import Combine
import CombineSchedulers
import SwiftUI

final class NetworkImageViewModel: ObservableObject {
  struct Environment {
    var transaction: Transaction
    var imageLoader: NetworkImageLoader
  }

  enum State: Equatable {
    case notRequested
    case loading
    case success(Image, CGSize)
    case failure

    var image: Image? {
      guard case .success(let image, _) = self else {
        return nil
      }
      return image
    }
  }

  @Published private(set) var state: State = .notRequested
  private var cancellable: AnyCancellable?

  func onAppear(url: URL?, scale: CGFloat, environment: Environment) {
    guard case .notRequested = state else {
      return
    }

    update(url: url, scale: scale, environment: environment)
  }

  private func update(url: URL?, scale: CGFloat, environment: Environment) {
    if let url = url {
      state = .loading
      cancellable = environment.imageLoader.image(for: url, scale: scale)
        .map { .success(.init(platformImage: $0), $0.size) }
        .replaceError(with: .failure)
        .receive(on: UIScheduler.shared)
        .sink { [weak self] state in
          withTransaction(environment.transaction) {
            self?.state = state
          }
        }
    } else {
      cancellable = nil
      state = .failure
    }
  }
}
