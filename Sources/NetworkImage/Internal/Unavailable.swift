import CombineSchedulers
import SwiftUI

// NB: Unavailable in 4.0.0

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
}
