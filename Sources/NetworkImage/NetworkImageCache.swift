import Foundation

public protocol NetworkImageCache: AnyObject, Sendable {
  func image(for source: ImageSource) -> PlatformImage?

  func setImage(_ image: PlatformImage, for source: ImageSource)
}

// MARK: - DefaultNetworkImageCache

public class DefaultNetworkImageCache {
  private enum Constants {
    static let defaultCountLimit = 100
  }

  private let cache = NSCache<HashableBox<ImageSource>, PlatformImage>()

  public init(countLimit: Int = 0) {
    self.cache.countLimit = countLimit
  }

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
  static var `default`: Self {
    .shared
  }
}
