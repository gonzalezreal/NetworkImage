import Foundation

public protocol NetworkImageLoader: AnyObject, Sendable {
  func image(with source: ImageSource) async throws -> PlatformImage
}

extension NetworkImageLoader {
  public func image(with url: URL) async throws -> PlatformImage {
    try await self.image(with: .init(url: url))
  }
}

// MARK: - DefaultNetworkImageLoader

public actor DefaultNetworkImageLoader {
  private enum Constants {
    static let memoryCapacity = 10 * 1024 * 1024
    static let diskCapacity = 100 * 1024 * 1024
    static let timeoutInterval: TimeInterval = 15
  }

  private let data: (URL) async throws -> (Data, URLResponse)
  private let cache: NetworkImageCache

  private var ongoingTasks: [ImageSource: Task<PlatformImage, Error>] = [:]

  public init(cache: NetworkImageCache, session: URLSession) {
    self.init(cache: cache, data: session.data(from:))
  }

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
  public static var `default`: Self {
    .shared
  }
}
