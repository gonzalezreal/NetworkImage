#if canImport(SwiftUI)

    import SwiftUI

    /// A network image style that does not decorate the resulting image but applies the
    /// `resizable()` and `aspectRatio(contentMode:)` modifiers to it, and
    /// displays a placeholder image when loading fails or the given URL is `nil`.
    ///
    /// To apply this style to a network image, or to a view that contains network images,
    /// use the `networkImageStyle(_:)` modifier.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
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

        /// Creates a resizable network image style.
        ///
        /// - Parameters:
        ///   - backgroundColor: The background color of the network image in any state.
        ///   - foregroundColor: The tint color for the placeholder image.
        ///   - contentMode: The content mode applied to the resulting image.
        ///   - errorPlaceholder: An image to display when there is an error or the URL is `nil`.
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

        /// Creates a view that represents the body of a network image.
        ///
        /// The system calls this method for each `NetworkImage` instance in a view
        /// hierarchy where this style is the current network image style.
        ///
        /// - Parameter state: The state of the network image.
        public func makeBody(state: NetworkImageState) -> some View {
            ZStack {
                backgroundColor

                switch state {
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
