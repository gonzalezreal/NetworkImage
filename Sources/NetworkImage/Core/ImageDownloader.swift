#if canImport(Combine)
    import Combine
    import Foundation

    /// An object that downloads and caches images.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public final class ImageDownloader {
        private let data: (URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
        private let imageCache: ImageCache

        /// The shared singleton image downloader.
        ///
        /// The shared image downloader uses the shared `URLCache` and provides
        /// reasonable defaults for disk and memory caches.
        public static let shared = ImageDownloader(
            session: .imageLoading,
            imageCache: ImmediateImageCache()
        )

        /// Creates an image downloader.
        /// - Parameters:
        ///   - session: The `URLSession` that will download the images.
        ///   - imageCache: An immediate cache to store the images in memory.
        public convenience init(session: URLSession, imageCache: ImageCache) {
            self.init(
                data: {
                    session.dataTaskPublisher(for: $0)
                        .eraseToAnyPublisher()
                },
                imageCache: imageCache
            )
        }

        internal init(
            data: @escaping (URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>,
            imageCache: ImageCache
        ) {
            self.data = data
            self.imageCache = imageCache
        }

        /// Returns a publisher that wraps an image download for a given URL.
        public func image(for url: URL) -> AnyPublisher<OSImage, Error> {
            if let image = imageCache.image(for: url) {
                return Just(image)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                return data(url)
                    .tryMap { [imageCache] data, response in
                        if let httpResponse = response as? HTTPURLResponse {
                            guard 200 ..< 300 ~= httpResponse.statusCode else {
                                throw NetworkImageError.badStatus(httpResponse.statusCode)
                            }
                        }

                        let image = try decodeImage(from: data)
                        imageCache.setImage(image, for: url)

                        return image
                    }
                    .eraseToAnyPublisher()
            }
        }
    }
#endif
