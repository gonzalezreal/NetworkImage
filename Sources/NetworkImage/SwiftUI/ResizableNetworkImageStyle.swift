//
// ResizableNetworkImageStyle.swift
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
    public struct ResizableNetworkImageStyle: NetworkImageStyle {
        private let backgroundColor: Color
        private let foregroundColor: Color
        private let contentMode: ContentMode
        private let errorPlaceholder: Image?

        public init(
            backgroundColor: Color,
            foregroundColor: Color,
            contentMode: ContentMode,
            errorPlaceholder: Image?
        ) {
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
            self.contentMode = contentMode
            self.errorPlaceholder = errorPlaceholder
        }

        #if os(iOS)
            public init(errorPlaceholder: Image? = Image(systemName: "photo")) {
                self.init(
                    backgroundColor: Color(.secondarySystemBackground),
                    foregroundColor: Color(.systemFill),
                    contentMode: .fill,
                    errorPlaceholder: errorPlaceholder
                )
            }

        #elseif os(tvOS) || os(watchOS)
            public init(errorPlaceholder: Image? = Image(systemName: "photo")) {
                self.init(
                    backgroundColor: Color.secondary,
                    foregroundColor: Color.primary.opacity(0.5),
                    contentMode: .fill,
                    errorPlaceholder: errorPlaceholder
                )
            }

        #elseif os(macOS)
            public init(errorPlaceholder: Image? = nil) {
                self.init(
                    backgroundColor: Color.secondary,
                    foregroundColor: Color.primary.opacity(0.5),
                    contentMode: .fill,
                    errorPlaceholder: errorPlaceholder
                )
            }
        #endif

        public func makeBody(configuration: NetworkImageConfiguration) -> some View {
            ZStack {
                backgroundColor

                switch configuration {
                case .loading:
                    EmptyView()
                case let .image(image, _):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                case .failed:
                    errorPlaceholder?
                        .foregroundColor(foregroundColor)
                }
            }
        }
    }

#endif
