import Foundation

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
}
