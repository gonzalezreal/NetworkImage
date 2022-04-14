import SwiftUI

// NB: Deprecated in 4.0.0

extension NetworkImage {
  @available(*, deprecated, message: "Use one of the other available NetworkImage initializers.")
  public init<P, F>(
    url: URL?,
    @ViewBuilder placeholder: @escaping () -> P,
    @ViewBuilder fallback: @escaping () -> F
  ) where Content == _ConditionalContent<_ConditionalContent<P, Image>, F>, P: View, F: View {
    self.init(url: url, content: { $0.resizable() }, placeholder: placeholder, fallback: fallback)
  }

  @available(*, deprecated, message: "Use one of the other available NetworkImage initializers.")
  public init(
    url: URL?, placeholderImage name: String
  ) where Content == _ConditionalContent<Image, Image> {
    self.init(url: url, content: { $0.resizable() }, placeholder: { Image(name) })
  }

  @available(*, deprecated, message: "Use one of the other available NetworkImage initializers.")
  public init(
    url: URL?, placeholderSystemImage name: String
  ) where Content == _ConditionalContent<Image, Image> {
    self.init(url: url, content: { $0.resizable() }, placeholder: { Image(systemName: name) })
  }

  @available(*, deprecated, message: "Use one of the other available NetworkImage initializers.")
  public init<F>(
    url: URL?, @ViewBuilder fallback: @escaping () -> F
  ) where Content == _ConditionalContent<_ConditionalContent<EmptyView, Image>, F>, F: View {
    self.init(
      url: url,
      content: { $0.resizable() },
      placeholder: { EmptyView() },
      fallback: fallback
    )
  }

  @available(*, deprecated, message: "Use one of the other available NetworkImage initializers.")
  public init(
    url: URL?, fallbackImage name: String
  ) where Content == _ConditionalContent<_ConditionalContent<EmptyView, Image>, Image> {
    self.init(
      url: url,
      content: { $0.resizable() },
      placeholder: { EmptyView() },
      fallback: { Image(name) }
    )
  }

  @available(*, deprecated, message: "Use one of the other available NetworkImage initializers.")
  public init(
    url: URL?, fallbackSystemImage name: String
  ) where Content == _ConditionalContent<_ConditionalContent<EmptyView, Image>, Image> {
    self.init(
      url: url,
      content: { $0.resizable() },
      placeholder: { EmptyView() },
      fallback: { Image(systemName: name) }
    )
  }
}

@available(*, deprecated, renamed: "PlatformImage")
public typealias OSImage = PlatformImage
