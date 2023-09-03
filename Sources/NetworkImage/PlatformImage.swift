import SwiftUI

#if canImport(UIKit)
  public typealias PlatformImage = UIImage
#elseif os(macOS)
  public typealias PlatformImage = NSImage
#endif

extension PlatformImage {
  static func decoding(data: Data, scale: CGFloat) -> PlatformImage? {
    #if canImport(UIKit)
      return .init(data: data, scale: scale)
    #elseif os(macOS)
      guard let bitmapImageRep = NSBitmapImageRep(data: data) else {
        return nil
      }

      let image = NSImage(
        size: NSSize(
          width: bitmapImageRep.pixelsWide,
          height: bitmapImageRep.pixelsHigh
        )
      )

      image.addRepresentation(bitmapImageRep)
      return image
    #endif
  }
}

extension Image {
  init(platformImage: PlatformImage) {
    #if canImport(UIKit)
      self.init(uiImage: platformImage)
    #elseif os(macOS)
      self.init(nsImage: platformImage)
    #endif
  }
}
