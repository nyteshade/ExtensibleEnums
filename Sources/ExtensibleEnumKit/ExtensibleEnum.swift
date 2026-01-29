import Foundation

@objc
open class ExtensibleEnum: NSObject {
  @objc public var rawValue: Any

  override public nonisolated init() {
    rawValue = NSNull()
    super.init()
  }
}
