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
