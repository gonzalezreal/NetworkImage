import Foundation

@available(*, unavailable, renamed: "NetworkImageCache")
public protocol ImageCache: AnyObject {
    func image(for url: URL) -> OSImage?
    func setImage(_ image: OSImage, for url: URL)
}

@available(*, unavailable, renamed: "NetworkImageCache")
public final class ImmediateImageCache: ImageCache {
    public func image(for _: URL) -> OSImage? {
        nil
    }

    public func setImage(_: OSImage, for _: URL) {}
}

#if canImport(Combine)
    import Combine

    @available(*, unavailable, renamed: "NetworkImageLoader")
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public final class ImageDownloader {
        public static let shared = ImageDownloader(
            session: .imageLoading,
            imageCache: ImmediateImageCache()
        )

        public init(session _: URLSession, imageCache _: ImageCache) {}

        public func image(for _: URL) -> AnyPublisher<OSImage, Error> {
            fatalError("Unavailable")
        }
    }
#endif

#if canImport(SwiftUI)
    import CombineSchedulers
    import SwiftUI

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public extension NetworkImage {
        @available(*, unavailable, renamed: "networkImageScheduler")
        func synchronous() -> NetworkImage {
            fatalError("Unavailable")
        }
    }
#endif
