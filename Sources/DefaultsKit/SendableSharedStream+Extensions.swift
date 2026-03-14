#if DEBUG

    import ConcurrencyExtras
    import Foundation

    extension SendableSharedStream {
        /// Captures the first value emitted from an async stream after triggering an action.
        /// - Parameters:
        ///   - action: The action to trigger that will cause the stream to emit a value
        ///   - timeout: Maximum time to wait for a value (default: 0.1 seconds)
        /// - Returns: The first emitted value, or nil if no value is emitted or timeout occurs
        func captureFirstValue(
            triggeredBy action: () async -> Void,
            timeout: TimeInterval = 0.1
        ) async throws -> Element? where Element: Sendable {
            let capturedResult: LockIsolated<Element?> = .init(nil)

            let streamTask = Task { @Sendable in
                for try await result in self {
                    capturedResult.withValue {
                        $0 = result
                    }
                    break
                }
            }

            let timeoutTask = Task {
                try await Task.sleep(for: .seconds(timeout))
            }

            await action()

            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { try await streamTask.value }
                group.addTask { try await timeoutTask.value }

                defer {
                    streamTask.cancel()
                    timeoutTask.cancel()
                }

                try await group.next()
            }

            return capturedResult.value
        }

        /// Captures a specific number of values from the stream after triggering an action
        /// - Parameters:
        ///   - count: Number of values to capture
        ///   - action: The action to trigger that will cause the stream to emit values
        ///   - timeout: Maximum time to wait for values (default: 0.1 seconds)
        /// - Returns: Array of captured values
        func captureValues(
            count: Int,
            timeout: TimeInterval = 0.1,
            triggeredBy action: () async -> Void
        ) async throws -> [Element] where Element: Sendable {
            let capturedValues: LockIsolated<[Element]> = .init([])

            let streamTask = Task { @Sendable in
                for try await value in self {
                    capturedValues.withValue { values in
                        values.append(value)
                        if values.count >= count {
                            return
                        }
                    }
                    if capturedValues.value.count >= count {
                        break
                    }
                }
            }

            await Task.megaYield()

            let timeoutTask = Task {
                try await Task.sleep(for: .seconds(timeout))
            }

            await action()

            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { try await streamTask.value }
                group.addTask { try await timeoutTask.value }

                defer {
                    streamTask.cancel()
                    timeoutTask.cancel()
                }

                try await group.next()
            }

            return capturedValues.value
        }
    }

    /// Captures values from multiple streams concurrently after triggering actions
    /// - Parameters:
    ///   - streams: Array of streams to capture values from
    ///   - timeout: Maximum time to wait for values (default: 0.1 seconds)
    ///   - actions: Array of actions to trigger concurrently
    /// - Returns: Array of captured values for each stream
    func captureConcurrentValues<T: Sendable>(
        from streams: [SendableSharedStream<T>],
        timeout: TimeInterval = 0.1,
        actions: [@Sendable () -> Void]
    ) async throws -> [[T]] {
        let capturedValues: LockIsolated<[[T]]> = .init(Array(repeating: [], count: streams.count))

        let streamTasks = streams.enumerated().map { index, stream in
            Task { @Sendable in
                for try await value in stream {
                    capturedValues.withValue { values in
                        values[index].append(value)
                    }
                    break
                }
            }
        }

        await Task.megaYield()

        let timeoutTask = Task {
            try await Task.sleep(for: .seconds(timeout))
        }

        let actionTasks = actions.map { action in
            Task { @Sendable in action() }
        }

        for task in actionTasks {
            await task.value
        }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for task in streamTasks {
                group.addTask { try await task.value }
            }
            group.addTask { try await timeoutTask.value }

            defer {
                streamTasks.forEach { $0.cancel() }
                timeoutTask.cancel()
            }

            try await group.next()
        }

        return capturedValues.value
    }

#endif
