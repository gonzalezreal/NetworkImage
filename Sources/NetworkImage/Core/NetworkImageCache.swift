import Foundation

/// Temporarily store images, keyed by their URL.
public struct NetworkImageCache {
  private let _image: (URL) -> OSImage?
  private let _setImage: (OSImage, URL) -> Void

  public init(nsCache: NSCache<NSURL, OSImage> = NSCache()) {
    self.init(
      image: { url in
        nsCache.object(forKey: url as NSURL)
      },
      setImage: { image, url in
        nsCache.setObject(image, forKey: url as NSURL)
      }
    )
  }

  init(image: @escaping (URL) -> OSImage?, setImage: @escaping (OSImage, URL) -> Void) {
    _image = image
    _setImage = setImage
  }

  /// Returns the image associated with a given URL.
  public func image(for url: URL) -> OSImage? {
    _image(url)
  }

  /// Stores the image in the cache, associated with the specified URL.
  public func setImage(_ image: OSImage, for url: URL) {
    _setImage(image, url)
  }
}

#if DEBUG
  extension NetworkImageCache {
    public static var noop: Self {
      Self(image: { _ in nil }, setImage: { _, _ in })
    }
  }
#endif
