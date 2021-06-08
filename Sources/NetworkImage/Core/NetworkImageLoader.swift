#if canImport(Combine)
    import Combine
    import Foundation
    import XCTestDynamicOverlay

    /// Loads and caches images.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public struct NetworkImageLoader {
        private let _image: (URL) -> AnyPublisher<OSImage, Error>

        /// Creates an image loader.
        /// - Parameters:
        ///   - urlSession: The `URLSession` that will load the images.
        ///   - imageCache: An immediate cache to store the images in memory.
        public init(urlSession: URLSession, imageCache: NetworkImageCache) {
            self.init(urlLoader: URLLoader(urlSession: urlSession), imageCache: imageCache)
        }

        init(urlLoader: URLLoader, imageCache: NetworkImageCache) {
            self.init { url in
                if let image = imageCache.image(for: url) {
                    return Just(image)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return urlLoader.dataTaskPublisher(for: url)
                        .tryMap { data, response in
                            if let httpResponse = response as? HTTPURLResponse {
                                guard 200 ..< 300 ~= httpResponse.statusCode else {
                                    throw NetworkImageError.badStatus(httpResponse.statusCode)
                                }
                            }

                            return try decodeImage(from: data)
                        }
                        .handleEvents(receiveOutput: { image in
                            imageCache.setImage(image, for: url)
                        })
                        .eraseToAnyPublisher()
                }
            }
        }

        init(image: @escaping (URL) -> AnyPublisher<OSImage, Error>) {
            _image = image
        }

        /// Returns a publisher that loads an image for a given URL.
        public func image(for url: URL) -> AnyPublisher<OSImage, Error> {
            _image(url)
        }
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public extension NetworkImageLoader {
        /// The shared singleton image loader.
        ///
        /// The shared image loader uses the shared `URLCache` and provides
        /// reasonable defaults for disk and memory caches.
        static let shared = Self(urlSession: .imageLoading, imageCache: NetworkImageCache())
    }

    #if DEBUG
        @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
        public extension NetworkImageLoader {
            static func mock<P>(
                url matchingURL: URL,
                withResponse response: P
            ) -> Self where P: Publisher, P.Output == OSImage, P.Failure == Error {
                Self { url in
                    if url != matchingURL {
                        XCTFail("\(Self.self).image recevied an unexpected URL: \(url)")
                    }

                    return response.eraseToAnyPublisher()
                }
            }

            static func mock<P>(
                response: P
            ) -> Self where P: Publisher, P.Output == OSImage, P.Failure == Error {
                Self { _ in response.eraseToAnyPublisher() }
            }

            static var failing: Self {
                Self { _ in
                    XCTFail("\(Self.self).image is unimplemented")
                    return Just(OSImage())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
        }
    #endif
#endif
