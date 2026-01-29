import Foundation

@objc
open class ExtensibleEnum: NSObject {
  public var rawValue: Any

  public nonisolated init?(rawValue: Any) {
    self.rawValue = rawValue
    super.init()
  }
}
