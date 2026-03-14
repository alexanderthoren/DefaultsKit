import Foundation
import ConcurrencyExtras

public final class StreamsManager: Sendable {
    private let streams: LockIsolated<[String: [UUID: AnyContinuation]]> = .init([:])

    public init() {}

    @Sendable public func yield(for key: String, value: any Sendable) {
        streams.withValue { continuations in
            continuations[key]?.values.forEach { $0.yield(value) }
        }
    }

    public func getStream<T: Sendable>(for key: String) -> AsyncStream<T> {
        let (stream, continuation) = AsyncStream<T>.makeStream()
        let id = UUID()

        streams.withValue { continuations in
            if continuations[key] == nil {
                continuations[key] = [:]
            }
            continuations[key]?[id] = AnyContinuation(continuation)
        }

        continuation.onTermination = { [weak self] _ in
            self?.streams.withValue { continuations in
                continuations[key]?.removeValue(forKey: id)
                if continuations[key]?.isEmpty == true {
                    continuations.removeValue(forKey: key)
                }
            }
        }

        return stream
    }
}

private struct AnyContinuation: Sendable {
    private let _yield: @Sendable (Any) -> Void

    init<T: Sendable>(_ continuation: AsyncStream<T>.Continuation) {
        _yield = { value in
            if let typedValue = value as? T {
                continuation.yield(typedValue)
            }
        }
    }

    func yield(_ value: Any) {
        _yield(value)
    }
}
