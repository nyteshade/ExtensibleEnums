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
      "  public typealias RawValue = \(raw: typeName)",
      """
        public required init?(rawValue: RawValue) {
          self.rawValue = rawValue
          super.init(rawValue: rawValue)
        }
      """
    ]
  }
}
