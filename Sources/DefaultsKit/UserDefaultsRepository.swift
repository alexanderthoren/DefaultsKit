public struct UserDefaultsRepository: Sendable {
    private var get: @Sendable (any Keyable) -> AnySendable
    private var set: @Sendable (AnySendable, any Keyable) -> Void
    private var remove: @Sendable (any Keyable) -> Void
    private var stream: @Sendable (any Keyable) -> AsyncStream<AnySendable>
    
    init(
        get: @escaping @Sendable (any Keyable) -> AnySendable,
        set: @escaping @Sendable (AnySendable, any Keyable) -> Void,
        remove: @escaping @Sendable (any Keyable) -> Void,
        stream: @escaping @Sendable (any Keyable) -> AsyncStream<AnySendable>
    ) {
        self.get = get
        self.set = set
        self.remove = remove
        self.stream = stream
    }

    public func get<T: Keyable>(_ key: T) -> T.T {
        let value = get(key)
        guard let typedValue = value.value as? T.T else {
            fatalError("Value for key \(key.id) is not of type \(T.T.self)")
        }
        return typedValue
    }

    public func set<T: Keyable>(_ newValue: T.T, _ key: T) {
        set(AnySendable(newValue), key)
    }
    
    public func remove<T: Keyable>(_ key: T) {
        remove(key)
    }

    public func stream<T: Keyable>(_ key: T) -> SendableSharedStream<T.T> {
        let sourceStream = stream(key)
        let mappedStream = AsyncStream<T.T> { continuation in
            let task = Task {
                continuation.yield(get(key))

                for await anySendable in sourceStream {
                    guard let value = anySendable.value as? T.T else {
                        fatalError("Value for key \(key.id) is not of type \(T.T.self)")
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
    public static var liveValue: Self {
        liveValue(store: .liveValue)
    }
    
    static func liveValue(store: UserDefaultsStore) -> Self {
        let streamsManager = StreamsManager()

        return UserDefaultsRepository(
            get: { key in
                store.get(key.id) ?? AnySendable(key.defaultValue)
            },
            set: { newValue, key in
                store.set(newValue, key.id)
                streamsManager.yield(for: key.id, value: newValue)
            },
            remove: { key in
                store.remove(key.id)
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
                remove: { _ in fatalError("remove not implemented") },
                stream: { _ in fatalError("stream not implemented") }
            )
        }
    }
#endif
