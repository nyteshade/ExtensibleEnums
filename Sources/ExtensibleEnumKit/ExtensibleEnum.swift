import Foundation

@objc @objcMembers
open class ExtensibleEnum: NSObject, RawRepresentable {
  public let rawValue: RawValue

  public required init?(rawValue: Any) {
    self.rawValue = rawValue
    super.init()
  }
}
