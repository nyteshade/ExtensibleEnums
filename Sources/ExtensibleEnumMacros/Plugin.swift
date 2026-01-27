import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ExtensibleEnumPlugin: CompilerPlugin {
    // This list tells the compiler which Macro classes are available in this binary
    let providingMacros: [Macro.Type] = [
        ExtensibleEnumerationMacro.self
    ]
}
