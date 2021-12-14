import Combine
import XCTest

@testable import NetworkImage

final class NetworkImageLoaderTests: XCTestCase {
  private var cancellables = Set<AnyCancellable>()

  override func tearDownWithError() throws {
    cancellables.removeAll()
  }

  func testImageLoadsAndCachesImage() throws {
    // given
    let imageCache = NetworkImageCache()
    let imageLoader = NetworkImageLoader(
      data: { url in
        XCTAssertEqual(url, Fixtures.anyImageURL)
        return Just(
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
        .eraseToAnyPublisher()
      },
      imageCache: imageCache
    )

    // when
    var result: PlatformImage?
    imageLoader.image(for: Fixtures.anyImageURL, scale: 1)
      .assertNoFailure()
      .sink(receiveValue: {
        result = $0
      })
      .store(in: &cancellables)

    // then
    let unwrappedResult = try XCTUnwrap(result)
    XCTAssertTrue(unwrappedResult.isEqual(imageCache.image(for: Fixtures.anyImageURL, scale: 1)))
    XCTAssertTrue(
      unwrappedResult.isEqual(imageLoader.cachedImage(for: Fixtures.anyImageURL, scale: 1)))
  }

  func testImageReturnsCachedImageIfAvailable() throws {
    // given
    let imageCache = NetworkImageCache()
    let imageLoader = NetworkImageLoader(
      data: { _ in
        XCTFail()
        return Empty().eraseToAnyPublisher()
      },
      imageCache: imageCache
    )
    imageCache.setImage(Fixtures.anyImage, for: Fixtures.anyImageURL, scale: 1)

    // when
    var result: PlatformImage?
    imageLoader.image(for: Fixtures.anyImageURL, scale: 1)
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
      data: { url in
        XCTAssertEqual(url, Fixtures.anyImageURL)
        return Just(
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
        .eraseToAnyPublisher()
      },
      imageCache: .noop
    )

    // when
    var result: Error?
    imageLoader.image(for: Fixtures.anyImageURL, scale: 1)
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
      data: { url in
        XCTAssertEqual(url, Fixtures.anyImageURL)
        return Just(
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
        .eraseToAnyPublisher()
      },
      imageCache: .noop
    )

    // when
    var result: Error?
    imageLoader.image(for: Fixtures.anyImageURL, scale: 1)
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
