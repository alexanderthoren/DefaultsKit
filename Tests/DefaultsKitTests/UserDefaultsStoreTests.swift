import Foundation
import Testing
@testable import DefaultsKit

@Suite("UserDefaultsStore integration tests")
struct UserDefaultsStoreTests {
    @Test func get() async throws {
        let uniqueKey = "testKey_\(UUID().uuidString)"
        UserDefaults.standard.removeObject(forKey: uniqueKey)

        let sut = UserDefaultsStore.liveValue
        let result = sut.get(uniqueKey)

        #expect(result == nil)
    }

    @Test func setAndGetString() async throws {
        let uniqueKey = "testKey_\(UUID().uuidString)"
        UserDefaults.standard.removeObject(forKey: uniqueKey)

        let sut = UserDefaultsStore.liveValue
        sut.set(AnySendable("testValue"), uniqueKey)

        let result: String = sut.get(uniqueKey)?.value as! String
        #expect(result == "testValue")
    }

    @Test func setAndGetInteger() async throws {
        let uniqueKey = "intKey_\(UUID().uuidString)"
        UserDefaults.standard.removeObject(forKey: uniqueKey)

        let sut = UserDefaultsStore.liveValue
        sut.set(AnySendable(42), uniqueKey)

        let result = sut.get(uniqueKey)?.value as? Int
        #expect(result == 42)
    }

    @Test func setAndGetBoolean() async throws {
        let uniqueKey = "boolKey_\(UUID().uuidString)"
        UserDefaults.standard.removeObject(forKey: uniqueKey)

        let sut = UserDefaultsStore.liveValue
        sut.set(AnySendable(true), uniqueKey)

        let result = sut.get(uniqueKey)?.value as? Bool
        #expect(result == true)
    }

    @Test func setAndGetDouble() async throws {
        let uniqueKey = "doubleKey_\(UUID().uuidString)"
        UserDefaults.standard.removeObject(forKey: uniqueKey)

        let sut = UserDefaultsStore.liveValue
        sut.set(AnySendable(3.14159), uniqueKey)

        let result = sut.get(uniqueKey)?.value as? Double
        #expect(result == 3.14159)
    }

    @Test func setAndGetArray() async throws {
        let uniqueKey = "arrayKey_\(UUID().uuidString)"
        UserDefaults.standard.removeObject(forKey: uniqueKey)

        let sut = UserDefaultsStore.liveValue
        let testArray = ["item1", "item2", "item3"]
        sut.set(AnySendable(testArray), uniqueKey)

        let result = sut.get(uniqueKey)?.value as? [String]
        #expect(result == testArray)
    }

    @Test func setAndGetDictionary() async throws {
        let uniqueKey = "dictKey_\(UUID().uuidString)"
        UserDefaults.standard.removeObject(forKey: uniqueKey)

        let sut = UserDefaultsStore.liveValue
        let testDict = ["key1": "value1", "key2": "value2"]
        sut.set(AnySendable(testDict), uniqueKey)

        let result = sut.get(uniqueKey)?.value as? [String: String]
        #expect(result == testDict)
    }

    @Test func setAndGetData() async throws {
        let uniqueKey = "dataKey_\(UUID().uuidString)"
        UserDefaults.standard.removeObject(forKey: uniqueKey)

        let sut = UserDefaultsStore.liveValue
        let testData = "test data".data(using: .utf8)!
        sut.set(AnySendable(testData), uniqueKey)

        let result = sut.get(uniqueKey)?.value as? Data
        #expect(result == testData)
    }

    @Test func setNilValue() async throws {
        let uniqueKey = "nilKey_\(UUID().uuidString)"
        UserDefaults.standard.removeObject(forKey: uniqueKey)

        let sut = UserDefaultsStore.liveValue
        sut.set(AnySendable("initialValue"), uniqueKey)
        sut.set(nil, uniqueKey)

        let result = sut.get(uniqueKey)
        #expect(result == nil)
    }

    @Test func removeKey() async throws {
        let uniqueKey = "removeKey_\(UUID().uuidString)"
        UserDefaults.standard.removeObject(forKey: uniqueKey)

        let sut = UserDefaultsStore.liveValue
        sut.set(AnySendable("valueToRemove"), uniqueKey)
        sut.remove(uniqueKey)

        let result = sut.get(uniqueKey)
        #expect(result == nil)
    }

    @Test func overwriteExistingValue() async throws {
        let uniqueKey = "overwriteKey_\(UUID().uuidString)"
        UserDefaults.standard.removeObject(forKey: uniqueKey)

        let sut = UserDefaultsStore.liveValue
        sut.set(AnySendable("originalValue"), uniqueKey)
        sut.set(AnySendable("newValue"), uniqueKey)

        let result = sut.get(uniqueKey)?.value as? String
        #expect(result == "newValue")
    }

    @Test func removeNonExistentKey() async throws {
        let uniqueKey = "nonExistentKey_\(UUID().uuidString)"
        UserDefaults.standard.removeObject(forKey: uniqueKey)

        let sut = UserDefaultsStore.liveValue
        sut.remove(uniqueKey)

        let result = sut.get(uniqueKey)
        #expect(result == nil)
    }
}
