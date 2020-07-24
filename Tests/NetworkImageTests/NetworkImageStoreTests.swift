//
// NetworkImageStoreTests.swift
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
    import CombineSchedulers
    import XCTest

    @testable import NetworkImage

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    final class NetworkImageStoreTests: XCTestCase {
        enum Fixtures {
            static let anyError = NetworkImageError.badStatus(500)
            static let anyURL = URL(string: "https://example.com/anyImage.jpg")!
            static let anyOtherURL = URL(string: "https://example.com/anyOtherImage.jpg")!
            static let anyImage = Image()
        }

        private let scheduler = DispatchQueue.testScheduler
        private var cancellables = Set<AnyCancellable>()

        override func tearDownWithError() throws {
            cancellables.removeAll()
        }

        func testDidSetURLToNil() {
            // given
            let sut = NetworkImageStore(
                environment: NetworkImageStore.Environment(
                    image: successfulImage,
                    currentTime: incrementingCurrentTime,
                    scheduler: scheduler.eraseToAnyScheduler()
                )
            )
            var result: [NetworkImageStore.State] = []

            sut.$state
                .sink { result.append($0) }
                .store(in: &cancellables)

            // when
            sut.send(.didSetURL(nil))
            sut.send(.didSetURL(Fixtures.anyURL))
            sut.send(.didSetURL(nil))
            scheduler.run()

            // then
            XCTAssertEqual(
                [
                    .notRequested,
                    .placeholder,
                    .loading,
                    .placeholder,
                ],
                result
            )
        }

        func testDidSetURL() {
            // given
            let sut = NetworkImageStore(
                environment: NetworkImageStore.Environment(
                    image: successfulImage,
                    currentTime: incrementingCurrentTime,
                    scheduler: scheduler.eraseToAnyScheduler()
                )
            )
            var result: [NetworkImageStore.State] = []

            sut.$state
                .sink { result.append($0) }
                .store(in: &cancellables)

            // when
            sut.send(.didSetURL(Fixtures.anyURL))
            sut.send(.didSetURL(Fixtures.anyOtherURL))
            scheduler.run()

            // then
            XCTAssertEqual(
                [
                    .notRequested,
                    .loading,
                    .loading,
                    .image(Fixtures.anyImage, elapsedTime: 2),
                ],
                result
            )
        }

        func testDidFail() {
            // given
            let sut = NetworkImageStore(
                environment: NetworkImageStore.Environment(
                    image: failedImage,
                    currentTime: incrementingCurrentTime,
                    scheduler: scheduler.eraseToAnyScheduler()
                )
            )
            var result: [NetworkImageStore.State] = []

            sut.$state
                .sink { result.append($0) }
                .store(in: &cancellables)

            // when
            sut.send(.didSetURL(Fixtures.anyURL))
            scheduler.run()

            // then
            XCTAssertEqual(
                [
                    .notRequested,
                    .loading,
                    .placeholder,
                ],
                result
            )
        }

        func testPrepareForReuse() {
            // given
            let sut = NetworkImageStore(
                environment: NetworkImageStore.Environment(
                    image: successfulImage,
                    currentTime: incrementingCurrentTime,
                    scheduler: scheduler.eraseToAnyScheduler()
                )
            )
            var result: [NetworkImageStore.State] = []

            sut.$state
                .sink { result.append($0) }
                .store(in: &cancellables)

            // when
            sut.send(.didSetURL(Fixtures.anyURL))
            sut.send(.prepareForReuse)
            scheduler.run()

            // then
            XCTAssertEqual(
                [
                    .notRequested,
                    .loading,
                    .notRequested,
                ],
                result
            )
        }
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private extension NetworkImageStoreTests {
        var successfulImage: (URL?) -> AnyPublisher<Image, Error> {
            { _ in
                Just(Fixtures.anyImage)
                    .delay(for: .seconds(1), scheduler: self.scheduler)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }

        var failedImage: (URL?) -> AnyPublisher<Image, Error> {
            { _ in
                Fail(error: Fixtures.anyError)
                    .delay(for: .seconds(1), scheduler: self.scheduler)
                    .eraseToAnyPublisher()
            }
        }

        var incrementingCurrentTime: () -> Double {
            var start = 0.0
            return {
                defer { start += 1 }
                return start
            }
        }
    }
#endif
