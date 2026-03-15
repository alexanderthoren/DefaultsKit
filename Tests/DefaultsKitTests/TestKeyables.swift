import Foundation
@testable import DefaultsKit

public extension Keyables {
    static var key1: AnyKey<Double> { .init(id: "test_key_1", defaultValue: 100.0) }
    static var key2: AnyKey<Double> { .init(id: "test_key_2", defaultValue: 200.0) }
    static var key3: AnyKey<Double> { .init(id: "test_key_3", defaultValue: 300.0) }
}
