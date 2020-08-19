//
// NetworkImageStore.swift
//
// Copyright (c) 2020 Guille Gonzalez
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(Combine)
    import Combine
    import CombineSchedulers
    import Foundation

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    internal final class NetworkImageStore {
        enum State: Equatable {
            case notRequested
            case loading
            case image(OSImage, elapsedTime: TimeInterval)
            case failed
        }

        enum Action {
            case didSetURL(URL?)
            case didLoadImage(OSImage, elapsedTime: TimeInterval)
            case didFail
            case prepareForReuse
        }

        struct Environment {
            let image: (URL) -> AnyPublisher<OSImage, Error>
            let currentTime: () -> Double
            let scheduler: AnySchedulerOf<DispatchQueue>

            init(
                image: @escaping (URL) -> AnyPublisher<OSImage, Error> = ImageDownloader.shared.image(for:),
                currentTime: @escaping () -> Double = CFAbsoluteTimeGetCurrent,
                scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
            ) {
                self.image = image
                self.currentTime = currentTime
                self.scheduler = scheduler
            }
        }

        @Published private(set) var state: State = .notRequested

        private let environment: Environment
        private var cancellable: AnyCancellable?

        init(environment: Environment = Environment()) {
            self.environment = environment
        }

        func send(_ action: Action) {
            switch action {
            case .didSetURL(.none):
                state = .failed
                cancellable?.cancel()
            case let .didSetURL(.some(url)):
                let startTime = environment.currentTime()
                state = .loading
                cancellable = environment.image(url)
                    .map { [environment] image in
                        let elapsedTime = environment.currentTime() - startTime
                        return .didLoadImage(image, elapsedTime: elapsedTime)
                    }
                    .replaceError(with: .didFail)
                    .receive(on: environment.scheduler)
                    .sink(receiveValue: { [weak self] action in
                        self?.send(action)
                    })
            case let .didLoadImage(image, elapsedTime):
                state = .image(image, elapsedTime: elapsedTime)
            case .didFail:
                state = .failed
            case .prepareForReuse:
                state = .notRequested
                cancellable?.cancel()
            }
        }
    }
#endif
