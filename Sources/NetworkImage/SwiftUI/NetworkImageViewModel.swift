import Combine
import CombineSchedulers
import SwiftUI

final class NetworkImageViewModel {
  struct Context {
    var transaction: Transaction
    var imageLoader: NetworkImageLoader
  }

  enum State: Equatable {
    case empty
    case success(URL, CGFloat, Image)
    case failure

    var url: URL? {
      guard case .success(let url, _, _) = self else {
        return nil
      }
      return url
    }

    var scale: CGFloat? {
      guard case .success(_, let scale, _) = self else {
        return nil
      }
      return scale
    }

    var image: Image? {
      guard case .success(_, _, let image) = self else {
        return nil
      }
      return image
    }
  }

  @Published private(set) var state: State = .empty
  private var cancellable: AnyCancellable?

  func update(url: URL?, scale: CGFloat, context: Context) {
    guard let url = url else {
      withTransaction(context.transaction) {
        self.state = .failure
      }
      return
    }

    guard url != self.state.url || scale != self.state.scale else {
      return
    }

    self.cancellable = context.imageLoader.image(for: url, scale: scale)
      .map { .success(url, scale, .init(platformImage: $0)) }
      .replaceError(with: .failure)
      .receive(on: UIScheduler.shared)
      .sink { [weak self] state in
        withTransaction(context.transaction) {
          self?.state = state
        }
      }
  }
}
