#if canImport(Combine)
    import Combine
    import CombineSchedulers
    import Foundation

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    internal final class NetworkImageStore: ObservableObject {
        enum State: Equatable {
            case placeholder
            case image(OSImage)
            case fallback
        }

        struct Environment {
            static let `default` = Environment(
                image: ImageDownloader.shared.image(for:),
                scheduler: DispatchQueue.main.eraseToAnyScheduler()
            )

            static let synchronous = Environment(
                image: { url in
                    Result {
                        try decodeImage(from: Data(contentsOf: url))
                    }
                    .publisher
                    .eraseToAnyPublisher()
                },
                scheduler: .immediate
            )

            let image: (URL) -> AnyPublisher<OSImage, Error>
            let scheduler: AnySchedulerOf<DispatchQueue>

            init(
                image: @escaping (URL) -> AnyPublisher<OSImage, Error>,
                scheduler: AnySchedulerOf<DispatchQueue>
            ) {
                self.image = image
                self.scheduler = scheduler
            }
        }

        @Published private(set) var state: State
        private let url: URL?

        init(url: URL?, environment: Environment = .default) {
            self.url = url

            if let url = url {
                state = .placeholder

                environment.image(url)
                    .map { .image($0) }
                    .replaceError(with: .fallback)
                    .receive(on: environment.scheduler)
                    .assign(to: &$state)
            } else {
                state = .fallback
            }
        }

        func synchronous() -> NetworkImageStore {
            NetworkImageStore(url: url, environment: .synchronous)
        }
    }
#endif
