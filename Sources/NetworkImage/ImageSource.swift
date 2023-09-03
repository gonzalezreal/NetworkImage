import Foundation

/// A type that represents the source of an image.
public struct ImageSource: Hashable {
  /// The URL for the image.
  public let url: URL

  /// The scale of the image.
  public let scale: CGFloat

  /// Creates an image source.
  /// - Parameters:
  ///   - url: The URL for the image.
  ///   - scale: The scale of the image.
  public init(url: URL, scale: CGFloat = 1) {
    self.url = url
    self.scale = scale
  }
}
