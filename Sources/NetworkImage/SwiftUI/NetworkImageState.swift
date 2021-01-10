#if canImport(SwiftUI)

    import SwiftUI

    /// The state of a network image.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public enum NetworkImageState {
        /// The image is loading.
        case loading

        /// The image is ready.
        ///
        /// As associated values, this case contains the `Image`
        /// and its size.
        case image(Image, size: CGSize)

        /// The image could not be loaded or the given URL is `nil`.
        case failed
    }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    internal extension NetworkImageState {
        init(state: NetworkImageStore.State) {
            switch state {
            case .notRequested, .loading:
                self = .loading
            case let .image(_, osImage):
                self = .image(Image(osImage: osImage), size: osImage.size)
            case .failed:
                self = .failed
            }
        }
    }

#endif
