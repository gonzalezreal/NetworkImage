import SwiftUI

public enum NetworkImageState: Equatable {
  case empty
  case success(image: Image, idealSize: CGSize)
  case failure

  public var image: Image? {
    guard case .success(let image, _) = self else {
      return nil
    }
    return image
  }
}
