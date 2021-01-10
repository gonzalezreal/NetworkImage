#if canImport(Combine)
    import Combine
    import CombineSchedulers
    import Foundation

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    internal final class NetworkImageStore: ObservableObject {
        enum State: Equatable {
            case notRequested
            case loading(URL)
            case image(URL, OSImage)
            case failed

            var url: URL? {
                switch self {
                case let .loading(url):
                    return url
                case let .image(url, _):
                    return url
                case .notRequested, .failed:
                    return nil
                }
            }
        }

        enum Action {
            case onAppear(URL?)
            case didLoadImage(URL, OSImage)
            case didFail
        }

        struct Environment {
            static let asynchronous = Environment(
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
                scheduler: DispatchQueue.immediateScheduler.eraseToAnyScheduler()
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

        @Published private(set) var state: State = .notRequested

        private let environment: Environment
        private var cancellable: AnyCancellable?

        init(environment: Environment) {
            self.environment = environment
        }

        func send(_ action: Action) {
            switch action {
            case .onAppear(.none):
                state = .failed
                cancellable?.cancel()
            case let .onAppear(.some(url)):
                guard url != state.url else { return }
                state = .loading(url)
                cancellable = environment.image(url)
                    .map { .didLoadImage(url, $0) }
                    .replaceError(with: .didFail)
                    .receive(on: environment.scheduler)
                    .sink(receiveValue: { [weak self] action in
                        self?.send(action)
                    })
            case let .didLoadImage(url, image):
                state = .image(url, image)
            case .didFail:
                state = .failed
            }
        }
    }
#endif
