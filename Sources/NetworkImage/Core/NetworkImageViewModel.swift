import Combine
import CombineSchedulers
import SwiftUI

final class NetworkImageViewModel: ObservableObject {
  struct Environment {
    var imageLoader: NetworkImageLoader
    var uiScheduler: AnySchedulerOf<UIScheduler>
  }

  enum State: Equatable {
    case empty
    case success(Image)
    case failure

    var image: Image? {
      guard case .success(let image) = self else {
        return nil
      }
      return image
    }
  }

  @Published private(set) var state: State?
  private var cancellable: AnyCancellable?

  init(state: State? = nil) {
    self.state = state
  }

  func onAppear(url: URL?, environment: Environment) {
    guard state == nil else { return }
    onURLChange(url: url, environment: environment)
  }

  func onURLChange(url: URL?, environment: Environment) {
    guard let url = url else {
      didFail()
      return
    }

    if let image = environment.imageLoader.cachedImage(for: url) {
      didLoadImage(image)
    } else {
      if state?.image == nil {
        state = .empty
      }

      cancellable = environment.imageLoader.image(for: url)
        .receive(on: environment.uiScheduler)
        .sink(
          receiveCompletion: { [weak self] completion in
            if case .failure = completion {
              self?.didFail()
            }
          },
          receiveValue: { [weak self] image in
            self?.didLoadImage(image)
          }
        )
    }
  }
}

extension NetworkImageViewModel {
  private func didLoadImage(_ image: OSImage) {
    #if os(iOS) || os(tvOS) || os(watchOS)
      state = .success(Image(uiImage: image))
    #elseif os(macOS)
      state = .success(Image(nsImage: image))
    #endif
  }

  private func didFail() {
    state = .failure
  }
}
