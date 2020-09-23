#if canImport(Combine)
    import Combine
    import Foundation

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public final class ImagePrefetcher {
        private let session: URLSession
        private var cancellables: [URL: AnyCancellable] = [:]

        public init(session: URLSession = .imageLoading) {
            self.session = session
        }

        public func prefetchImages(with urls: Set<URL>) {
            assert(Thread.isMainThread)

            for url in urls where !cancellables.keys.contains(url) {
                cancellables[url] = session.dataTaskPublisher(for: url)
                    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            }
        }

        public func cancelPrefetchingImages(with urls: Set<URL>) {
            assert(Thread.isMainThread)

            for url in urls {
                cancellables.removeValue(forKey: url)
            }
        }
    }
#endif
