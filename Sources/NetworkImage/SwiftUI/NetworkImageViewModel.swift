import Combine
import CombineSchedulers
import SwiftUI

final class NetworkImageViewModel: ObservableObject {
  struct Context {
    var transaction: Transaction
    var imageLoader: NetworkImageLoader
  }

  enum State: Equatable {
    case empty(url: URL, scale: CGFloat)
    case success(Image)
    case failure

    var image: Image? {
      guard case .success(let image) = self else {
        return nil
      }
      return image
    }
  }

  @Published private(set) var state: State
  private var cancellable: AnyCancellable?

  init(url: URL?, scale: CGFloat) {
    if let url = url {
      self.state = .empty(url: url, scale: scale)
    } else {
      self.state = .failure
    }
  }

  func onAppear(context: Context) {
    guard case .empty(let url, let scale) = self.state else {
      return
    }

    self.cancellable = context.imageLoader.image(for: url, scale: scale)
      .map { .success(.init(platformImage: $0)) }
      .replaceError(with: .failure)
      .receive(on: UIScheduler.shared)
      .sink { [weak self] state in
        withTransaction(context.transaction) {
          self?.state = state
        }
      }
  }
}
