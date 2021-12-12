import SwiftUI

struct ExampleList: View {
  var body: some View {
    List {
      NavigationLink("Displaying Network Images", destination: SimpleExampleView())
      NavigationLink("Styling Network Images", destination: StyleExampleView())
      NavigationLink("Placeholders and fallbacks", destination: PlaceholderExampleView())
      NavigationLink("Random Image", destination: RandomImageExampleView())
      NavigationLink("Image List", destination: ImageListExampleView())

      #if os(iOS)
        NavigationLink(
          "UIKit (NetworkImageLoader)",
          destination: ImageLoaderExampleView()
            .navigationTitle("UIKit (NetworkImageLoader)")
            .navigationBarTitleDisplayMode(.inline)
        )
      #endif
    }
    .navigationTitle("NetworkImage")
  }
}

struct ExampleList_Previews: PreviewProvider {
  static var previews: some View {
    ExampleList()
  }
}
