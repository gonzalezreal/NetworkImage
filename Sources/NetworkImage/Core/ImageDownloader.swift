//
// ImageDownloader.swift
//
// Copyright (c) 2020 Guille Gonzalez
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
