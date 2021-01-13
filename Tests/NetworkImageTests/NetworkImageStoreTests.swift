#if canImport(Combine)
    import Combine
    import CombineSchedulers
    import XCTest

    @testable import NetworkImage

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    final class NetworkImageStoreTests: XCTestCase {
        private let scheduler = DispatchQueue.testScheduler
        private var cancellables = Set<AnyCancellable>()

        override func tearDownWithError() throws {
            cancellables.removeAll()
        }

        func testOnAppearNil() {
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
            sut.send(.onAppear(Fixtures.anyImageURL))
            sut.send(.onAppear(nil))
            scheduler.run()

            // then
            XCTAssertEqual(
                [
                    .notRequested,
                    .failed(nil),
                    .loading(Fixtures.anyImageURL),
                    .failed(nil),
                ],
                result
            )
        }

        func testOnAppear() {
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
            sut.send(.onAppear(Fixtures.anyImageURL))
            sut.send(.onAppear(Fixtures.anyImageURL))
            sut.send(.onAppear(Fixtures.anyOtherImageURL))
            scheduler.run()

            // then
            XCTAssertEqual(
                [
                    .notRequested,
                    .loading(Fixtures.anyImageURL),
                    .loading(Fixtures.anyOtherImageURL),
                    .image(Fixtures.anyOtherImageURL, Fixtures.anyImage),
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
            sut.send(.onAppear(Fixtures.anyImageURL))
            scheduler.run()

            // then
            XCTAssertEqual(
                [
                    .notRequested,
                    .loading(Fixtures.anyImageURL),
                    .failed(Fixtures.anyImageURL),
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
