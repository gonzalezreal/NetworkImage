import XCTest
import NetworkImage

final class DefaultNetworkImageCacheTests: XCTestCase {
  func testCacheMiss() {
    // given
    let cache = DefaultNetworkImageCache()

    // when
    let image = cache.image(for: Fixtures.source)

    // then
    XCTAssertNil(image)

    // when
    cache.setImage(Fixtures.image, for: Fixtures.source)
    let image2x = cache.image(for: Fixtures.source2x)

    // then
    XCTAssertNil(image2x)
  }

  func testCacheHit() {
    // given
    let cache = DefaultNetworkImageCache()
    cache.setImage(Fixtures.image, for: Fixtures.source)

    // when
    let image = cache.image(for: Fixtures.source)

    // then
    XCTAssertIdentical(image, Fixtures.image)
  }
}
