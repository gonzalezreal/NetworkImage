import Combine
import CombineSchedulers
import Foundation

internal struct NetworkImageEnvironment {
  var imageLoader: NetworkImageLoader
  var mainQueue: AnySchedulerOf<DispatchQueue>
}

internal final class NetworkImageStore: ObservableObject {
  enum Action {
    case onAppear(environment: NetworkImageEnvironment)
    case didLoadImage(OSImage)
    case didFail
  }

  enum State: Equatable {
    case notRequested(URL)
    case placeholder
    case image(OSImage)
    case fallback
  }

  @Published private(set) var state: State
  private var cancellables: Set<AnyCancellable> = []

  init(url: URL?) {
    if let url = url {
      state = .notRequested(url)
    } else {
      state = .fallback
    }
  }

  func send(_ action: Action) {
    switch action {
    case let .onAppear(environment):
      guard case let .notRequested(url) = state else {
        return
      }
      if let image = environment.imageLoader.cachedImage(for: url) {
        state = .image(image)
      } else {
        state = .placeholder
        environment.imageLoader.image(for: url)
          .map { .didLoadImage($0) }
          .replaceError(with: .didFail)
          .receive(on: environment.mainQueue)
          .sink { [weak self] action in
            self?.send(action)
          }
          .store(in: &cancellables)
      }
    case let .didLoadImage(image):
      state = .image(image)
    case .didFail:
      state = .fallback
    }
  }
}
