public enum Keyables {
    public protocol Keyable: Identifiable, Sendable {
        associatedtype T
        var id: String { get }
        var defaultValue: T { get }
    }
}
