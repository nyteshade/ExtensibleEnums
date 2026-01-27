@attached(member, names: named(RawValue), named(rawValue), named(init))
public macro Extensible<T>(_ type: T.Type) = #externalMacro(module: "ExtensibleEnumMacros", type: "ExtensibleEnumMacro")
