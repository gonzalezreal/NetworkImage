#if canImport(SwiftUI)

    import SwiftUI

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public enum NetworkImageConfiguration {
        case loading
        case image(Image, size: CGSize)
        case failed
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    internal extension NetworkImageConfiguration {
        init(state: NetworkImageStore.State) {
            switch state {
            case .notRequested, .loading:
                self = .loading
            case let .image(osImage, _):
                self = .image(Image(osImage: osImage), size: osImage.size)
            case .failed:
                self = .failed
            }
        }
    }

#endif
