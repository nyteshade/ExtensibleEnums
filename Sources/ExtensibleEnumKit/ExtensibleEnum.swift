import Foundation

@objc
open class ExtensibleEnum: NSObject {
  public var rawValue: Any

  @objc public nonisolated init?(rawValue: Any) {
    self.rawValue = rawValue
    super.init()
  }
}
