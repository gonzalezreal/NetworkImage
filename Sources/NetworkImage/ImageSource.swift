import Foundation

public struct ImageSource: Hashable {
  public let url: URL
  public let scale: CGFloat

  public init(url: URL, scale: CGFloat = 1) {
    self.url = url
    self.scale = scale
  }
}
