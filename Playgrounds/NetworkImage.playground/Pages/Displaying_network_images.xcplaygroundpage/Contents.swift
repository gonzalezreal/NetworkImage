//: [Previous](@previous)

import PlaygroundSupport
import SwiftUI

import NetworkImage

/*:
 You can use a `NetworkImage` view to display an image from a given URL. The download happens asynchronously, and the resulting image is cached both in disk and memory.
 */

struct ContentView: View {
    var body: some View {
        NetworkImage(url: URL(string: "https://picsum.photos/id/237/300/200"))
            .frame(width: 300, height: 200)
    }
}

/*:
 By default, remote images are resizable and fill the available space while maintaining the aspect ratio.
 */
//: [Next](@next)

PlaygroundPage.current.setLiveView(
    ContentView().frame(width: 500, height: 500)
)
