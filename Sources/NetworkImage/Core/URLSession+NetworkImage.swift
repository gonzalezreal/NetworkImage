import Foundation

extension URLSession {
    private enum Constants {
        static let memoryCapacity = 10 * 1024 * 1024
        static let diskCapacity = 100 * 1024 * 1024
        static let timeoutInterval: TimeInterval = 15
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public static var imageLoading: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = URLCache(
            memoryCapacity: Constants.memoryCapacity,
            diskCapacity: Constants.diskCapacity
        )
        configuration.timeoutIntervalForRequest = Constants.timeoutInterval
        configuration.httpAdditionalHeaders = ["Accept": "image/*"]

        return URLSession(configuration: configuration)
    }
}
