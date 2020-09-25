//: [Previous](@previous)

import PlaygroundSupport
import SwiftUI

import NetworkImage

/*:
 To add a custom appearance, create a type that conforms to the `NetworkImageStyle` protocol. You can customize a network image's appearance in all of its different states: loading, displaying an image or failed.
 */

struct RoundedImageStyle: NetworkImageStyle {
    var width: CGFloat?
    var height: CGFloat?

    func makeBody(state: NetworkImageState) -> some View {
        ZStack {
            Color(.secondarySystemBackground)

            switch state {
            case .loading:
                EmptyView()
            case let .image(image, _):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failed:
                Image(systemName: "photo")
                    .foregroundColor(Color(.systemFill))
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

/*:
 Then set the custom style for all network images within a view, using the `networkImageStyle(_:)` modifier:
 */

struct ContentView: View {
    var body: some View {
        HStack {
            NetworkImage(url: URL(string: "https://picsum.photos/id/1025/300/200"))
            NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
        }
        .networkImageStyle(
            RoundedImageStyle(width: 200, height: 200)
        )
    }
}

//: [Next](@next)

PlaygroundPage.current.setLiveView(
    ContentView().frame(width: 500, height: 500)
)
