import SwiftSyntax
import SwiftSyntaxMacros

public struct ExtensibleEnumerationMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {

    guard
      let argument = node.arguments?.as(LabeledExprListSyntax.self)?.first?.expression
    else {
      return []
    }

    let typeName = argument.description.replacingOccurrences(of: ".self", with: "").trimmingCharacters(in: .whitespaces)

    return [
      "public typealias RawValue = \(raw: typeName)",
      """
      public nonisolated required init?(rawValue: RawValue) {
        super.init(rawValue: rawValue)
      }

      public var typedRawValue: RawValue {
        return rawValue as! RawValue
      }

      /// Returns all values with concrete `RawValue` type.
      /// This shadows the base class `allValues() -> [Any]` when called from Swift.
      public static func allValues() -> [RawValue] {
        let untyped = (self as ExtensibleEnumProtocol.Type).allKeysAndValues()
        return untyped.keys.sorted().compactMap { untyped[$0] as? RawValue }
      }

      /// Returns all keys and values with concrete `RawValue` type.
      /// This shadows the base class `allKeysAndValues() -> [String: Any]` when called from Swift.
      public static func allKeysAndValues() -> [String: RawValue] {
        let untyped = (self as ExtensibleEnumProtocol.Type).allKeysAndValues()
        return untyped.compactMapValues { $0 as? RawValue }
      }

      /// Access a typed value by its case name.
      /// This shadows the base class subscript when called from Swift.
      public static subscript(key: String) -> RawValue? {
        return allKeysAndValues()[key]
      }

      /// Returns a typed sequence for functional iteration.
      /// This shadows the base class `all` when called from Swift.
      public static var all: ExtensibleEnumSequence<Self, RawValue> {
        return ExtensibleEnumSequence(keysAndValues: allKeysAndValues())
      }
      """
    ]
  }
}
