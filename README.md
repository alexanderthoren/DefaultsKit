# DefaultsKit

A type-safe Swift wrapper around UserDefaults with built-in reactive streams.

## Why DefaultsKit?

DefaultsKit provides a modern, type-safe wrapper around `UserDefaults` with:

- **Type-safe keys**: Define keys as types that conform to `Keyable` - misspelled keys become compiler errors
- **Automatic type inference**: Values are strongly typed, eliminating manual casting
- **Built-in default values**: Each key declares its own default, no need to check for `nil`
- **Reactive streams**: Observe changes via `AsyncStream` without `NotificationCenter` hacks

## Installation

Add DefaultsKit to your project via Swift Package Manager:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/alexanderthoren/DefaultsKit.git", from: "1.0.0")
]
```

Or add it in Xcode via **File > Add Package Dependency**.

## Quick Start

### 1. Define Your Keys

Create type-safe keys using `AnyKey` - the default implementation:

```swift
import DefaultsKit

public extension Keyables {
    static var userName: AnyKey<String> {
        .init(id: "user_name", defaultValue: "")
    }
    static var theme: AnyKey<String> {
        .init(id: "app_theme", defaultValue: "system")
    }
    static var isLoggedIn: AnyKey<Bool> {
        .init(id: "is_logged_in", defaultValue: false)
    }
}
```

Or use the shorthand helper:

```swift
public extension Keyables {
    static var userName: AnyKey<String> { .init(id: "user_name", defaultValue: "") }
    static var theme: AnyKey<String> { .init(id: "app_theme", defaultValue: "system") }
    static var isLoggedIn: AnyKey<Bool> { .init(id: "is_logged_in", defaultValue: false) }
}
```

### 2. Use the Repository

```swift
let repository = UserDefaultsRepository.liveValue

// Get a value (type inferred from key's defaultValue)
let userName = repository.get(Keyables.userName)

// Set a new value
repository.set("Alice", Keyables.userName)
```

### 3. Observe Changes

```swift
// Create a stream that emits when the key changes (type inferred)
let stream = repository.stream(Keyables.userName)

for await name in stream {
    print("User name changed to: \(name)")
}
```

## Key Concepts

### Keyable Protocol & AnyKey

A `Keyable` is a type-safe wrapper that defines:
- `id`: The unique string key used in UserDefaults
- `defaultValue`: The value returned when no value is stored

Most of the time, you'll use `AnyKey<T>` which is a struct that implements `Keyable`:

```swift
public protocol Keyable: Identifiable, Sendable {
    associatedtype T
    var id: String { get }
    var defaultValue: T { get }
}

public struct AnyKey<T: Sendable>: Keyable {
    public let id: String
    public let defaultValue: T
}
```

### UserDefaultsRepository

The main interface for interacting with stored values:

| Method | Description |
|--------|-------------|
| `get(_:)` | Retrieve a value, returning the default if not set |
| `set(_:_:)` | Store a new value |
| `stream(_:)` | Observe changes as an async stream |

### SendableSharedStream

A shared, sendable async sequence that broadcasts values to multiple subscribers. Each subscriber receives the current value followed by all subsequent changes.

## Adding New Keys

To add a new keyable to your app, use `AnyKey`:

```swift
public extension Keyables {
    static var myNewKey: AnyKey<Int> { .init(id: "my_new_key", defaultValue: 0) }
}
```

## Supported Types

DefaultsKit supports any `Sendable` type that can be stored in UserDefaults, including:

- `String`, `Int`, `Double`, `Bool`
- `[String]` (arrays)
- `[String: String]` (dictionaries)
- `Data`
- Any custom `Codable` type

## Requirements

- Swift 6.2+
- macOS 15+
- iOS 18+ (if targeting iOS)

## License

MIT License
