import Foundation

public protocol ImageCache: AnyObject {
    func image(for url: URL) -> OSImage?
    func setImage(_ image: OSImage, for url: URL)
}
