import Foundation

public struct AnySendable: @unchecked Sendable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }
}

struct UserDefaultsStore: Sendable {
    var get: @Sendable (_ key: String) -> AnySendable?
    var set: @Sendable (_ value: AnySendable?, _ key: String) -> Void
    var remove: @Sendable (_ key: String) -> Void
}

extension UserDefaultsStore {
    static var liveValue: Self {
        UserDefaultsStore(
            get: { key in
                guard let value = UserDefaults.standard.object(forKey: key) else { return nil }
                return AnySendable(value)
            },
            set: { value, key in
                UserDefaults.standard.set(value?.value, forKey: key)
            },
            remove: { key in
                UserDefaults.standard.removeObject(forKey: key)
            }
        )
    }
}

#if DEBUG
    extension UserDefaultsStore {
        static var testValue: Self {
            UserDefaultsStore(
                get: { _ in nil },
                set: { _, _ in },
                remove: { _ in }
            )
        }
    }
#endif
