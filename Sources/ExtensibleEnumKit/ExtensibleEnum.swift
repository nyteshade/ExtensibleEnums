import Foundation

@objc @objcMembers
open class ExtensibleEnum: NSObject {
  public let rawValue: Any

  public required init?(rawValue: Any) {
    self.rawValue = rawValue
    super.init()
  }
}
