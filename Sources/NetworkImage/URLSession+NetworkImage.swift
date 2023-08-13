import Foundation

extension URLSession {
  /// Returns a `URLSession` optimized for image downloading.
  public static func imageLoading(
    memoryCapacity: Int,
    diskCapacity: Int,
    timeoutInterval: TimeInterval
  ) -> URLSession {
    let configuration = URLSessionConfiguration.default

    configuration.requestCachePolicy = .returnCacheDataElseLoad
    configuration.urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
    configuration.timeoutIntervalForRequest = timeoutInterval
    configuration.httpAdditionalHeaders = ["Accept": "image/*"]

    return .init(configuration: configuration)
  }
}
