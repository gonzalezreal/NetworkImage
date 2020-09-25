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
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public struct NetworkImage: View {
        @Environment(\.networkImageStyle) private var networkImageStyle
        @ObservedObject private var store: NetworkImageStore

        /// Creates a network image.
        /// - Parameter url: The URL where the image is located.
        public init(url: URL?) {
            self.init(store: NetworkImageStore(url: url))
        }

        private init(store: NetworkImageStore) {
            self.store = store
        }

        public var body: some View {
            networkImageStyle.makeBody(
                state: NetworkImageState(state: store.state)
            )
        }
    }

#endif
