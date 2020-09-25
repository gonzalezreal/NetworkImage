import Foundation

/// An object that can temporarily store images, keyed by their URL.
///
/// Any class implementing this protocol must allow adding and querying images from different threads.
public protocol ImageCache: AnyObject {
    /// Returns the image associated with a given URL.
    func image(for url: URL) -> OSImage?

    /// Stores the image in the cache, associated with the specified URL.
    func setImage(_ image: OSImage, for url: URL)
}
