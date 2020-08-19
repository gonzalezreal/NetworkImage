//
// ImagePrefetcher.swift
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
    import Foundation

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public final class ImagePrefetcher {
        private let session: URLSession
        private var cancellables: [URL: AnyCancellable] = [:]

        public init(session: URLSession = .imageLoading) {
            self.session = session
        }

        public func prefetchImages(with urls: Set<URL>) {
            assert(Thread.isMainThread)

            for url in urls where !cancellables.keys.contains(url) {
                cancellables[url] = session.dataTaskPublisher(for: url)
                    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            }
        }

        public func cancelPrefetchingImages(with urls: Set<URL>) {
            assert(Thread.isMainThread)

            for url in urls {
                cancellables.removeValue(forKey: url)
            }
        }
    }
#endif
