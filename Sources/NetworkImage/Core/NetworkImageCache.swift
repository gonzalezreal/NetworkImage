import CoreGraphics
import Foundation

/// Temporarily store images, keyed by their URL.
public struct NetworkImageCache {
  private let _image: (URL, CGFloat) -> PlatformImage?
  private let _setImage: (PlatformImage, URL, CGFloat) -> Void

  public init() {
    class Key: NSObject {
      let url: URL
      let scale: CGFloat

      init(_ url: URL, _ scale: CGFloat) {
        self.url = url
        self.scale = scale
      }

      override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Key else { return false }
        return url == other.url && scale == other.scale
      }

      override var hash: Int {
        return url.hashValue ^ scale.hashValue
      }
    }

    let nsCache = NSCache<Key, PlatformImage>()

    self.init(
      image: { url, scale in
        nsCache.object(forKey: Key(url, scale))
      },
      setImage: { image, url, scale in
        nsCache.setObject(image, forKey: Key(url, scale))
      }
    )
  }

  init(
    image: @escaping (URL, CGFloat) -> PlatformImage?,
    setImage: @escaping (PlatformImage, URL, CGFloat) -> Void
  ) {
    _image = image
    _setImage = setImage
  }

  /// Returns the image associated with a given URL.
  public func image(for url: URL, scale: CGFloat = 1) -> PlatformImage? {
    _image(url, scale)
  }

  /// Stores the image in the cache, associated with the specified URL.
  public func setImage(_ image: PlatformImage, for url: URL, scale: CGFloat = 1) {
    _setImage(image, url, scale)
  }
}

#if DEBUG
  extension NetworkImageCache {
    public static var noop: Self {
      Self(image: { _, _ in nil }, setImage: { _, _, _ in })
    }
  }
#endif
