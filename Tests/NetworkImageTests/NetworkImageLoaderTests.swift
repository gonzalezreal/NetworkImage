#if canImport(Combine)
    import Combine
    import XCTest

    @testable import NetworkImage

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    final class NetworkImageLoaderTests: XCTestCase {
        private var cancellables = Set<AnyCancellable>()

        override func tearDownWithError() throws {
            cancellables.removeAll()
        }

        func testImageLoadsAndCachesImage() throws {
            // given
            let imageCache = NetworkImageCache()
            let imageLoader = NetworkImageLoader(
                urlLoader: .mock(
                    url: Fixtures.anyImageURL,
                    withResponse: Just(
                        (
                            data: Fixtures.anyImageResponse,
                            response: HTTPURLResponse(
                                url: Fixtures.anyImageURL,
                                statusCode: 200,
                                httpVersion: "HTTP/1.1",
                                headerFields: nil
                            )!
                        )
                    )
                    .setFailureType(to: URLError.self)
                ),
                imageCache: imageCache
            )

            // when
            var result: OSImage?
            imageLoader.image(for: Fixtures.anyImageURL)
                .assertNoFailure()
                .sink(receiveValue: {
                    result = $0
                })
                .store(in: &cancellables)

            // then
            let unwrappedResult = try XCTUnwrap(result)
            XCTAssertTrue(unwrappedResult.isEqual(imageCache.image(for: Fixtures.anyImageURL)))
            XCTAssertTrue(unwrappedResult.isEqual(imageLoader.cachedImage(for: Fixtures.anyImageURL)))
        }

        func testImageReturnsCachedImageIfAvailable() throws {
            // given
            let imageCache = NetworkImageCache()
            let imageLoader = NetworkImageLoader(urlLoader: .failing, imageCache: imageCache)
            imageCache.setImage(Fixtures.anyImage, for: Fixtures.anyImageURL)

            // when
            var result: OSImage?
            imageLoader.image(for: Fixtures.anyImageURL)
                .assertNoFailure()
                .sink(receiveValue: {
                    result = $0
                })
                .store(in: &cancellables)

            // then
            let unwrappedResult = try XCTUnwrap(result)
            XCTAssertTrue(unwrappedResult.isEqual(Fixtures.anyImage))
        }

        func testImageFailsWithBadStatusError() throws {
            // given
            let imageLoader = NetworkImageLoader(
                urlLoader: .mock(
                    url: Fixtures.anyImageURL,
                    withResponse: Just(
                        (
                            data: .init(),
                            response: HTTPURLResponse(
                                url: Fixtures.anyImageURL,
                                statusCode: 500,
                                httpVersion: "HTTP/1.1",
                                headerFields: nil
                            )!
                        )
                    )
                    .setFailureType(to: URLError.self)
                ),
                imageCache: .noop
            )

            // when
            var result: Error?
            imageLoader.image(for: Fixtures.anyImageURL)
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
            let unwrappedResult = try XCTUnwrap(result as? NetworkImageError)
            XCTAssertEqual(unwrappedResult, .badStatus(500))
        }

        func testImageFailsWithInvalidDataError() throws {
            // given
            let imageLoader = NetworkImageLoader(
                urlLoader: .mock(
                    url: Fixtures.anyImageURL,
                    withResponse: Just(
                        (
                            data: Fixtures.anyResponse,
                            response: HTTPURLResponse(
                                url: Fixtures.anyImageURL,
                                statusCode: 200,
                                httpVersion: "HTTP/1.1",
                                headerFields: nil
                            )!
                        )
                    )
                    .setFailureType(to: URLError.self)
                ),
                imageCache: .noop
            )

            // when
            var result: Error?
            imageLoader.image(for: Fixtures.anyImageURL)
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
            let unwrappedResult = try XCTUnwrap(result as? NetworkImageError)
            XCTAssertEqual(unwrappedResult, .invalidData(Fixtures.anyResponse))
        }
    }
#endif
