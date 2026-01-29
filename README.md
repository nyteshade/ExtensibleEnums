# ExtensibleEnumKit

A Swift package that provides extensible enumerations with support for complex value types, runtime introspection, and Objective-C interoperability.

## The Problem

Swift enums are powerful but have a fundamental limitation: they cannot be extended to add new cases. Once an enum is defined, its cases are fixed.

```swift
// This is impossible in Swift:
enum Status {
    case pending
    case approved
}

extension Status {
    case rejected  // Error: Enum 'case' is not allowed outside of an enum
}
```

This becomes problematic when you need to:
- Add domain-specific cases in different modules
- Allow third-party code to extend your type's values
- Define values that can grow over time without modifying the original declaration

## The Solution

ExtensibleEnumKit provides class-based enumerations that can be extended, support any value type (not just integers or strings), and offer full runtime introspection of all defined cases.

```swift
import ExtensibleEnumKit

@ExtensibleEnumeration(Int.self)
@objc public class StatusCode: ExtensibleEnum, TypedExtensibleEnumProtocol {
    @objc static let ok = StatusCode(intValue: 200)
    @objc static let notFound = StatusCode(intValue: 404)
}

// Extend in another file or module
public extension StatusCode {
    @objc static let serverError = StatusCode(intValue: 500)
    @objc static let unauthorized = StatusCode(intValue: 401)
}
```

## Installation

Add ExtensibleEnumKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/user/ExtensibleEnumKit.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["ExtensibleEnumKit"]
    )
]
```

**Requirements:** Swift 5.9+, macOS 13+ / iOS 13+

## Usage

### Basic Definition

Define an extensible enum by subclassing `ExtensibleEnum` and applying the `@ExtensibleEnumeration` macro:

```swift
import ExtensibleEnumKit

@ExtensibleEnumeration(String.self)
@objc public class LogLevel: ExtensibleEnum, TypedExtensibleEnumProtocol {
    @objc static let debug = LogLevel(rawValue: "DEBUG")
    @objc static let info = LogLevel(rawValue: "INFO")
    @objc static let warning = LogLevel(rawValue: "WARNING")
    @objc static let error = LogLevel(rawValue: "ERROR")
}
```

### Complex Value Types

Unlike traditional enums, ExtensibleEnumKit supports any value type:

```swift
@objc @objcMembers
public class NetworkEndpoint: NSObject {
    let host: String
    let port: Int
    let isSecure: Bool

    init(host: String, port: Int, isSecure: Bool = true) {
        self.host = host
        self.port = port
        self.isSecure = isSecure
    }
}

@ExtensibleEnumeration(NetworkEndpoint.self)
@objc public class Endpoints: ExtensibleEnum, TypedExtensibleEnumProtocol {
    @objc static let production = NetworkEndpoint(host: "api.example.com", port: 443)
    @objc static let staging = NetworkEndpoint(host: "staging.example.com", port: 443)
    @objc static let local = NetworkEndpoint(host: "localhost", port: 8080, isSecure: false)
}
```

### Extending in Other Files or Modules

The key feature: add new cases anywhere via extensions.

```swift
// In your test target or another module:
public extension Endpoints {
    @objc static let mock = NetworkEndpoint(host: "mock.test", port: 9999, isSecure: false)
}
```

### Runtime Introspection

Query all defined cases at runtime:

```swift
// Get all case names
let keys: [String] = StatusCode.allKeys()
// ["notFound", "ok", "serverError", "unauthorized"]

// Get all values (typed)
let codes: [Int] = StatusCode.allValues()
// [200, 401, 404, 500]

// Get key-value mapping (typed)
let mapping: [String: Int] = StatusCode.allKeysAndValues()
// ["ok": 200, "notFound": 404, "serverError": 500, "unauthorized": 401]
```

### Accessing the Raw Value

```swift
let status = StatusCode.ok

// Type-safe access
let code: Int = status.typedRawValue  // 200

// Type-erased access (for generic code)
let anyValue: Any = status.rawValue
```

## Objective-C Interoperability

ExtensibleEnumKit is fully compatible with Objective-C:

```objc
// Objective-C usage
NSArray<NSString *> *keys = [StatusCode allKeys];
NSDictionary<NSString *, id> *mapping = [StatusCode allKeysAndValues];

StatusCode *status = StatusCode.ok;
NSLog(@"Status: %@", status.rawValue);
```

The `@objc` attribute on static properties is required for runtime discovery.

## API Reference

### `@ExtensibleEnumeration(_:)` Macro

Generates type-safe accessors for your extensible enum.

```swift
@ExtensibleEnumeration(YourType.self)
```

**Generates:**
- `typealias RawValue` - The concrete value type
- `init?(rawValue:)` - Failable initializer
- `typedRawValue: RawValue` - Type-safe value accessor
- `static func allValues() -> [RawValue]` - All values (typed)
- `static func allKeysAndValues() -> [String: RawValue]` - Complete mapping (typed)

### `ExtensibleEnum` Base Class

The base class providing core functionality:

- `rawValue: Any` - The underlying value (type-erased)
- `init(rawValue:)` - Initialize with any value
- `class func allKeys() -> [String]` - All case names
- `class func allValues() -> [Any]` - All values (type-erased)
- `class func allKeysAndValues() -> [String: Any]` - Complete mapping (type-erased)

### `TypedExtensibleEnumProtocol`

Protocol for type-safe Swift access:

- `associatedtype RawValue` - The concrete value type
- `typedRawValue: RawValue` - Type-safe value accessor

## Best Practices

1. **Always use `@objc` on static properties** - Required for runtime discovery
2. **Mark classes as `final`** when you don't need further subclassing
3. **Use `@objcMembers`** on value types for full Objective-C compatibility
4. **Prefer typed accessors** (`allValues()`, `typedRawValue`) in Swift code

## How It Works

ExtensibleEnumKit uses Objective-C runtime introspection to discover all static properties at runtime. The `@objc` attribute exposes properties to the runtime, and the base class uses `class_copyPropertyList` to enumerate them.

The `@ExtensibleEnumeration` macro generates type-safe wrappers that cast the discovered values to your specified type, giving you compile-time type safety while maintaining runtime extensibility.

## License

MIT License
