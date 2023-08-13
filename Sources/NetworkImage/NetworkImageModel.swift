import SwiftUI

final class NetworkImageModel: ObservableObject {
  struct Environment {
    let transaction: Transaction
    let imageLoader: NetworkImageLoader
  }

  struct State: Equatable {
    var source: ImageSource?
    var image: NetworkImageState = .empty
  }

  @Published private(set) var state: State = .init()

  @MainActor func onAppear(source: ImageSource?, environment: Environment) async {
    guard source != self.state.source else { return }

    guard let source else {
      self.state = .init()
      return
    }

    self.state.source = source
    self.state.image = .empty

    let image: NetworkImageState

    do {
      let platformImage = try await environment.imageLoader.image(with: source)
      image = .success(image: .init(platformImage: platformImage), idealSize: platformImage.size)
    } catch {
      image = .failure
    }

    withTransaction(environment.transaction) {
      self.state.image = image
    }
  }
}
