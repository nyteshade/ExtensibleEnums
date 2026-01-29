import Foundation

public protocol ExtensibleEnumProtocol {
  typealias RawValue = Any

  static func allKeys() -> [String]
  static func allValues() -> [RawValue]
}

public extension ExtensibleEnumProtocol where Self: ExtensibleEnum {
  static func allKeys() -> [String] {
    allKeysAndValues().keys.sorted()
  }

  static func allValues() -> [RawValue] {
    allKeysAndValues().map { $0.value }
  }

  static func allKeysAndValues() -> [String: RawValue] {
    var dict: [String: RawValue] = [:]
    var count: UInt32 = 0

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

    free(properties)

    return dict
  }
}
