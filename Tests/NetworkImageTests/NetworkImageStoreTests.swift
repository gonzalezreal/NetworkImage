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
                    scheduler: scheduler.eraseToAnyScheduler()
                )
            )
            var result: [NetworkImageStore.State] = []

            sut.$state
                .sink { result.append($0) }
                .store(in: &cancellables)

            // when
            sut.send(.onAppear(nil))
            sut.send(.onAppear(Fixtures.anyURL))
            sut.send(.onAppear(nil))
            scheduler.run()

            // then
            XCTAssertEqual(
                [
                    .notRequested,
                    .failed,
                    .loading(Fixtures.anyURL),
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
                    scheduler: scheduler.eraseToAnyScheduler()
                )
            )
            var result: [NetworkImageStore.State] = []

            sut.$state
                .sink { result.append($0) }
                .store(in: &cancellables)

            // when
            sut.send(.onAppear(Fixtures.anyURL))
            sut.send(.onAppear(Fixtures.anyURL))
            sut.send(.onAppear(Fixtures.anyOtherURL))
            scheduler.run()

            // then
            XCTAssertEqual(
                [
                    .notRequested,
                    .loading(Fixtures.anyURL),
                    .loading(Fixtures.anyOtherURL),
                    .image(Fixtures.anyOtherURL, Fixtures.anyImage),
                ],
                result
            )
        }

        func testDidFail() {
            // given
            let sut = NetworkImageStore(
                environment: NetworkImageStore.Environment(
                    image: failedImage,
                    scheduler: scheduler.eraseToAnyScheduler()
                )
            )
            var result: [NetworkImageStore.State] = []

            sut.$state
                .sink { result.append($0) }
                .store(in: &cancellables)

            // when
            sut.send(.onAppear(Fixtures.anyURL))
            scheduler.run()

            // then
            XCTAssertEqual(
                [
                    .notRequested,
                    .loading(Fixtures.anyURL),
                    .failed,
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
    }
#endif
