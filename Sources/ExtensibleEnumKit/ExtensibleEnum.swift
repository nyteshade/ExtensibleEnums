import Foundation

@objc
open class ExtensibleEnum: NSObject {
  @objc public var rawValue: Any

  @objc static func allKeys() -> [String] { [ ] }
  @objc static func allValues() -> [Any] { [ ] }
  @objc static func allKeysAndValues() -> [String: Any] { [:] }

  override public nonisolated init() {
    rawValue = NSNull()
    super.init()
  }
}
