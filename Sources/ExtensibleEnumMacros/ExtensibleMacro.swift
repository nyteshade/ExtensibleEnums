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
        let keysAndValues = allTypedKeysAndValues()
        return keysAndValues.keys.sorted().compactMap { keysAndValues[$0] }
      }

      /// Returns all keys and values with concrete `RawValue` type.
      /// This shadows the base class `allKeysAndValues() -> [String: Any]` when called from Swift.
      public static func allKeysAndValues() -> [String: RawValue] {
        return allTypedKeysAndValues()
      }

      /// Returns the complete mapping with concrete value types.
      public static func allTypedKeysAndValues() -> [String: RawValue] {
        // Runtime introspection, then cast values
        let untyped = (self as ExtensibleEnumProtocol.Type).allKeysAndValues()
        return untyped.compactMapValues { $0 as? RawValue }
      }
      """
    ]
  }
}
