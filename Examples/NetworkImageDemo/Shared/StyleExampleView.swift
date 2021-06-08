import NetworkImage
import SwiftUI

struct StyleExampleView: View {
    private var content: some View {
        VStack {
            NetworkImage(url: URL(string: "https://picsum.photos/id/1025/300/200"))
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
//        .animation(.default)
        .networkImageStyle(GrayscaleNetworkImageStyle())
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

struct GrayscaleNetworkImageStyle: NetworkImageStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.image
            .resizable()
            .scaledToFill()
            .grayscale(0.99)
    }
}
