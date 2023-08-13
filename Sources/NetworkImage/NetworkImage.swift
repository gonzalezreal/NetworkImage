import SwiftUI

/// A view that displays an image located at a given URL.
///
/// A network image downloads and displays an image from a given URL; the download is asynchronous,
/// and the result is cached both in disk and memory.
///
/// You create a network image, in its simplest form, by providing the image URL.
///
///     NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
///       .frame(width: 300, height: 200)
///
/// To manipulate the loaded image, use the `content` parameter.
///
///     NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200")) { image in
///       image.resizable().scaledToFill()
///     }
///     .frame(width: 150, height: 150)
///     .clipped()
///
/// The view displays a standard placeholder that fills the available space until the image loads. You can
/// specify a custom placeholder by using the `placeholder` parameter.
///
///     NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200")) { image in
///       image.resizable().scaledToFill()
///     } placeholder: {
///       Color.yellow // Shown while the image is loaded or an error occurs
///     }
///     .frame(width: 150, height: 150)
///     .clipped()
///
/// It is also possible to specify a custom fallback placeholder that the view will display if there is an
/// error or the URL is `nil`.
///
///     NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200")) { image in
///       image.resizable().scaledToFill()
///     } placeholder: {
///       ProgressView() // Shown while the image is loaded
///     } fallback: {
///       Image(systemName: "photo") // Shown when an error occurs or the URL is nil
///     }
///     .frame(width: 150, height: 150)
///     .clipped()
///     .background(Color.yellow)
///
public struct NetworkImage<Content>: View where Content: View {
  @Environment(\.networkImageLoader) private var imageLoader
  @StateObject private var model = NetworkImageModel()

  private let source: ImageSource?
  private let transaction: Transaction
  private let content: (NetworkImageState) -> Content

  private var environment: NetworkImageModel.Environment {
    .init(transaction: self.transaction, imageLoader: self.imageLoader)
  }

  /// Loads and displays an image from the specified URL using
  /// a default placeholder until the image loads.
  ///
  /// - Parameters:
  ///   - url: The URL of the image to display.
  ///   - scale: The scale to use for the image. The default is `1`.
  public init(url: URL?, scale: CGFloat = 1) where Content == _OptionalContent<Image> {
    self.init(url: url, scale: scale) { state in
      _OptionalContent(state.image)
    }
  }

  /// Loads and displays a modifiable image from the specified URL using a
  /// default placeholder until the image loads.
  ///
  /// - Parameters:
  ///   - url: The URL where the image is located.
  ///   - scale: The scale to use for the image. The default is `1`.
  ///   - transaction: The transaction to use when the state changes.
  ///   - content: A closure that takes the loaded image as an input, and
  ///     returns the view to show. You can return the image directly, or
  ///     modify it as needed before returning it.
  public init<I>(
    url: URL?,
    scale: CGFloat = 1,
    transaction: Transaction = .init(),
    @ViewBuilder content: @escaping (Image) -> I
  ) where Content == _OptionalContent<I>, I: View {
    self.init(url: url, scale: scale, transaction: transaction) { state in
      _OptionalContent(state.image, content: content)
    }
  }

  /// Loads and displays a modifiable image from the specified URL using a
  /// custom placeholder until the image loads.
  ///
  /// - Parameters:
  ///   - url: The URL where the image is located.
  ///   - scale: The scale to use for the image. The default is `1`.
  ///   - transaction: The transaction to use when the state changes.
  ///   - content: A closure that takes the loaded image as an input, and
  ///     returns the view to show. You can return the image directly, or
  ///     modify it as needed before returning it.
  ///   - placeholder: A closure that returns the view to display while the image is loading.
  public init<I, P>(
    url: URL?,
    scale: CGFloat = 1,
    transaction: Transaction = .init(),
    @ViewBuilder content: @escaping (Image) -> I,
    @ViewBuilder placeholder: @escaping () -> P
  ) where Content == _ConditionalContent<I, P>, I: View, P: View {
    self.init(
      url: url,
      scale: scale,
      transaction: transaction,
      content: { state in
        if let image = state.image {
          content(image)
        } else {
          placeholder()
        }
      }
    )
  }

  public init(
    url: URL?,
    scale: CGFloat = 1,
    transaction: Transaction = .init(),
    @ViewBuilder content: @escaping (NetworkImageState) -> Content
  ) {
    self.source = url.map { ImageSource(url: $0, scale: scale) }
    self.transaction = transaction
    self.content = content
  }

  public var body: some View {
    if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
      self.content(self.model.state.image)
        .task(id: self.source) {
          await self.model.onAppear(source: self.source, environment: self.environment)
        }
    } else {
      self.content(self.model.state.image)
        .modifier(
          TaskModifier(id: self.source) {
            await self.model.onAppear(source: self.source, environment: self.environment)
          }
        )
    }
  }
}

public struct _OptionalContent<Content>: View where Content: View {
  private let image: Image?
  private let content: (Image) -> Content

  init(_ image: Image?, content: @escaping (Image) -> Content) {
    self.image = image
    self.content = content
  }

  public var body: some View {
    if let image {
      self.content(image)
    } else {
      Image(platformImage: .init())
        .resizable()
        .redacted(reason: .placeholder)
    }
  }
}

extension _OptionalContent where Content == Image {
  init(_ image: Image?) {
    self.init(image, content: { $0 })
  }
}
