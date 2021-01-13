#if canImport(Combine)
    import Combine
    import CombineSchedulers
    import XCTest

    @testable import NetworkImage

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    final class NetworkImageStoreTests: XCTestCase {
        private let scheduler = DispatchQueue.testScheduler
        private var cancellables = Set<AnyCancellable>()

        private var successfulImage: (URL?) -> AnyPublisher<OSImage, Error> {
            { _ in
                Just(Fixtures.anyImage)
                    .delay(for: .seconds(1), scheduler: self.scheduler)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }

        private var failedImage: (URL?) -> AnyPublisher<OSImage, Error> {
            { _ in
                Fail(error: Fixtures.anyError)
                    .delay(for: .seconds(1), scheduler: self.scheduler)
                    .eraseToAnyPublisher()
            }
        }

        override func tearDownWithError() throws {
            cancellables.removeAll()
        }

        func testNilURLReturnsFallback() {
            // given
            let sut = NetworkImageStore(
                url: nil,
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
            scheduler.run()

            // then
            XCTAssertEqual([.fallback], result)
        }

        func testValidURLReturnsImage() {
            // given
            let sut = NetworkImageStore(
                url: Fixtures.anyImageURL,
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
            scheduler.run()

            // then
            XCTAssertEqual(
                [
                    .placeholder,
                    .image(Fixtures.anyImage),
                ],
                result
            )
        }

        func testFailingURLReturnsFallback() {
            // given
            let sut = NetworkImageStore(
                url: Fixtures.anyImageURL,
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
            scheduler.run()

            // then
            XCTAssertEqual(
                [
                    .placeholder,
                    .fallback,
                ],
                result
            )
        }
    }
#endif
