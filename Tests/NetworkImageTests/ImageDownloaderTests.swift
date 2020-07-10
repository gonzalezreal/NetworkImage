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

#if canImport(UIKit) && canImport(Combine)
    import Combine
    import UIKit
    import XCTest

    import NetworkImage

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    final class ImageDownloaderTests: XCTestCase {
        enum Fixtures {
            static let anyImageURL = URL(string: "https://example.com/dot.png")!
            static let anyDataImageURL = URL(string: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==")!
            static let anyImage = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==")!
            static let anyResponse = Data(base64Encoded: "Z29uemFsZXpyZWFs")!
        }

        private var sut: ImageDownloader!
        private var cancellables = Set<AnyCancellable>()

        override func setUp() {
            super.setUp()

            sut = ImageDownloader(session: .stubbed, imageCache: DisabledImageCache())
        }

        override func tearDown() {
            HTTPStubProtocol.removeAllStubs()
            super.tearDown()
        }

        func testAnyImageResponseReturnsImage() {
            // given
            givenAnyImageResponse()
            let didReceiveValue = expectation(description: "didReceiveValue")
            var result: UIImage?

            // when
            sut.image(for: Fixtures.anyImageURL)
                .assertNoFailure()
                .sink(receiveValue: {
                    result = $0
                    didReceiveValue.fulfill()
                })
                .store(in: &cancellables)

            // then
            wait(for: [didReceiveValue], timeout: 1)
            XCTAssertNotNil(result)
        }

        func testBadStatusResponseFailsWithBadStatusError() {
            // given
            givenBadStatusResponse()
            let didFail = expectation(description: "didFail")
            var result: Error?

            // when
            sut.image(for: Fixtures.anyImageURL)
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            result = error
                            didFail.fulfill()
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)

            // then
            wait(for: [didFail], timeout: 1)
            XCTAssertEqual(result as? NetworkImageError, .badStatus(500))
        }

        func testAnyResponseFailsWithInvalidDataError() {
            // given
            givenAnyResponse()
            let didFail = expectation(description: "didFail")
            var result: Error?

            // when
            sut.image(for: Fixtures.anyImageURL)
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            result = error
                            didFail.fulfill()
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)

            // then
            wait(for: [didFail], timeout: 1)
            XCTAssertEqual(result as? NetworkImageError, .invalidData(Fixtures.anyResponse))
        }

        func testAnyDataImageURLReturnsImage() {
            // given
            let didReceiveValue = expectation(description: "didReceiveValue")
            var result: UIImage?

            // when
            sut.image(for: Fixtures.anyDataImageURL)
                .assertNoFailure()
                .sink(receiveValue: {
                    result = $0
                    didReceiveValue.fulfill()
                })
                .store(in: &cancellables)

            // then
            wait(for: [didReceiveValue], timeout: 1)
            XCTAssertNotNil(result)
        }
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private extension ImageDownloaderTests {
        class DisabledImageCache: ImageCache {
            func image(for _: URL) -> UIImage? {
                nil
            }

            func setImage(_: UIImage, for _: URL) {}
        }

        func givenAnyImageResponse() {
            let request = URLRequest(url: Fixtures.anyImageURL)
            HTTPStubProtocol.stubRequest(request, data: Fixtures.anyImage, statusCode: 200)
        }

        func givenBadStatusResponse() {
            let request = URLRequest(url: Fixtures.anyImageURL)
            HTTPStubProtocol.stubRequest(request, data: Data(), statusCode: 500)
        }

        func givenAnyResponse() {
            let request = URLRequest(url: Fixtures.anyImageURL)
            HTTPStubProtocol.stubRequest(request, data: Fixtures.anyResponse, statusCode: 200)
        }
    }
#endif
