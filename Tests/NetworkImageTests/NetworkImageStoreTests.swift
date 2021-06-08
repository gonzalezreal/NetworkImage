#if canImport(Combine)
    import Combine
    import CombineSchedulers
    import XCTest

    @testable import NetworkImage

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    final class NetworkImageStoreTests: XCTestCase {
        private var cancellables = Set<AnyCancellable>()

        override func tearDownWithError() throws {
            cancellables.removeAll()
        }

        func testNilURLReturnsFallback() {
            // given
            let store = NetworkImageStore(
                url: nil,
                environment: NetworkImageEnvironment(
                    imageLoader: .failing,
                    mainQueue: .immediate
                )
            )

            var result: [NetworkImageStore.State] = []

            store.$state
                .sink { result.append($0) }
                .store(in: &cancellables)

            // then
            XCTAssertEqual([.fallback], result)
        }

        func testValidURLReturnsImage() {
            // given
            let scheduler = DispatchQueue.test
            let store = NetworkImageStore(
                url: Fixtures.anyImageURL,
                environment: NetworkImageEnvironment(
                    imageLoader: .mock(
                        url: Fixtures.anyImageURL,
                        withResponse: Just(Fixtures.anyImage)
                            .setFailureType(to: Error.self)
                            .delay(for: .seconds(1), scheduler: scheduler)
                    ),
                    mainQueue: scheduler.eraseToAnyScheduler()
                )
            )
            var result: [NetworkImageStore.State] = []

            store.$state
                .sink { result.append($0) }
                .store(in: &cancellables)

            // when
            scheduler.advance(by: .seconds(1))

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
            let scheduler = DispatchQueue.test
            let store = NetworkImageStore(
                url: Fixtures.anyImageURL,
                environment: NetworkImageEnvironment(
                    imageLoader: .mock(
                        url: Fixtures.anyImageURL,
                        withResponse: Fail(error: Fixtures.anyError as Error)
                            .delay(for: .seconds(1), scheduler: scheduler)
                    ),
                    mainQueue: scheduler.eraseToAnyScheduler()
                )
            )
            var result: [NetworkImageStore.State] = []

            store.$state
                .sink { result.append($0) }
                .store(in: &cancellables)

            // when
            scheduler.advance(by: .seconds(1))

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
