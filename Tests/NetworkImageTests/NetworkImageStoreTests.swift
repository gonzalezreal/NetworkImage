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
            static let anyImage = OSImage()
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
                    .failed,
                    .loading,
                    .failed,
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
                    .failed,
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
        var successfulImage: (URL?) -> AnyPublisher<OSImage, Error> {
            { _ in
                Just(Fixtures.anyImage)
                    .delay(for: .seconds(1), scheduler: self.scheduler)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }

        var failedImage: (URL?) -> AnyPublisher<OSImage, Error> {
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
