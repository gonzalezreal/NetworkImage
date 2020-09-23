//
// ImageDownloaderTests.swift
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
    import XCTest

    @testable import NetworkImage

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    final class ImageDownloaderTests: XCTestCase {
        enum Fixtures {
            static let anyImageURL = URL(string: "https://example.com/dot.png")!
            static let anyImage = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==")!
            static let anyResponse = Data(base64Encoded: "Z29uemFsZXpyZWFs")!
        }

        private var cancellables = Set<AnyCancellable>()

        override func tearDownWithError() throws {
            cancellables.removeAll()
        }

        func testAnyImageResponseReturnsImage() {
            // given
            let sut = ImageDownloader(
                data: anyImageResponse,
                imageCache: DisabledImageCache()
            )
            var result: OSImage?

            // when
            sut.image(for: Fixtures.anyImageURL)
                .assertNoFailure()
                .sink(receiveValue: {
                    result = $0
                })
                .store(in: &cancellables)

            // then
            XCTAssertNotNil(result)
        }

        func testBadStatusResponseFailsWithBadStatusError() {
            // given
            let sut = ImageDownloader(
                data: badStatusResponse,
                imageCache: DisabledImageCache()
            )
            var result: Error?

            // when
            sut.image(for: Fixtures.anyImageURL)
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            result = error
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)

            // then
            XCTAssertEqual(result as? NetworkImageError, .badStatus(500))
        }

        func testAnyResponseFailsWithInvalidDataError() {
            // given
            let sut = ImageDownloader(
                data: anyResponse,
                imageCache: DisabledImageCache()
            )
            var result: Error?

            // when
            sut.image(for: Fixtures.anyImageURL)
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            result = error
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)

            // then
            XCTAssertEqual(result as? NetworkImageError, .invalidData(Fixtures.anyResponse))
        }
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private extension ImageDownloaderTests {
        class DisabledImageCache: ImageCache {
            func image(for _: URL) -> OSImage? { nil }
            func setImage(_: OSImage, for _: URL) {}
        }

        var anyImageResponse: (URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
            { url in
                Just(
                    (
                        data: Fixtures.anyImage,
                        response: HTTPURLResponse(
                            url: url,
                            statusCode: 200,
                            httpVersion: "HTTP/1.1",
                            headerFields: nil
                        )!
                    )
                )
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
            }
        }

        var badStatusResponse: (URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
            { url in
                Just(
                    (
                        data: Data(),
                        response: HTTPURLResponse(
                            url: url,
                            statusCode: 500,
                            httpVersion: "HTTP/1.1",
                            headerFields: nil
                        )!
                    )
                )
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
            }
        }

        var anyResponse: (URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
            { url in
                Just(
                    (
                        data: Fixtures.anyResponse,
                        response: HTTPURLResponse(
                            url: url,
                            statusCode: 200,
                            httpVersion: "HTTP/1.1",
                            headerFields: nil
                        )!
                    )
                )
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
            }
        }
    }
#endif
