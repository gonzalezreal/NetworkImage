import Foundation

/// A type that loads and caches images.
public protocol NetworkImageLoader: AnyObject, Sendable {
  /// Loads and returns the image for a given image source.
  func image(with source: ImageSource) async throws -> PlatformImage
}

extension NetworkImageLoader {
  /// Loads and returns the image for a given URL.
  public func image(with url: URL) async throws -> PlatformImage {
    try await self.image(with: .init(url: url))
  }
}

// MARK: - DefaultNetworkImageLoader

/// The default network image loader.
public actor DefaultNetworkImageLoader {
  private enum Constants {
    static let memoryCapacity = 10 * 1024 * 1024
    static let diskCapacity = 100 * 1024 * 1024
    static let timeoutInterval: TimeInterval = 15
  }

  private let data: (URL) async throws -> (Data, URLResponse)
  private let cache: NetworkImageCache

  private var ongoingTasks: [ImageSource: Task<PlatformImage, Error>] = [:]

  /// Creates a default network image cache.
  /// - Parameter countLimit: The maximum number of images that the cache should hold. If `0`,
  ///                         there is no count limit. The default value is `0`.

  /// Creates a default network image loader.
  /// - Parameters:
  ///   - cache: The network image cache that this loader will use to store the images.
  ///   - session: The session that this loader will use to fetch the images.
  public init(cache: NetworkImageCache, session: URLSession) {
    self.init(cache: cache, data: session.data(from:))
  }

  /// A shared network image loader.
  public static let shared = DefaultNetworkImageLoader(
    cache: .default,
    session: .imageLoading(
      memoryCapacity: Constants.memoryCapacity,
      diskCapacity: Constants.diskCapacity,
      timeoutInterval: Constants.timeoutInterval
    )
  )

  init(
    cache: NetworkImageCache,
    data: @escaping (URL) async throws -> (Data, URLResponse)
  ) {
    self.data = data
    self.cache = cache
  }
}

extension DefaultNetworkImageLoader: NetworkImageLoader {
  public func image(with source: ImageSource) async throws -> PlatformImage {
    if let image = self.cache.image(for: source) {
      return image
    }

    if let task = self.ongoingTasks[source] {
      return try await task.value
    }

    let task = Task<PlatformImage, Error> {
      let (data, response) = try await self.data(source.url)

      // remove ongoing task
      self.ongoingTasks.removeValue(forKey: source)

      guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
        200..<300 ~= statusCode
      else {
        throw URLError(.badServerResponse)
      }

      guard let image = PlatformImage.decoding(data: data, scale: source.scale) else {
        throw URLError(.cannotDecodeContentData)
      }

      // add image to cache
      self.cache.setImage(image, for: source)

      return image
    }

    // add ongoing task
    self.ongoingTasks[source] = task

    return try await task.value
  }
}

extension NetworkImageLoader where Self == DefaultNetworkImageLoader {
  /// The shared default network image loader.
  public static var `default`: Self {
    .shared
  }
}
