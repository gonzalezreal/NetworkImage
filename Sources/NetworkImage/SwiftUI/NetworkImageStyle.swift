#if canImport(SwiftUI)

    import SwiftUI

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public protocol NetworkImageStyle {
        associatedtype Body: View

        @ViewBuilder func makeBody(configuration: NetworkImageConfiguration) -> Body
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public extension View {
        func networkImageStyle<A>(_ networkImageStyle: A) -> some View where A: NetworkImageStyle {
            environment(\.networkImageStyle, AnyNetworkImageStyle(networkImageStyle))
        }
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    struct AnyNetworkImageStyle: NetworkImageStyle {
        private let _makeBody: (NetworkImageConfiguration) -> AnyView

        init<A>(_ networkImageStyle: A) where A: NetworkImageStyle {
            _makeBody = {
                AnyView(networkImageStyle.makeBody(configuration: $0))
            }
        }

        func makeBody(configuration: NetworkImageConfiguration) -> AnyView {
            _makeBody(configuration)
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
