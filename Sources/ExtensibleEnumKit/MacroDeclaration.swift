@attached(member, names: named(RawValue), named(rawValue), named(init))
public macro ExtensibleEnumeration<T>(_ type: T.Type) = #externalMacro(
    module: "ExtensibleEnumMacros",     // This must match the 'macro.name' in Package.swift targets
    type: "ExtensibleEnumerationMacro"  // This must match the 'struct' name in your Plugin list
)
