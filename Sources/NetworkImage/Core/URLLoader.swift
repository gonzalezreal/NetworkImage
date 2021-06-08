#if canImport(Combine)
    import Combine
    import Foundation
    import XCTestDynamicOverlay

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    internal struct URLLoader {
        private let _dataTaskPublisher: (URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>

        init(dataTaskPublisher: @escaping (URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>) {
            _dataTaskPublisher = dataTaskPublisher
        }

        init(urlSession: URLSession) {
            self.init { url in
                urlSession.dataTaskPublisher(for: url)
                    .eraseToAnyPublisher()
            }
        }

        func dataTaskPublisher(for url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
            _dataTaskPublisher(url)
        }
    }

    #if DEBUG
        @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
        extension URLLoader {
            static func mock<P>(
                url matchingURL: URL,
                withResponse response: P
            ) -> Self where P: Publisher, P.Output == (data: Data, response: HTTPURLResponse), P.Failure == URLError {
                Self { url in
                    if url != matchingURL {
                        XCTFail("\(Self.self).dataTaskPublisher received an unexpected URL: \(url)")
                    }
                    return response
                        .map { ($0, $1 as URLResponse) }
                        .eraseToAnyPublisher()
                }
            }

            static var failing: Self {
                Self { _ in
                    XCTFail("\(Self.self).dataTaskPublisher is unimplemented")
                    return Fail(error: URLError(.notConnectedToInternet))
                        .eraseToAnyPublisher()
                }
            }
        }
    #endif
#endif
