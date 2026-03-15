import Testing
@testable import DefaultsKit

@Suite("UserDefaultsRepository integration tests")
struct UserDefaultsRepositoryIntegrationTests {
    @Test func stream_sequential_operations() async throws {
        var store = UserDefaultsStore.testValue
        store.set = { _, _ in }
        let sut = UserDefaultsRepository.liveValue(store: store)

        let stream: SendableSharedStream<Double> = sut.stream(Keyables.key1)
        let receivedValues = try await stream.captureValues(count: 3) {
            sut.set(1000.0, Keyables.key1)
            await Task.megaYield()

            sut.set(2000.0, Keyables.key1)
            await Task.megaYield()
        }.dropFirst()

        #expect(receivedValues == [1000.0, 2000.0])
    }

    @Test func stream_concurrent_operations() async throws {
        var store = UserDefaultsStore.testValue
        store.set = { _, _ in }
        let sut = UserDefaultsRepository.liveValue(store: store)

        let streams: [SendableSharedStream<Double>] = [
            sut.stream(Keyables.key1),
            sut.stream(Keyables.key2),
            sut.stream(Keyables.key3),
        ]

        let results = try await captureConcurrentValues(from: streams, actions: [
            { sut.set(100.0, Keyables.key1) },
            { sut.set(200.0, Keyables.key2) },
            { sut.set(300.0, Keyables.key3) },
        ])

        #expect(results[0].contains(100))
        #expect(results[1].contains(200))
        #expect(results[2].contains(300))
    }

    @Test func stream_multiple_subscribers() async throws {
        var store = UserDefaultsStore.testValue
        store.set = { _, _ in }
        let sut = UserDefaultsRepository.liveValue(store: store)

        let streams: [SendableSharedStream<Double>] = [
            sut.stream(Keyables.key1),
            sut.stream(Keyables.key1),
        ]

        let results = try await captureConcurrentValues(from: streams, actions: [
            { sut.set(100.0, Keyables.key1) },
        ])

        #expect(results[0] == [100.0])
        #expect(results[1] == [100.0])
    }
}

