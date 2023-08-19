import XCTest
@testable import NetworkImage

final class DefaultNetworkImageLoaderTests: XCTestCase {
  func testImageLoad() async throws {
    // given
    let imageCache = DefaultNetworkImageCache()

    var loadCount = 0
    let imageLoader = DefaultNetworkImageLoader(cache: imageCache) { _ in
      loadCount += 1
      return (Fixtures.imageData, Fixtures.okResponse)
    }

    // when
    async let firstImage = imageLoader.image(with: Fixtures.source)
    async let secondImage = imageLoader.image(with: Fixtures.anotherSource)
    async let thirdImage = imageLoader.image(with: Fixtures.source)

    let images = try await (firstImage, secondImage, thirdImage)

    // then
    XCTAssertEqual(loadCount, 2)
    XCTAssertIdentical(images.0, images.2)
    XCTAssertIdentical(imageCache.image(for: Fixtures.source), images.0)
    XCTAssertIdentical(imageCache.image(for: Fixtures.anotherSource), images.1)
  }

  func testImageCache() async throws {
    // given
    let imageCache = DefaultNetworkImageCache()
    imageCache.setImage(Fixtures.image, for: Fixtures.source)

    var loadCount = 0
    let imageLoader = DefaultNetworkImageLoader(cache: imageCache) { _ in
      loadCount += 1
      return (Fixtures.imageData, Fixtures.okResponse)
    }

    // when
    let image = try await imageLoader.image(with: Fixtures.source)

    // then
    XCTAssertEqual(loadCount, 0)
    XCTAssertIdentical(image, Fixtures.image)
  }

  func testImageBadServerResponse() async throws {
    // given
    let imageLoader = DefaultNetworkImageLoader(cache: .default) { _ in
      return (.init(), Fixtures.internalServerErrorResponse)
    }

    // when
    var capturedError: URLError?
    do {
      _ = try await imageLoader.image(with: Fixtures.source)
      XCTFail("Asynchronous call did not throw an error.")
    } catch {
      capturedError = error as? URLError
    }

    // then
    XCTAssertEqual(capturedError, URLError(.badServerResponse))
  }

  func testImageCannotDecodeContent() async throws {
    // given
    let imageLoader = DefaultNetworkImageLoader(cache: .default) { _ in
      return (Data([0xde, 0xad, 0xbe, 0xef]), Fixtures.okResponse)
    }

    // when
    var capturedError: URLError?
    do {
      _ = try await imageLoader.image(with: Fixtures.source)
      XCTFail("Asynchronous call did not throw an error.")
    } catch {
      capturedError = error as? URLError
    }

    // then
    XCTAssertEqual(capturedError, URLError(.cannotDecodeContentData))
  }
}
