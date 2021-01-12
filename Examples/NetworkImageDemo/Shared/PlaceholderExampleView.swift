import NetworkImage
import SwiftUI

struct PlaceholderExampleView: View {
    private var content: some View {
        VStack(spacing: 8) {
            Text("This example is using a delay proxy to simulate the slow loading of images.")
                .padding()

            NetworkImage(url: URL(string: "https://deelay.me/2000/https://picsum.photos/id/1025/300/200")) {
                ProgressView()
            } fallback: {
                Image(systemName: "photo.fill")
                    .imageScale(.large)
                    .blendMode(.overlay)
            }
            .scaledToFill()
            .frame(width: 200, height: 200)
            .background(Color.secondary.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            NetworkImage(url: URL(string: "https://deelay.me/2000/https://example.com")) {
                ProgressView()
            } fallback: {
                Image(systemName: "photo.fill")
                    .imageScale(.large)
                    .blendMode(.overlay)
            }
            .scaledToFill()
            .frame(width: 200, height: 200)
            .background(Color.secondary.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .animation(.default)
        .navigationTitle("Placeholders and fallbacks")
    }

    var body: some View {
        #if os(iOS)
            content.navigationBarTitleDisplayMode(.inline)
        #else
            content
        #endif
    }
}
