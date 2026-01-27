import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ExtensibleEnumPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    ExtensibleEnumMacro.self
    // If you add @StringIterable later, you'd add it here too
  ]
}
