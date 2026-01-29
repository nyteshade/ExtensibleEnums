@attached(member, names: named(RawValue), named(init), named(typedRawValue), named(allValues), named(allKeysAndValues), named(subscript), named(all))
public macro ExtensibleEnumeration<T>(_ type: T.Type) = #externalMacro(
    module: "ExtensibleEnumMacros",
    type: "ExtensibleEnumerationMacro"
)
