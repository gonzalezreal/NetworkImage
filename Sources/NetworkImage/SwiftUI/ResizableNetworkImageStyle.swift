import SwiftUI

/// A network image style that applies the `resizable()` modifier to the image.
///
/// To apply this style to a network image, or to a view that contains network images,
/// use the `networkImageStyle(_:)` modifier.
public struct ResizableNetworkImageStyle: NetworkImageStyle {
  /// Creates a view that represents the body of a network image.
  ///
  /// The system calls this method for each `NetworkImage` instance in a view
  /// hierarchy where this style is the current network image style.
  ///
  /// - Parameter configuration: The properties of a network image, such as
  /// the actual image and its logical size.
  public func makeBody(configuration: Configuration) -> some View {
    configuration.image.resizable()
  }
}
