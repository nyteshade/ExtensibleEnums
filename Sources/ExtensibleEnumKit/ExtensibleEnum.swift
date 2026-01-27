import Foundation

@objc
open class ExtensibleEnum: NSObject {
  public let rawValue: Any

  @objc public nonisolated required init?(rawValue: Any) {
    self.rawValue = rawValue
    super.init()
  }
}
