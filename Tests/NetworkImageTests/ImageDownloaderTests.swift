#if canImport(Combine)
    import Combine
    import XCTest

    @testable import NetworkImage

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    final class ImageDownloaderTests: XCTestCase {
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
                        data: Fixtures.anyImageResponse,
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
