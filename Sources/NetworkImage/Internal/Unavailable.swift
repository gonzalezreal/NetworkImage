import CombineSchedulers
import SwiftUI

// NB: Unavailable in 4.0.0

@available(
  *,
  unavailable,
  message: "You can style a NetworkImage by providing a content closure in one of the initializers."
)
public protocol NetworkImageStyle {
  associatedtype Body: View
  func makeBody(configuration: Self.Configuration) -> Body
  typealias Configuration = NetworkImageStyleConfiguration
}

@available(
  *,
  unavailable,
  message: "You can style a NetworkImage by providing a content closure in one of the initializers."
)
public struct NetworkImageStyleConfiguration {
  public var image: Image
  public var size: CGSize
}

@available(
  *,
  unavailable,
  message: "You can style a NetworkImage by providing a content closure in one of the initializers."
)
public struct ResizableNetworkImageStyle: NetworkImageStyle {
  public func makeBody(configuration: Configuration) -> some View {
    EmptyView()
  }
}

extension EnvironmentValues {
  @available(
    *,
    unavailable,
    message: "You can use the 'transaction' parameter in NetworkImage to animate state changes."
  )
  public var networkImageScheduler: AnySchedulerOf<UIScheduler> {
    get { UIScheduler.shared.eraseToAnyScheduler() }
    set {}
  }
}

extension View {
  @available(
    *,
    unavailable,
    message: "You can use the 'transaction' parameter in NetworkImage to animate state changes."
  )
  public func networkImageScheduler(
    _ networkImageScheduler: AnySchedulerOf<UIScheduler>
  ) -> some View {
    EmptyView()
  }

  @available(
    *,
    unavailable,
    message: "You can use the 'transaction' parameter in NetworkImage to animate state changes."
  )
  public func networkImageScheduler(_ networkImageScheduler: UIScheduler) -> some View {
    EmptyView()
  }

  @available(
    *,
    unavailable,
    message:
      "You can style a NetworkImage by providing a content closure in one of the initializers."
  )
  public func networkImageStyle<S>(_ networkImageStyle: S) -> some View where S: NetworkImageStyle {
    EmptyView()
  }
}
