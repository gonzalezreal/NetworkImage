#if !(os(iOS) && (arch(i386) || arch(arm))) && canImport(SwiftUI)

    import SwiftUI

    /// A type that applies a custom appearance to all network images within a view hierarchy.
    ///
    /// To configure the current network image style for a view hierarchy, use the `networkImageStyle(_:)`
    /// modifier and specify a style that conforms to `NetworkImageStyle`.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public protocol NetworkImageStyle {
        /// A view that represents the body of a network image.
        associatedtype Body: View

        /// Creates a view that represents the body of a network image.
        ///
        /// The system calls this method for each `NetworkImage` instance in a view
        /// hierarchy where this style is the current network image style.
        ///
        /// - Parameter state: The state of the network image.
        @ViewBuilder func makeBody(state: NetworkImageState) -> Body
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public extension View {
        /// Sets the style for network images within this view.
        func networkImageStyle<S>(_ networkImageStyle: S) -> some View where S: NetworkImageStyle {
            environment(\.networkImageStyle, AnyNetworkImageStyle(networkImageStyle))
        }
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    struct AnyNetworkImageStyle: NetworkImageStyle {
        private let _makeBody: (NetworkImageState) -> AnyView

        init<S>(_ networkImageStyle: S) where S: NetworkImageStyle {
            _makeBody = {
                AnyView(networkImageStyle.makeBody(state: $0))
            }
        }

        func makeBody(state: NetworkImageState) -> AnyView {
            _makeBody(state)
        }
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    extension EnvironmentValues {
        var networkImageStyle: AnyNetworkImageStyle {
            get { self[NetworkImageStyleKey.self] }
            set { self[NetworkImageStyleKey.self] = newValue }
        }
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private struct NetworkImageStyleKey: EnvironmentKey {
        static let defaultValue = AnyNetworkImageStyle(ResizableNetworkImageStyle())
    }

#endif
