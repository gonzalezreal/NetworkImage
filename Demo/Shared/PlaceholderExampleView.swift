import NetworkImage
import SwiftUI

struct PlaceholderExampleView: View {
  private let url = URL(string: "https://picsum.photos/id/1025/300/200")
  private let invalidURL = URL(string: "https://example.com")

  private func exampleImage(url: URL?) -> some View {
    NetworkImage(url: url, transaction: .init(animation: .default)) { state in
      switch state {
      case .empty:
        ProgressView()
      case .success(let image, _):
        image
      case .failure:
        Image(systemName: "photo.fill")
          .imageScale(.large)
          .blendMode(.overlay)
      }
    }
    .frame(width: 200, height: 200)
    .background(Color.secondary.opacity(0.25))
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }

  private var content: some View {
    VStack(spacing: 8) {
      Text("This example uses a custom image loader that delays the loading of images.")
        .padding()

      self.exampleImage(url: self.url)
      self.exampleImage(url: self.invalidURL)
    }
    .navigationTitle("Placeholders and fallbacks")
    .networkImageLoader(DelayNetworkImageLoader(delay: 2))
  }

  var body: some View {
    #if os(iOS)
      content.navigationBarTitleDisplayMode(.inline)
    #else
      content
    #endif
  }
}

private final class DelayNetworkImageLoader: NetworkImageLoader {
  private let delay: TimeInterval

  init(delay: TimeInterval) {
    self.delay = delay
  }

  func image(with source: ImageSource) async throws -> PlatformImage {
    try await Task.sleep(nanoseconds: UInt64(self.delay * 1_000_000_000))
    return try await DefaultNetworkImageLoader.shared.image(with: source)
  }
}
