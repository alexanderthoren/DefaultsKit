import Asynchrone

public struct SendableSharedStream<T: Sendable>: Sendable, AsyncSequence {
    private let makeIterator: @Sendable () -> AsyncThrowingStream<T, Error>.Iterator

    init(_ sharedSequence: @escaping @Sendable () -> SharedAsyncSequence<AsyncStream<T>>) {
        makeIterator = {
            sharedSequence().makeAsyncIterator()
        }
    }

    public func makeAsyncIterator() -> AsyncThrowingStream<T, Error>.Iterator {
        makeIterator()
    }
}

extension AsyncStream where Element: Sendable {
    func shared() -> SendableSharedStream<Element> {
        SendableSharedStream { self.shared() }
    }
}
