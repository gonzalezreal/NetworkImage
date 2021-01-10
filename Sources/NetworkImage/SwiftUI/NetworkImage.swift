#if canImport(SwiftUI)

    import SwiftUI

    /// A view that displays a remote image.
    ///
    /// A network image downloads and displays an image from a given URL.
    /// The download is asynchronous, and the result is cached both in disk and memory.
    ///
    /// You can create a network image by providing the URL where the image is located.
    ///
    ///     NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
    ///
    /// You can customize a network image's appearance in all of its different states: loading,
    /// displaying an image or failed. To add a custom appearance, create a style that conforms to
    /// the `NetworkImageStyle` protocol. To set a specific style for all network images within
    /// a view, use the `networkImageStyle(_:)` modifier:
    ///
    ///     VStack {
    ///         NetworkImage(url: URL(string: "https://picsum.photos/id/1025/300/200"))
    ///         NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
    ///     }
    ///     .networkImageStyle(BackdropNetworkImageStyle())
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public struct NetworkImage: View {
        @Environment(\.networkImageStyle) private var networkImageStyle
        @StateObject private var store = NetworkImageStore()

        private let url: URL?

        /// Creates a network image.
        /// - Parameter url: The URL where the image is located.
        public init(url: URL?) {
            self.url = url
        }

        public var body: some View {
            networkImageStyle
                .makeBody(state: NetworkImageState(state: store.state))
                .onAppear { store.send(.onAppear(url)) }
        }
    }

#endif
