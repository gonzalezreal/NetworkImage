import Foundation

public final class ImmediateImageCache: ImageCache {
    private let cache = NSCache<NSURL, OSImage>()

    public func image(for url: URL) -> OSImage? {
        cache.object(forKey: url as NSURL)
    }

    public func setImage(_ image: OSImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}
