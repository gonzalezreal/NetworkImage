//: [Previous](@previous)

import PlaygroundSupport
import SwiftUI

import NetworkImage

/*:
 You can customize a network image's appearance by using a network image style. The default image style is an instance of `ResizableNetworkImageStyle` configured to `fill` the available space. To set a specific style for all network images within a view, you can use the `networkImageStyle(_:)` modifier.
 */

struct ContentView: View {
    var body: some View {
        HStack {
            NetworkImage(url: URL(string: "https://picsum.photos/id/1025/300/200"))
                .frame(width: 200, height: 200)
            NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
                .frame(width: 200, height: 200)
        }
        .networkImageStyle(
            ResizableNetworkImageStyle(
                backgroundColor: .yellow,
                contentMode: .fit
            )
        )
    }
}

//: [Next](@next)

PlaygroundPage.current.setLiveView(
    ContentView().frame(width: 500, height: 500)
)
