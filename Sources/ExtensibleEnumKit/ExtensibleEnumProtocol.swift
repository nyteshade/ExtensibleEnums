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
/// @ExtensibleEnumeration(Int.self)
/// @objc final class Priority: ExtensibleEnum, TypedExtensibleEnumProtocol {
///   @objc static let low = Priority(intValue: 0)
///   @objc static let high = Priority(intValue: 10)
/// }
///
/// let value: Int = Priority.high.typedRawValue  // Type-safe
/// let all: [Int] = Priority.allValues()         // Typed array
/// ```
public protocol TypedExtensibleEnumProtocol: ExtensibleEnumProtocol {

  /// The concrete type of raw values for this extensible enum.
  associatedtype RawValue

  /// The strongly-typed raw value for this instance.
  var typedRawValue: RawValue { get }
}
