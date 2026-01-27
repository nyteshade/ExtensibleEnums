import Foundation

@objc @objcMembers
open class ExtensibleEnum: NSObject {
  public var rawValue: Any

  public init?(rawValue: Any) {
    self.rawValue = rawValue
    super.init()
  }
}
