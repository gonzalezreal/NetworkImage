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
        public enum Defaults {
            #if os(iOS)
                public static var backgroundColor: Color {
                    Color(.secondarySystemBackground)
                }

                public static var foregroundColor: Color {
                    Color(.systemFill)
                }

            #elseif os(macOS) || os(tvOS) || os(watchOS)
                public static var backgroundColor: Color {
                    .secondary
                }

                public static var foregroundColor: Color {
                    Color.primary.opacity(0.5)
                }
            #endif

            #if os(iOS) || os(tvOS) || os(watchOS)
                public static var errorPlaceholder: Image? {
                    Image(systemName: "photo")
                }

            #elseif os(macOS)
                public static let errorPlaceholder: Image? = nil
            #endif
        }

        private let backgroundColor: Color
        private let foregroundColor: Color
        private let contentMode: ContentMode
        private let errorPlaceholder: Image?

        public init(
            backgroundColor: Color = Defaults.backgroundColor,
            foregroundColor: Color = Defaults.foregroundColor,
            contentMode: ContentMode = .fill,
            errorPlaceholder: Image? = Defaults.errorPlaceholder
        ) {
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
            self.contentMode = contentMode
            self.errorPlaceholder = errorPlaceholder
        }

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
