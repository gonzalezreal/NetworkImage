import NetworkImage
import SwiftUI

struct SimpleExampleView: View {
    private var content: some View {
        VStack {
            NetworkImage(url: URL(string: "https://picsum.photos/id/1025/300/200"))
                .scaledToFill()
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
                .scaledToFill()
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
//        .animation(.default)
        .navigationTitle("Displaying Network Images")
    }

    var body: some View {
        #if os(iOS)
            content.navigationBarTitleDisplayMode(.inline)
        #else
            content
        #endif
    }
}
