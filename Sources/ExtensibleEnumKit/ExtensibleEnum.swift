import Foundation

// MARK: - Sequence Wrapper

/// A sequence wrapper that enables functional iteration over extensible enum cases.
///
/// Use via the `all` property on any `ExtensibleEnum` subclass:
/// ```swift
/// Workers.all.filter { $0.value.age > 30 }.map { $0.key }
/// ```
public struct ExtensibleEnumSequence<Value>: Sequence {
  public typealias Element = (key: String, value: Value)

  private let keysAndValues: [String: Value]

  public init(keysAndValues: [String: Value]) {
    self.keysAndValues = keysAndValues
  }

  public func makeIterator() -> AnyIterator<Element> {
    var keys = keysAndValues.keys.sorted().makeIterator()
    return AnyIterator {
      guard let key = keys.next(), let value = self.keysAndValues[key] else {
        return nil
      }
      return (key: key, value: value)
    }
  }

  /// The number of cases.
  public var count: Int {
    return keysAndValues.count
  }

  /// All keys in sorted order.
  public var keys: [String] {
    return keysAndValues.keys.sorted()
  }

  /// All values in key-sorted order.
  public var values: [Value] {
    return keys.compactMap { keysAndValues[$0] }
  }
}

// MARK: - Base Class

/// Base class for extensible enumerations usable from Swift and Objective-C.
///
/// ## Type-Safe Subclassing (Swift)
/// For compile-time type safety, conform to ``TypedExtensibleEnumProtocol``:
/// ```swift
/// final class StatusCode: ExtensibleEnum, TypedExtensibleEnumProtocol {
///   typealias RawValue = Int
///   var typedRawValue: Int { rawValue as! Int }
///
///   @objc static let ok = StatusCode(intValue: 200)
/// }
/// ```
///
/// ## Basic Subclassing (Swift + ObjC)
/// For simple cases without type safety:
/// ```swift
/// @objc class SimpleEnum: ExtensibleEnum {
///   @objc static let caseA = SimpleEnum(rawValue: "a")
/// }
/// ```
@objc
open class ExtensibleEnum: NSObject, ExtensibleEnumProtocol {

  /// The underlying value (type-erased).
  @objc
  public var rawValue: Any

  /// Creates a new instance with the given raw value.
  /// - Parameter rawValue: The underlying value to store.
  @objc
  public init(rawValue: Any) {
    self.rawValue = rawValue
    super.init()
  }

  // MARK: - ExtensibleEnumProtocol

  @objc
  open class func allKeys() -> [String] {
    return allKeysAndValues().keys.sorted()
  }

  @objc
  open class func allValues() -> [Any] {
    let keysAndValues = allKeysAndValues()
    return keysAndValues.keys.sorted().compactMap { keysAndValues[$0] }
  }

  @objc
  open class func allKeysAndValues() -> [String: Any] {
    var dict: [String: Any] = [:]
    var count: UInt32 = 0

    guard
      let metaClass = object_getClass(self),
      let properties = class_copyPropertyList(metaClass, &count)
    else {
      return [:]
    }

    defer {
      free(properties)
    }

    let ignoredNames: Set<String> = [
      "hash",
      "superclass",
      "description",
      "debugDescription"
    ]

    for i in 0..<Int(count) {
      let property = properties[i]
      let name = String(cString: property_getName(property))

      if ignoredNames.contains(name) || name.hasPrefix("_") {
        continue
      }

      guard
        let attr = property_getAttributes(property),
        let _ = String(utf8String: attr)
      else {
        continue
      }

      if let value = self.value(forKey: name) {
        dict[name] = value
      }
    }

    return dict
  }

  // MARK: - Swift Convenience Methods

  /// Access a value by its case name.
  ///
  /// ```swift
  /// let person = Workers["Brie"]  // Person?
  /// ```
  public static subscript(key: String) -> Any? {
    return allKeysAndValues()[key]
  }

  /// Returns the case name for this instance, or nil if not found.
  ///
  /// ```swift
  /// let worker = Workers.Brie
  /// print(worker.caseName)  // "Brie"
  /// ```
  open var caseName: String? {
    let keysAndValues = Self.allKeysAndValues()
    for (key, value) in keysAndValues {
      if let enumValue = value as? NSObject, let selfValue = rawValue as? NSObject {
        if enumValue.isEqual(selfValue) {
          return key
        }
      } else if String(describing: value) == String(describing: rawValue) {
        return key
      }
    }
    return nil
  }

  // MARK: - Objective-C Convenience Methods

  /// Returns the number of defined cases.
  @objc
  open class var count: Int {
    return allKeys().count
  }

  /// Returns the value for the given case name, or nil if not found.
  /// - Parameter key: The case name to look up.
  /// - Returns: The value associated with the key, or nil.
  @objc(valueForCaseNamed:)
  open class func value(forCaseNamed key: String) -> Any? {
    return allKeysAndValues()[key]
  }


  /// Enumerates all cases, calling the block with each key and value.
  ///
  /// Example (Objective-C):
  /// ```objc
  /// [Workers enumerateKeysAndValuesUsingBlock:^(NSString *key, id value, BOOL *stop) {
  ///     NSLog(@"%@: %@", key, value);
  ///     if ([key isEqualToString:@"done"]) *stop = YES;
  /// }];
  /// ```
  ///
  /// - Parameter block: A block called for each key-value pair. Set `stop` to YES to halt enumeration.
  @objc
  open class func enumerateKeysAndValues(using block: (String, Any, UnsafeMutablePointer<ObjCBool>) -> Void) {
    var stop: ObjCBool = false
    let keysAndValues = allKeysAndValues()
    for key in keysAndValues.keys.sorted() {
      guard let value = keysAndValues[key] else { continue }
      block(key, value, &stop)
      if stop.boolValue { break }
    }
  }

  /// Enumerates all values, calling the block with each value.
  ///
  /// Example (Objective-C):
  /// ```objc
  /// [Workers enumerateValuesUsingBlock:^(id value, BOOL *stop) {
  ///     NSLog(@"%@", value);
  /// }];
  /// ```
  ///
  /// - Parameter block: A block called for each value. Set `stop` to YES to halt enumeration.
  @objc
  open class func enumerateValues(using block: (Any, UnsafeMutablePointer<ObjCBool>) -> Void) {
    var stop: ObjCBool = false
    for value in allValues() {
      block(value, &stop)
      if stop.boolValue { break }
    }
  }
}
