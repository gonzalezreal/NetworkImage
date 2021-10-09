import SwiftUI

extension Image {
  public init(osImage: OSImage) {
    #if os(iOS) || os(tvOS) || os(watchOS)
      self.init(uiImage: osImage)
    #elseif os(macOS)
      self.init(nsImage: osImage)
    #endif
  }
}
