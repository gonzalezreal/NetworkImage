
import Combine
import CombineSchedulers
import XCTest

@testable import NetworkImage

final class NetworkImageStoreTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDownWithError() throws {
        cancellables.removeAll()
    }

    func testNilURLReturnsFallback() {
        // given
        let store = NetworkImageStore(url: nil)

        var result: [NetworkImageStore.State] = []

        store.$state
            .sink { result.append($0) }
            .store(in: &cancellables)

        // when
        store.send(
            .onAppear(
                environment: .init(
                    imageLoader: .failing,
                    mainQueue: .immediate
                )
            )
        )

        // then
        XCTAssertEqual([.fallback], result)
    }

    func testValidURLReturnsImage() {
        // given
        let scheduler = DispatchQueue.test
        let store = NetworkImageStore(url: Fixtures.anyImageURL)
        var result: [NetworkImageStore.State] = []

        store.$state
            .sink { result.append($0) }
            .store(in: &cancellables)

        // when
        store.send(
            .onAppear(
                environment: .init(
                    imageLoader: .mock(
                        url: Fixtures.anyImageURL,
                        withResponse: Just(Fixtures.anyImage)
                            .setFailureType(to: Error.self)
                            .delay(for: .seconds(1), scheduler: scheduler)
                    ),
                    mainQueue: scheduler.eraseToAnyScheduler()
                )
            )
        )
        scheduler.advance(by: .seconds(1))

        // then
        XCTAssertEqual(
            [
                .notRequested(Fixtures.anyImageURL),
                .placeholder,
                .image(Fixtures.anyImage),
            ],
            result
        )
    }

    func testFailingURLReturnsFallback() {
        // given
        let scheduler = DispatchQueue.test
        let store = NetworkImageStore(url: Fixtures.anyImageURL)
        var result: [NetworkImageStore.State] = []

        store.$state
            .sink { result.append($0) }
            .store(in: &cancellables)

        // when
        store.send(
            .onAppear(
                environment: .init(
                    imageLoader: .mock(
                        url: Fixtures.anyImageURL,
                        withResponse: Fail(error: Fixtures.anyError as Error)
                            .delay(for: .seconds(1), scheduler: scheduler)
                    ),
                    mainQueue: scheduler.eraseToAnyScheduler()
                )
            )
        )
        scheduler.advance(by: .seconds(1))

        // then
        XCTAssertEqual(
            [
                .notRequested(Fixtures.anyImageURL),
                .placeholder,
                .fallback,
            ],
            result
        )
    }
}
