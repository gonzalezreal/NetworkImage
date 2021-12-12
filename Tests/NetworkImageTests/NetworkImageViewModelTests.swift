import Combine
import CombineSchedulers
import SwiftUI
import XCTest

@testable import NetworkImage

final class NetworkImageViewModelTests: XCTestCase {
  private var cancellables = Set<AnyCancellable>()

  override func tearDownWithError() throws {
    cancellables.removeAll()
  }

  func testOnAppearNilReturnsFailure() {
    // given
    let viewModel = NetworkImageViewModel()

    var result: [NetworkImageViewModel.State?] = []

    viewModel.$state
      .sink { result.append($0) }
      .store(in: &cancellables)

    // when
    viewModel.onAppear(
      url: nil,
      environment: .init(
        imageLoader: .failing,
        uiScheduler: UIScheduler.shared.eraseToAnyScheduler()
      )
    )

    // then
    XCTAssertEqual([nil, .failure], result)
  }

  func testOnAppearWithNoneStateReturnsImage() {
    // given
    let scheduler = DispatchQueue.test
    let viewModel = NetworkImageViewModel()
    var result: [NetworkImageViewModel.State?] = []

    viewModel.$state
      .sink { result.append($0) }
      .store(in: &cancellables)

    // when
    viewModel.onAppear(
      url: Fixtures.anyImageURL,
      environment: .init(
        imageLoader: .mock(
          url: Fixtures.anyImageURL,
          withResponse: Just(Fixtures.anyImage)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(1), scheduler: scheduler)
        ),
        uiScheduler: UIScheduler.shared.eraseToAnyScheduler()
      )
    )
    scheduler.advance(by: .seconds(1))

    // then
    XCTAssertEqual(
      [
        nil,
        .empty,
        .success(Fixtures.anyImageView),
      ],
      result
    )
  }

  func testOnAppearWithSomeStateDoesNothing() {
    // given
    let viewModel = NetworkImageViewModel(state: .empty)

    var result: [NetworkImageViewModel.State?] = []

    viewModel.$state
      .sink { result.append($0) }
      .store(in: &cancellables)

    // when
    viewModel.onAppear(
      url: Fixtures.anyImageURL,
      environment: .init(
        imageLoader: .failing,
        uiScheduler: UIScheduler.shared.eraseToAnyScheduler()
      )
    )

    // then
    XCTAssertEqual([.empty], result)
  }

  func testOnAppearWithFailingURLReturnsFailure() {
    // given
    let scheduler = DispatchQueue.test
    let viewModel = NetworkImageViewModel()

    var result: [NetworkImageViewModel.State?] = []

    viewModel.$state
      .sink { result.append($0) }
      .store(in: &cancellables)

    // when
    viewModel.onAppear(
      url: Fixtures.anyImageURL,
      environment: .init(
        imageLoader: .mock(
          url: Fixtures.anyImageURL,
          withResponse: Fail(error: Fixtures.anyError as Error)
            .delay(for: .seconds(1), scheduler: scheduler)
        ),
        uiScheduler: UIScheduler.shared.eraseToAnyScheduler()
      )
    )
    scheduler.advance(by: .seconds(1))

    // then
    XCTAssertEqual(
      [
        nil,
        .empty,
        .failure,
      ],
      result
    )
  }

  func testOnURLChangeWithNilURLReturnsFailure() {
    // given
    let viewModel = NetworkImageViewModel(state: .empty)

    var result: [NetworkImageViewModel.State?] = []

    viewModel.$state
      .sink { result.append($0) }
      .store(in: &cancellables)

    // when
    viewModel.onURLChange(
      url: nil,
      environment: .init(
        imageLoader: .failing,
        uiScheduler: UIScheduler.shared.eraseToAnyScheduler()
      )
    )

    // then
    XCTAssertEqual([.empty, .failure], result)
  }

  func testOnURLChangeWithSomeURLReturnsImage() {
    // given
    let scheduler = DispatchQueue.test
    let viewModel = NetworkImageViewModel(state: .failure)
    var result: [NetworkImageViewModel.State?] = []

    viewModel.$state
      .sink { result.append($0) }
      .store(in: &cancellables)

    // when
    viewModel.onURLChange(
      url: Fixtures.anyImageURL,
      environment: .init(
        imageLoader: .mock(
          url: Fixtures.anyImageURL,
          withResponse: Just(Fixtures.anyImage)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(1), scheduler: scheduler)
        ),
        uiScheduler: UIScheduler.shared.eraseToAnyScheduler()
      )
    )
    scheduler.advance(by: .seconds(1))

    // then
    XCTAssertEqual(
      [
        .failure,
        .empty,
        .success(Fixtures.anyImageView),
      ],
      result
    )
  }
}
