import Combine
import CombineSchedulers
import SwiftUI

/// A view that displays an image located at a given URL.
///
/// A network image downloads and displays an image from a given URL; the download is asynchronous,
/// and the result is cached both in disk and memory.
///
/// You create a network image, in its simplest form, by providing the image URL.
///
/// ```swift
/// NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
/// ```
///
/// You can also provide the name of a placeholder image that the view will display while the image is loading or, as
/// a fallback, if an error occurs or the URL is `nil`.
///
/// ```swift
/// NetworkImage(
///   url: URL(string: "https://picsum.photos/id/237/300/200"),
///   placeholderSystemImage: "photo.fill"
/// )
/// ```
///
/// If you want, you can only provide a fallback image. A network image view only displays this image if an error occurs
/// or when the URL is `nil`.
///
/// ```swift
/// NetworkImage(
///   url: URL(string: "https://picsum.photos/id/237/300/200"),
///   fallbackSystemImage: "photo.fill"
/// )
/// ```
///
/// It is also possible to create network images using views to compose the network image's placeholders
/// programmatically.
///
/// ```swift
/// NetworkImage(url: movie.posterURL) {
///   ProgressView()
/// } fallback: {
///   Text(movie.title)
///     .padding()
/// }
/// ```
///
/// ### Styling Network Images
///
/// You can customize the appearance of network images by creating styles that conform to the
/// `NetworkImageStyle` protocol. To set a specific style for all network images within a view, use
/// the `networkImageStyle(_:)` modifier. In the following example, a custom style adds a grayscale
/// effect to all the network image views within the enclosing `VStack`:
///
/// ```swift
/// struct ContentView: View {
///   var body: some View {
///     VStack {
///       NetworkImage(url: URL(string: "https://picsum.photos/id/1025/300/200"))
///       NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
///     }
///     .networkImageStyle(GrayscaleNetworkImageStyle())
///   }
/// }
/// struct GrayscaleNetworkImageStyle: NetworkImageStyle {
///   func makeBody(configuration: Configuration) -> some View {
///     configuration.image
///       .resizable()
///       .grayscale(0.99)
///   }
/// }
/// ```
public struct NetworkImage<Placeholder, Fallback>: View where Placeholder: View, Fallback: View {
  private enum LoadState: Equatable {
    case empty
    case success(URL, Image)
    case failure
  }

  @Environment(\.networkImageStyle) private var imageStyle
  @Environment(\.networkImageLoader) private var imageLoader

  @State private var loadState = LoadState.empty

  private let url: URL?
  private let placeholder: Placeholder
  private let fallback: Fallback

  private var loadStatePublisher: AnyPublisher<LoadState, Never> {
    guard let url = self.url else {
      return Just(.empty).eraseToAnyPublisher()
    }

    switch loadState {
    case .success(let loadedURL, _) where loadedURL == url:
      return Empty().eraseToAnyPublisher()
    default:
      return imageLoader.image(for: url)
        .map { platformImage in
          #if os(iOS) || os(tvOS) || os(watchOS)
            let image = Image(uiImage: platformImage)
          #elseif os(macOS)
            let image = Image(nsImage: platformImage)
          #endif
          return .success(url, image)
        }
        .replaceError(with: .failure)
        .receive(on: UIScheduler.shared)
        .eraseToAnyPublisher()
    }
  }

  /// Creates a network image with custom placeholders.
  /// - Parameters:
  ///   - url: The URL where the image is located.
  ///   - placeholder: A view builder that creates the view to display while the image is loading.
  ///   - fallback: A view builder that creates the view to display when the URL is `nil` or an error has occurred.
  public init(
    url: URL?,
    @ViewBuilder placeholder: () -> Placeholder,
    @ViewBuilder fallback: () -> Fallback
  ) {
    self.url = url
    self.placeholder = placeholder()
    self.fallback = fallback()
  }

