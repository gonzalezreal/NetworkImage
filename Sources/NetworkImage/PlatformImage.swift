import SwiftUI

#if canImport(UIKit)
  /// An object that manages image data.
  ///
  /// `PlatformImage` is a type alias for the type that the platform uses to manage image data.
  public typealias PlatformImage = UIImage
#elseif os(macOS)
  /// An object that manages image data.
  ///
  /// `PlatformImage` is a type alias for the type that the platform uses to manage image data.
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
