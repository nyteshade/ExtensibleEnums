import Foundation

// 1. Define a protocol to handle the generic extraction
public protocol ExtensibleEnumProtocol: RawRepresentable {
  static func allKeys() -> [String]
  static func allValues() -> [RawValue]
}

// 2. Implement the logic in a protocol extension
public extension ExtensibleEnumProtocol where Self: NSObject {
  static func allKeys() -> [String] {
    allKeysAndValues().keys.sorted()
  }

  static func allValues() -> [RawValue] {
    allKeysAndValues().map { $0.value }
  }

  static func allKeysAndValues() -> [String: RawValue] {
    var dict: [String: RawValue] = [:]
    var count: UInt32 = 0

    // 1. Get the metaclass (statics live here)
    guard
      let metaClass = object_getClass(self),
      let properties = class_copyPropertyList(metaClass, &count)
    else {
      return [:]
    }

    let ignoredNames = ["hash", "superclass", "description", "debugDescription"]

    for i in 0..<Int(count) {
      let property = properties[i]
      let name = String(cString: property_getName(property))

      // 2. Basic name filter
      if ignoredNames.contains(name) || name.hasPrefix("_") {
        continue
      }

      // 3. Inspect Attributes (Optional but safer)
      // This ensures it's a property the Obj-C runtime recognizes as such
      guard
        let attr = property_getAttributes(property),
        let _ = String(utf8String: attr)
      else {
        continue
      }

      // 4. Extract the value via KVC
      // KVC handles the dynamic lookup of both 'static let' and 'static var'
      // Use a do-catch or check respondsTo to avoid KVC exceptions if a key isn't KVC-compliant
      if let value = self.value(forKey: name) as? RawValue {
        dict[name] = value
      }
    }

    free(properties)

    return dict
  }
}
