import NetworkImage
import SwiftUI

struct ImageListExampleView: View {
  private let urls = [
    URL(string: "https://image.tmdb.org/t/p/w780/srYya1ZlI97Au4jUYAktDe3avyA.jpg")!,
    URL(string: "https://image.tmdb.org/t/p/w780/kf456ZqeC45XTvo6W9pW5clYKfQ.jpg")!,
    URL(string: "https://image.tmdb.org/t/p/w780/ibwOX4xUndc6E90MYfglghWvO5Z.jpg")!,
    URL(string: "https://image.tmdb.org/t/p/w780/aHYUj0hICtWZ5tPiCIm6pWUcjYK.jpg")!,
    URL(string: "https://image.tmdb.org/t/p/w780/fX8e94MEWSuTJExndVYxKsmA4Hw.jpg")!,
    URL(string: "https://image.tmdb.org/t/p/w780/yR27bZPIkNhpGEIP3jKV2EifTgo.jpg")!,
    URL(string: "https://image.tmdb.org/t/p/w780/9pHxv7TX0jOKNgnGMDP6RJ2m1GL.jpg")!,
    URL(string: "https://image.tmdb.org/t/p/w780/z15NpieRw7jL7bKoICwLO5j7FgZ.jpg")!,
    URL(string: "https://image.tmdb.org/t/p/w780/cjaOSjsjV6cl3uXdJqimktT880L.jpg")!,
    URL(string: "https://image.tmdb.org/t/p/w780/dueiWzWc81UAgnbDAyH4Gjqnh4n.jpg")!,
  ]

  private var content: some View {
    ScrollView {
      LazyVStack {
        ForEach(urls, id: \.self) { url in
          NetworkImage(url: url)
            .aspectRatio(1.778, contentMode: .fill)
            .background(Color.secondary.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
              RoundedRectangle(cornerRadius: 4)
                .strokeBorder(Color.primary.opacity(0.25), lineWidth: 0.5)
            )
        }
      }
      .padding()
    }
    .navigationTitle("Image List")
  }

  var body: some View {
    #if os(iOS)
      content.navigationBarTitleDisplayMode(.inline)
    #else
      content
    #endif
  }
}

struct ImageListExampleView_Previews: PreviewProvider {
  static var previews: some View {
    ImageListExampleView()
  }
}
