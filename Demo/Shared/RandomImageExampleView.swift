import NetworkImage
import SwiftUI

struct RandomImageExampleView: View {
  private let identifiers = [
    "0", "1", "10", "100", "1000", "1001",
    "1002", "1003", "1004", "1005", "1006",
    "1008", "1009", "101", "1010", "1011",
    "1012", "1013", "1014", "1015", "1016",
    "1018", "1019", "102", "1020", "1021",
    "1022", "1023", "1024", "1025",
  ]

  @State var url: URL?

  private var content: some View {
    VStack {
      NetworkImage(url: self.url)
        .scaledToFill()
        .frame(width: 200, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 8))
      Button("Random Image") {
        if let id = self.identifiers.randomElement() {
          self.url = URL(string: "https://picsum.photos/id/\(id)/300/200")
        }
      }
    }
    .navigationTitle("Random Image")
  }

  var body: some View {
    #if os(iOS)
      content.navigationBarTitleDisplayMode(.inline)
    #else
      content
    #endif
  }
}

struct RandomImageExampleView_Previews: PreviewProvider {
  static var previews: some View {
    RandomImageExampleView()
  }
}
