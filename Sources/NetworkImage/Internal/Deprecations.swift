import Combine
import Foundation

// NB: Deprecated in 3.1.3

extension NetworkImageCache {
  @available(
    *, deprecated,
    message: "NetworkImageCache no longer supports providing a NSCache in the initializer"
  )
  public init(nsCache: NSCache<NSURL, OSImage> = NSCache()) {
    self.init(
      image: { url, _ in
        nsCache.object(forKey: url as NSURL)
      },
      setImage: { image, url, _ in
        nsCache.setObject(image, forKey: url as NSURL)
      }
    )
  }
}
