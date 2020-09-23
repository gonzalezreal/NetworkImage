#if canImport(Combine)
    import Combine
    import Foundation

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public final class ImageDownloader {
        private let data: (URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
        private let imageCache: ImageCache

        public static let shared = ImageDownloader(
            session: .imageLoading,
            imageCache: ImmediateImageCache()
        )

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
