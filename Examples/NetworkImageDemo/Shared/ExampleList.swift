import SwiftUI

struct ExampleList: View {
    var body: some View {
        List {
            NavigationLink("Displaying Network Images", destination: SimpleExampleView())
            NavigationLink("Styling Network Images", destination: StyleExampleView())
            NavigationLink("Placeholders and fallbacks", destination: PlaceholderExampleView())

            #if os(iOS)
                NavigationLink(
                    "Using ImageDownloader",
                    destination: ImageDownloaderExampleView()
                        .navigationTitle("Using ImageDownloader")
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
