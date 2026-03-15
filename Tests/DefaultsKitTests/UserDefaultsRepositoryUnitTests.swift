import Testing
@testable import DefaultsKit

@Suite("UserDefaultsRepository unit tests")
struct UserDefaultsRepositoryUnitTests {
    @Test func get() {
        var store = UserDefaultsStore.testValue
        store.get = { key in
            #expect(key == "test_key_1")
            return AnySendable(100.0)
        }
        let sut = UserDefaultsRepository.liveValue(store: store)

        let result: Double = sut.get(Keyables.key1)
        #expect(result == 100.0)
    }

    @Test func set() {
        var store = UserDefaultsStore.testValue
        store.set = { value, key in
            #expect(value!.value as! Double == 850)
            #expect(key == "test_key_1")
        }
        let sut = UserDefaultsRepository.liveValue(store: store)

        sut.set(850.0, Keyables.key1)
    }

    @Test func stream() async throws {
        var store = UserDefaultsStore.testValue
        store.set = { _, _ in }
        let sut = UserDefaultsRepository.liveValue(store: store)

        let stream: SendableSharedStream<Double> = sut.stream(Keyables.key1)

        let result = try await stream.captureValues(count: 2) {
            sut.set(100.0, Keyables.key1)
        }

        #expect(result == [100.0, 100.0])
    }
}