  /// Creates a network image that displays a placeholder image while the image is loading or as a fallback.
  /// - Parameters:
  ///   - url: The URL where the image is located.
  ///   - placeholderImage: The name of the placeholder image resource.
  public init(url: URL?, placeholderImage name: String)
  where Placeholder == Image, Fallback == Image {
    self.init(
      url: url,
      placeholder: { Image(name) },
      fallback: { Image(name) }
    )
  }

  /// Creates a network image that displays a placeholder system image while the image is loading or as a fallback.
  /// - Parameters:
  ///   - url: The URL where the image is located.
  ///   - placeholderSystemImage: The name of the system image that will be used as a placeholder.
  @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
  public init(url: URL?, placeholderSystemImage name: String)
  where Placeholder == Image, Fallback == Image {
    self.init(
      url: url,
      placeholder: { Image(systemName: name) },
      fallback: { Image(systemName: name) }
    )
  }

  public var body: some View {
    Group {
      switch loadState {
      case .empty:
        placeholder
      case .success(_, let image):
        imageStyle.makeBody(
          configuration: NetworkImageStyleConfiguration(
            image: image,
            size: .zero
          )
        )
      case .failure:
        fallback
      }
    }
    .onReceive(loadStatePublisher) { loadState in
      self.loadState = loadState
    }
  }
}

extension NetworkImage where Fallback == EmptyView {
  /// Creates a network image without placeholders.
  /// - Parameter url: The URL where the image is located.
  public init(url: URL?) where Placeholder == EmptyView {
    self.init(
      url: url,
      placeholder: { EmptyView() },
      fallback: { EmptyView() }
    )
  }

  /// Creates a network image that displays a custom placeholder while the image is loading.
  /// - Parameters:
  ///   - url: The URL where the image is located.
  ///   - placeholder: A view builder that creates the view to display while the image is loading.
  public init(url: URL?, @ViewBuilder placeholder: () -> Placeholder) {
    self.init(
      url: url,
      placeholder: placeholder,
      fallback: { EmptyView() }
    )
  }
}

extension NetworkImage where Placeholder == EmptyView {
  /// Creates a network image with a fallback view.
  /// - Parameters:
  ///   - url: The URL where the image is located.
  ///   - fallback: A view builder that creates the view to display when the URL is `nil` or an error has occurred.
  public init(url: URL?, @ViewBuilder fallback: () -> Fallback) {
    self.init(
      url: url,
      placeholder: { EmptyView() },
      fallback: fallback
    )
  }

  /// Creates a network image with a fallback image.
  /// - Parameters:
  ///   - url: The URL where the image is located.
  ///   - fallbackImage: The name of the image resource to display when the URL is `nil` or an error has occurred.
  public init(url: URL?, fallbackImage name: String) where Fallback == Image {
    self.init(
      url: url,
      placeholder: { EmptyView() },
      fallback: { Image(name) }
    )
  }

  /// Creates a network image with a fallback system image.
  /// - Parameters:
  ///   - url: The URL where the image is located.
  ///   - fallbackSystemImage: The name of the system image to display when the URL is `nil`
  ///     or an error has occurred.
  @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
  public init(url: URL?, fallbackSystemImage name: String) where Fallback == Image {
    self.init(
      url: url,
      placeholder: { EmptyView() },
      fallback: { Image(systemName: name) }
    )
  }
}

extension View {
  /// Sets the image loader for network images within this view.
  public func networkImageLoader(_ networkImageLoader: NetworkImageLoader) -> some View {
    environment(\.networkImageLoader, networkImageLoader)
  }
}

extension EnvironmentValues {
  public var networkImageLoader: NetworkImageLoader {
    get { self[NetworkImageLoaderKey.self] }
    set { self[NetworkImageLoaderKey.self] = newValue }
  }
}

private struct NetworkImageLoaderKey: EnvironmentKey {
  static let defaultValue: NetworkImageLoader = .shared
}
