public struct UserDefaultsRepository: Sendable {
    public var get: @Sendable (any Keyables.Keyable) -> AnySendable
    public var set: @Sendable (AnySendable, any Keyables.Keyable) -> Void
    public var stream: @Sendable (any Keyables.Keyable) -> AsyncStream<AnySendable>

    public func get<U>(key: any Keyables.Keyable) -> U {
        guard let value = get(key).value as? U else {
            fatalError("Value for key \(key.id) is not of type \(U.self)")
        }
        return value
    }

    public func set<U>(_ newValue: U, key: any Keyables.Keyable) {
        set(AnySendable(newValue), key)
    }

    public func stream<U>(key: any Keyables.Keyable) -> SendableSharedStream<U> {
        let sourceStream = stream(key)
        let mappedStream = AsyncStream<U> { continuation in
            let task = Task {
                continuation.yield(get(key: key))

                for await anySendable in sourceStream {
                    guard let value = anySendable.value as? U else {
                        fatalError("Value for key \(key.id) is not of type \(U.self)")
                    }
                    continuation.yield(value)
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
        return mappedStream.shared()
    }
}

extension UserDefaultsRepository {
    public static func liveValue(store: UserDefaultsStore) -> Self {
        let streamsManager = StreamsManager()

        return UserDefaultsRepository(
            get: { key in
                store.get(key.id) ?? AnySendable(key.defaultValue)
            },
            set: { newValue, key in
                store.set(newValue, key.id)
                streamsManager.yield(for: key.id, value: newValue)
            },
            stream: { key in
                streamsManager.getStream(for: key.id)
            }
        )
    }
}

#if DEBUG
    extension UserDefaultsRepository {
        public static var testValue: Self {
            UserDefaultsRepository(
                get: { _ in fatalError("get not implemented") },
                set: { _, _ in fatalError("set not implemented") },
                stream: { _ in fatalError("stream not implemented") }
            )
        }
    }
#endif
