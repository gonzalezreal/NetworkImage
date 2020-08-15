//
// NetworkImage.swift
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

#if canImport(SwiftUI)

    import SwiftUI

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    extension NetworkImageStore: ObservableObject {}

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    internal extension NetworkImageStore {
        convenience init(url: URL?) {
            self.init()
            send(.didSetURL(url))
        }
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public struct NetworkImage<Content: View, Placeholder: View>: View {
        @ObservedObject private var store: NetworkImageStore

        private let content: (Image) -> Content
        private let error: () -> Placeholder

        public init(
            url: URL?,
            content: @escaping (Image) -> Content,
            error: @escaping () -> Placeholder
        ) {
            self.init(
                store: NetworkImageStore(url: url),
                content: content,
                error: error
            )
        }

        private init(
            store: NetworkImageStore,
            content: @escaping (Image) -> Content,
            error: @escaping () -> Placeholder
        ) {
            self.store = store
            self.content = content
            self.error = error
        }

        public var body: some View {
            switch store.state {
            case .notRequested, .loading:
                EmptyView()
            case let .image(osImage, _):
                content(Image(osImage: osImage))
            case .failed:
                error()
            }
        }
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    extension NetworkImage where Placeholder == EmptyView {
        public init(url: URL?, content: @escaping (Image) -> Content) {
            self.init(url: url, content: content, error: { EmptyView() })
        }
    }

#endif
