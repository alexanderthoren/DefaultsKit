public enum Keyables {}

public protocol Keyable: Identifiable, Sendable {
    associatedtype T
    var id: String { get }
    var defaultValue: T { get }
}

/// A type-erased key wrapper that preserves type information
public struct AnyKey<T: Sendable>: Keyable {
    public let id: String
    public let defaultValue: T

    public init(id: String, defaultValue: T) {
        self.id = id
        self.defaultValue = defaultValue
    }
}

extension Keyables {
    /// Helper to create a key with type inference for defaultValue
    public static func key<T: Sendable>(id: String, defaultValue: T) -> AnyKey<T> {
        AnyKey(id: id, defaultValue: defaultValue)
    }
}
