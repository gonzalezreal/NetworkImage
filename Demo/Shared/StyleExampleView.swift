import NetworkImage
import SwiftUI

struct StyleExampleView: View {
  private var content: some View {
    VStack {
      NetworkImage(url: URL(string: "https://picsum.photos/id/1025/300/200")) { image in
        image.grayscale(0.99)
      } placeholder: {
        Color.secondary.opacity(0.25)
      }
      .frame(width: 200, height: 200)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200")) { image in
        image.grayscale(0.99)
      } placeholder: {
        Color.secondary.opacity(0.25)
      }
      .frame(width: 200, height: 200)
      .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .navigationTitle("Styling Network Images")
  }

  var body: some View {
    #if os(iOS)
      content.navigationBarTitleDisplayMode(.inline)
    #else
      content
    #endif
  }
}
