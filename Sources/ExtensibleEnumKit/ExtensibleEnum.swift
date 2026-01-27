import Foundation

@objc @objcMembers
open class ExtensibleEnum: NSObject {
  public let rawValue: Any

  // Must be open so subclasses can be instantiated by the system
  public required init?(rawValue: Any) {
    self.rawValue = rawValue
    super.init()
  }
}
