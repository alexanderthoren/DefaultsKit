# DefaultsKit

A type-safe Swift wrapper around UserDefaults with built-in reactive streams.

## Why DefaultsKit?

Working with `UserDefaults` directly has several pain points:

- **String-based keys**: Easy to misspell keys, leading to silent bugs
- **No type safety**: Values are retrieved as `Any?` and require manual casting
- **No default values**: You must manually check for `nil` and provide defaults
- **No built-in observation**: Monitoring changes requires `NotificationCenter` hacks

DefaultsKit solves these by providing:

- **Type-safe keys**: Define keys as types that conform to `Keyable`
- **Compile-time key checking**: Misspelled keys become compiler errors
- **Automatic default values**: Each key declares its own default
- **Reactive streams**: Observe changes via `AsyncStream`

## Installation

Add DefaultsKit to your project via Swift Package Manager:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/yourusername/DefaultsKit", from: "1.0.0")
]
```

Or add it in Xcode via **File > Add Package Dependency**.

## Quick Start

### 1. Define Your Keys

Create type-safe keys by extending `Keyables`:

```swift
import DefaultsKit

public extension Keyables {
    static var userName: any Keyable { UserNameKey() }
    static var theme: any Keyable { ThemeKey() }
    static var isLoggedIn: any Keyable { IsLoggedInKey() }

    private struct UserNameKey: Keyable {
        let id: String = "user_name"
        let defaultValue: String = ""
    }

    private struct ThemeKey: Keyable {
        let id: String = "app_theme"
        let defaultValue: String = "system"
    }

    private struct IsLoggedInKey: Keyable {
        let id: String = "is_logged_in"
        let defaultValue: Bool = false
    }
}
```

### 2. Use the Repository

```swift
let repository = UserDefaultsRepository.liveValue

// Get a value (returns default if not set)
let userName: String = repository.get(key: Keyables.userName)

// Set a new value
repository.set("Alice", key: Keyables.userName)
```

### 3. Observe Changes

```swift
// Create a stream that emits when the key changes
let stream: SendableSharedStream<String> = repository.stream(key: Keyables.userName)

for await name in stream {
    print("User name changed to: \(name)")
}
```

## Key Concepts

### Keyable Protocol

A `Keyable` is a type-safe wrapper that defines:
- `id`: The unique string key used in UserDefaults
- `defaultValue`: The value returned when no value is stored

```swift
public protocol Keyable: Identifiable, Sendable {
    associatedtype T
    var id: String { get }
    var defaultValue: T { get }
}
```

### UserDefaultsRepository

The main interface for interacting with stored values:

| Method | Description |
|--------|-------------|
| `get(key:)` | Retrieve a value, returning the default if not set |
| `set(_:key:)` | Store a new value |
| `stream(key:)` | Observe changes as an async stream |

### SendableSharedStream

A shared, sendable async sequence that broadcasts values to multiple subscribers. Each subscriber receives the current value followed by all subsequent changes.

## Adding New Keys

To add a new keyable to your app:

1. Create a private struct that conforms to `Keyable`
2. Set the `id` to a unique string
3. Set the `defaultValue` to a sensible fallback
4. Add a static computed property to access it

```swift
public extension Keyables {
    static var myNewKey: any Keyable { MyNewKey() }

    private struct MyNewKey: Keyable {
        let id: String = "my_new_key"
        let defaultValue: Int = 0
    }
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