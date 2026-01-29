import Testing
import Foundation
@testable import ExtensibleEnumKit

// MARK: - Test Value Types

@objc @objcMembers
final class Color: NSObject, @unchecked Sendable {
  let r: Int
  let g: Int
  let b: Int

  init(r: Int, g: Int, b: Int) {
    self.r = r
    self.g = g
    self.b = b
  }

  override func isEqual(_ object: Any?) -> Bool {
    guard let other = object as? Color else { return false }
    return r == other.r && g == other.g && b == other.b
  }
}

// MARK: - Test Enum (using macro)

@ExtensibleEnumeration(Color.self)
@objc final class Colors: ExtensibleEnum, TypedExtensibleEnumProtocol {
  @objc static let red = Color(r: 255, g: 0, b: 0)
  @objc static let green = Color(r: 0, g: 255, b: 0)
  @objc static let blue = Color(r: 0, g: 0, b: 255)
}

// Extension to test extensibility
extension Colors {
  @objc static let yellow = Color(r: 255, g: 255, b: 0)
}

// MARK: - Base Class Tests

@Suite("ExtensibleEnum Base Class")
struct ExtensibleEnumBaseTests {

  @Test("allKeys returns all case names sorted")
  func allKeysReturnsSortedNames() {
    let keys = Colors.allKeys()
    #expect(keys.count == 4)
    #expect(keys == ["blue", "green", "red", "yellow"])
  }

  @Test("allValues returns all values")
  func allValuesReturnsAllValues() {
    let values: [Color] = Colors.allValues()
    #expect(values.count == 4)
  }

  @Test("allKeysAndValues returns complete mapping")
  func allKeysAndValuesReturnsMapping() {
    let mapping: [String: Color] = Colors.allKeysAndValues()
    #expect(mapping.count == 4)
    #expect(mapping["red"]?.r == 255)
    #expect(mapping["green"]?.g == 255)
    #expect(mapping["blue"]?.b == 255)
    #expect(mapping["yellow"]?.r == 255)
    #expect(mapping["yellow"]?.g == 255)
  }

  @Test("count returns correct number of cases")
  func countReturnsCorrectNumber() {
    #expect(Colors.count == 4)
  }

  @Test("caseName returns correct name for instance")
  func caseNameReturnsCorrectName() {
    let instance = Colors(rawValue: Color(r: 255, g: 0, b: 0))
    #expect(instance?.caseName == "red")
  }

  @Test("caseName returns nil for unknown value")
  func caseNameReturnsNilForUnknown() {
    let instance = Colors(rawValue: Color(r: 1, g: 2, b: 3))
    #expect(instance?.caseName == nil)
  }

  @Test("value(forCaseNamed:) returns correct value")
  func valueForCaseNamedReturnsValue() {
    let value = Colors.value(forCaseNamed: "red") as? Color
    #expect(value?.r == 255)
    #expect(value?.g == 0)
    #expect(value?.b == 0)
  }

  @Test("value(forCaseNamed:) returns nil for unknown key")
  func valueForCaseNamedReturnsNilForUnknown() {
    let value = Colors.value(forCaseNamed: "purple")
    #expect(value == nil)
  }
}

// MARK: - Typed Protocol Tests

@Suite("TypedExtensibleEnumProtocol")
struct TypedProtocolTests {

  @Test("typedRawValue returns correctly typed value")
  func typedRawValueReturnsTypedValue() {
    let instance = Colors(rawValue: Color(r: 0, g: 255, b: 0))
    let color: Color = instance!.typedRawValue
    #expect(color.g == 255)
  }

  @Test("allValues returns typed array")
  func allValuesReturnsTypedArray() {
    let values: [Color] = Colors.allValues()
    #expect(values.count == 4)
    // Verify we can access Color properties without casting
    let totalRed = values.reduce(0) { $0 + $1.r }
    #expect(totalRed > 0)
  }

  @Test("allKeysAndValues returns typed dictionary")
  func allKeysAndValuesReturnsTypedDictionary() {
    let mapping: [String: Color] = Colors.allKeysAndValues()
    // Verify we can access Color properties without casting
    #expect(mapping["blue"]?.b == 255)
  }

