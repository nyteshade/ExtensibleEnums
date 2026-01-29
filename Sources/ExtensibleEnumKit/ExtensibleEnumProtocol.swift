import Foundation

import ObjectiveC

// MARK: - Objective-C Protocol

/// Objective-C compatible protocol for extensible enumerations.
///
/// Exposes type-erased accessors for cross-bridge compatibility.
/// For type-safe Swift usage, see ``TypedExtensibleEnumProtocol``.
@objc
public protocol ExtensibleEnumProtocol {
  @objc static func allKeys() -> [String]
  @objc static func allValues() -> [Any]
  @objc static func allKeysAndValues() -> [String: Any]
}

// MARK: - Swift Type-Safe Protocol

/// Type-safe protocol for extensible enumerations in Swift.
///
/// Conforming types specify a concrete `RawValue` type, enabling
/// compile-time type checking.
///
/// ## Example
/// ```swift
/// final class Priority: ExtensibleEnum, TypedExtensibleEnumProtocol {
///   typealias RawValue = Int
///
///   @objc static let low = Priority(intValue: 0)
///   @objc static let high = Priority(intValue: 10)
///
///   var typedRawValue: Int { rawValue as! Int }
/// }
///
/// let value: Int = Priority.high.typedRawValue  // Type-safe
/// ```
public protocol TypedExtensibleEnumProtocol: ExtensibleEnumProtocol {

  /// The concrete type of raw values for this extensible enum.
  associatedtype RawValue

  /// The strongly-typed raw value for this instance.
  var typedRawValue: RawValue { get }

  /// Returns all values with their concrete type.
  static func allTypedValues() -> [RawValue]

  /// Returns the complete mapping with concrete value types.
  static func allTypedKeysAndValues() -> [String: RawValue]
}

// MARK: - Default Implementations for Typed Protocol

public extension TypedExtensibleEnumProtocol where Self: ExtensibleEnum {

  /// Default implementation converting typed values to type-erased array.
  static func allValues() -> [Any] {
    return allTypedValues()
  }

  /// Default implementation deriving typed values from typed key-value map.
  static func allTypedValues() -> [RawValue] {
    return allTypedKeysAndValues().keys.sorted().compactMap {
      allTypedKeysAndValues()[$0]
    }
  }

  /// Default implementation converting typed map to type-erased map.
  static func allKeysAndValues() -> [String: Any] {
    return allTypedKeysAndValues().mapValues { $0 as Any }
  }
}
