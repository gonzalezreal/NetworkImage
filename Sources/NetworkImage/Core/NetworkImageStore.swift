#if canImport(Combine)
    import Combine
    import CombineSchedulers
    import Foundation

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    internal struct NetworkImageEnvironment {
        var imageLoader: NetworkImageLoader
        var mainQueue: AnySchedulerOf<DispatchQueue>
    }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    internal final class NetworkImageStore: ObservableObject {
        enum State: Equatable {
            case placeholder
            case image(OSImage)
            case fallback
        }

        @Published private(set) var state: State

        init(url: URL?, environment: NetworkImageEnvironment) {
            if let url = url {
                if let image = environment.imageLoader.cachedImage(for: url) {
                    state = .image(image)
                } else {
                    state = .placeholder

                    environment.imageLoader.image(for: url)
                        .map { .image($0) }
                        .replaceError(with: .fallback)
                        .receive(on: environment.mainQueue)
                        .assign(to: &$state)
                }
            } else {
                state = .fallback
            }
        }
    }
#endif