  @Test("subscript returns typed optional")
  func subscriptReturnsTypedOptional() {
    let color: Color? = Colors["green"]
    #expect(color?.g == 255)
  }

  @Test("subscript returns nil for unknown key")
  func subscriptReturnsNilForUnknown() {
    let color: Color? = Colors["purple"]
    #expect(color == nil)
  }
}

// MARK: - Sequence Tests

@Suite("ExtensibleEnumSequence")
struct SequenceTests {

  @Test("all property returns iterable sequence")
  func allReturnsIterableSequence() {
    var count = 0
    for (key, value) in Colors.all {
      #expect(!key.isEmpty)
      #expect(value.r >= 0)
      count += 1
    }
    #expect(count == 4)
  }

  @Test("all.count returns correct count")
  func allCountReturnsCorrectCount() {
    #expect(Colors.all.count == 4)
  }

  @Test("all.keys returns sorted keys")
  func allKeysReturnsSortedKeys() {
    #expect(Colors.all.keys == ["blue", "green", "red", "yellow"])
  }

  @Test("all.values returns values in key order")
  func allValuesReturnsValuesInKeyOrder() {
    let values = Colors.all.values
    #expect(values.count == 4)
    // First value should be "blue" (alphabetically first)
    #expect(values[0].b == 255)
  }

  @Test("all supports filter")
  func allSupportsFilter() {
    let pureColors = Colors.all.filter { (_, color) in
      [color.r, color.g, color.b].filter { $0 == 255 }.count == 1
    }
    #expect(pureColors.count == 3) // red, green, blue (not yellow)
  }

  @Test("all supports map")
  func allSupportsMap() {
    let names = Colors.all.map { $0.key }
    #expect(names.count == 4)
    #expect(names.contains("red"))
  }
}

// MARK: - allCases Tests

@Suite("allCases")
struct AllCasesTests {

  @Test("allCases returns enum instances")
  func allCasesReturnsInstances() {
    let cases = Colors.allCases
    #expect(cases.count == 4)
  }

  @Test("allCases instances have correct values")
  func allCasesInstancesHaveCorrectValues() {
    let cases = Colors.allCases
    let redCase = cases.first { $0.caseName == "red" }
    #expect(redCase?.typedRawValue.r == 255)
  }
}

// MARK: - Block Enumeration Tests

@Suite("Block Enumeration")
struct BlockEnumerationTests {

  @Test("enumerateKeysAndValues iterates all cases")
  func enumerateKeysAndValuesIteratesAll() {
    var visited: [String] = []
    Colors.enumerateKeysAndValues { key, _, _ in
      visited.append(key)
    }
    #expect(visited.count == 4)
    #expect(visited.contains("red"))
  }

  @Test("enumerateKeysAndValues supports early exit")
  func enumerateKeysAndValuesSupportsEarlyExit() {
    var visited: [String] = []
    Colors.enumerateKeysAndValues { key, _, stop in
      visited.append(key)
      if visited.count == 2 {
        stop.pointee = true
      }
    }
    #expect(visited.count == 2)
  }

  @Test("enumerateValues iterates all values")
  func enumerateValuesIteratesAll() {
    var count = 0
    Colors.enumerateValues { _, _ in
      count += 1
    }
    #expect(count == 4)
  }

  @Test("enumerateValues supports early exit")
  func enumerateValuesSupportsEarlyExit() {
    var count = 0
    Colors.enumerateValues { _, stop in
      count += 1
      if count == 1 {
        stop.pointee = true
      }
    }
    #expect(count == 1)
  }
}

// MARK: - Extension Tests

@Suite("Extensibility")
struct ExtensibilityTests {

  @Test("extended cases are discoverable")
  func extendedCasesAreDiscoverable() {
    let keys = Colors.allKeys()
    #expect(keys.contains("yellow"))
  }

  @Test("extended cases have correct values")
  func extendedCasesHaveCorrectValues() {
    let yellow: Color? = Colors["yellow"]
    #expect(yellow?.r == 255)
    #expect(yellow?.g == 255)
    #expect(yellow?.b == 0)
  }
}
