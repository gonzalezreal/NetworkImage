import Foundation

/// A type that temporarily stores images in memory, keyed by their ``ImageSource`` value.
public protocol NetworkImageCache: AnyObject, Sendable {
  /// Returns the image associated with a given source.
  func image(for source: ImageSource) -> PlatformImage?

  /// Sets the image of the specified source in the cache.
  func setImage(_ image: PlatformImage, for source: ImageSource)
}

// MARK: - DefaultNetworkImageCache

/// The default network image cache.
public class DefaultNetworkImageCache {
  private enum Constants {
    static let defaultCountLimit = 100
  }

  private let cache = NSCache<HashableBox<ImageSource>, PlatformImage>()

  /// Creates a default network image cache.
  /// - Parameter countLimit: The maximum number of images that the cache should hold. If `0`,
  ///                         there is no count limit. The default value is `0`.
  public init(countLimit: Int = 0) {
    self.cache.countLimit = countLimit
  }

  /// A shared network image cache.
  public static let shared = DefaultNetworkImageCache(countLimit: Constants.defaultCountLimit)
}

extension DefaultNetworkImageCache: NetworkImageCache, @unchecked Sendable {
  public func image(for source: ImageSource) -> PlatformImage? {
    self.cache.object(forKey: .init(source))
  }

  public func setImage(_ image: PlatformImage, for source: ImageSource) {
    self.cache.setObject(image, forKey: .init(source))
  }
}

extension NetworkImageCache where Self == DefaultNetworkImageCache {
  /// The shared default network image cache.
  static var `default`: Self {
    .shared
  }
}
