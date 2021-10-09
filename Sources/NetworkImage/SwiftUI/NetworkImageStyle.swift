import SwiftUI

/// A type that applies a custom appearance to all network images within a view hierarchy.
///
/// To configure the current network image style for a view hierarchy, use the `networkImageStyle(_:)`
/// modifier and specify a style that conforms to `NetworkImageStyle`.
public protocol NetworkImageStyle {
  /// A view that represents the body of a network image.
  associatedtype Body: View

  /// Creates a view that represents the body of a network image.
  ///
  /// The system calls this method for each `NetworkImage` instance in a view
  /// hierarchy where this style is the current network image style.
  ///
  /// - Parameter configuration: The properties of a network image, such as
  /// the actual image and its logical size.
  func makeBody(configuration: Self.Configuration) -> Body

  /// A type alias for the properties of a network image view instance.
  typealias Configuration = NetworkImageStyleConfiguration
}

/// The properties of a network image view instance.
public struct NetworkImageStyleConfiguration {
  /// The image presented by the network image view.
  public var image: Image

  /// The logical dimensions, in points, for the image.
  public var size: CGSize
}

extension View {
  /// Sets the style for network images within this view.
  public func networkImageStyle<S>(_ networkImageStyle: S) -> some View where S: NetworkImageStyle {
    environment(\.networkImageStyle, AnyNetworkImageStyle(networkImageStyle))
  }
}

struct AnyNetworkImageStyle: NetworkImageStyle {
  private let _makeBody: (Configuration) -> AnyView

  init<S>(_ networkImageStyle: S) where S: NetworkImageStyle {
    _makeBody = {
      AnyView(networkImageStyle.makeBody(configuration: $0))
    }
  }

  func makeBody(configuration: Configuration) -> AnyView {
    _makeBody(configuration)
  }
}

extension EnvironmentValues {
  var networkImageStyle: AnyNetworkImageStyle {
    get { self[NetworkImageStyleKey.self] }
    set { self[NetworkImageStyleKey.self] = newValue }
  }
}

private struct NetworkImageStyleKey: EnvironmentKey {
  static let defaultValue = AnyNetworkImageStyle(ResizableNetworkImageStyle())
}
