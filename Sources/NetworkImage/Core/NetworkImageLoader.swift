import Combine
import CoreGraphics
import Foundation

/// Loads and caches images.
public struct NetworkImageLoader {
  private let _image: (URL, CGFloat) -> AnyPublisher<PlatformImage, Error>
  private let _cachedImage: (URL, CGFloat) -> PlatformImage?

  /// Creates an image loader.
  /// - Parameters:
  ///   - urlSession: The `URLSession` that will load the images.
  ///   - imageCache: An immediate cache to store the images in memory.
  public init(urlSession: URLSession, imageCache: NetworkImageCache) {
    self.init(
      data: { url in
        urlSession.dataTaskPublisher(for: url).eraseToAnyPublisher()
      },
      imageCache: imageCache
    )
  }

  init(
    data: @escaping (URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>,
    imageCache: NetworkImageCache
  ) {
    self.init(
      image: { url, scale in
        if let image = imageCache.image(for: url, scale: scale) {
          return Just(image)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        } else {
          return data(url)
            .tryMap { data, response in
              if let httpResponse = response as? HTTPURLResponse {
                guard 200..<300 ~= httpResponse.statusCode else {
                  throw NetworkImageError.badStatus(httpResponse.statusCode)
                }
              }

              return try decodeImage(from: data, scale: scale)
            }
            .handleEvents(receiveOutput: { image in
              imageCache.setImage(image, for: url, scale: scale)
            })
            .eraseToAnyPublisher()
        }
      },
      cachedImage: { url, scale in
        imageCache.image(for: url, scale: scale)
      }
    )
  }

  init(
    image: @escaping (URL, CGFloat) -> AnyPublisher<PlatformImage, Error>,
    cachedImage: @escaping (URL, CGFloat) -> PlatformImage?
  ) {
    _image = image
    _cachedImage = cachedImage
  }

  /// Returns a publisher that loads an image for a given URL.
  public func image(for url: URL, scale: CGFloat = 1) -> AnyPublisher<PlatformImage, Error> {
    _image(url, scale)
  }

  /// Returns the cached image for a given URL if there is any.
  public func cachedImage(for url: URL, scale: CGFloat = 1) -> PlatformImage? {
    _cachedImage(url, scale)
  }
}

extension NetworkImageLoader {
  /// The shared singleton image loader.
  ///
  /// The shared image loader uses the shared `URLCache` and provides
  /// reasonable defaults for disk and memory caches.
  public static let shared = Self(urlSession: .imageLoading, imageCache: NetworkImageCache())
}

#if DEBUG
  import XCTestDynamicOverlay

  extension NetworkImageLoader {
    public static func mock<P>(
      url matchingURL: URL,
      scale matchingScale: CGFloat = 1,
      withResponse response: P
    ) -> Self where P: Publisher, P.Output == PlatformImage, P.Failure == Error {
      Self { url, scale in
        if url != matchingURL, scale != matchingScale {
          XCTFail("\(Self.self).image received an unexpected URL: \(url) or scale: \(scale)")
        }

        return response.eraseToAnyPublisher()
      } cachedImage: { _, _ in
        nil
      }
    }

    public static func mock<P>(
      response: P
    ) -> Self where P: Publisher, P.Output == PlatformImage, P.Failure == Error {
      Self { _, _ in
        response.eraseToAnyPublisher()
      } cachedImage: { _, _ in
        nil
      }
    }

    public static var failing: Self {
      Self { _, _ in
        XCTFail("\(Self.self).image is unimplemented")
        return Empty()
          .setFailureType(to: Error.self)
          .eraseToAnyPublisher()
      } cachedImage: { _, _ in
        nil
      }
    }
  }
#endif
