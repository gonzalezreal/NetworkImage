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
    public struct NetworkImage: View {
        @Environment(\.networkImageStyle) private var networkImageStyle
        @ObservedObject private var store: NetworkImageStore

        public init(url: URL?) {
            self.init(store: NetworkImageStore(url: url))
        }

        private init(store: NetworkImageStore) {
            self.store = store
        }

        public var body: some View {
            networkImageStyle.makeBody(
                configuration: NetworkImageConfiguration(state: store.state)
            )
        }
    }

#endif
