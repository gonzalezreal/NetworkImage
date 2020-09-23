#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit

    #if os(watchOS)
        import WatchKit
    #endif

    public typealias OSImage = UIImage

    private func screenScale() -> CGFloat {
        #if os(watchOS)
            return WKInterfaceDevice.current().screenScale
        #else
            return UIScreen.main.scale
        #endif
    }

    internal func decodeImage(from data: Data) throws -> UIImage {
        guard let image = UIImage(data: data, scale: screenScale()) else {
            throw NetworkImageError.invalidData(data)
        }

        // Inflates the underlying compressed image data to be backed by an uncompressed bitmap representation.
        _ = image.cgImage?.dataProvider?.data

        return image
    }

#elseif os(macOS)
    import Cocoa

    public typealias OSImage = NSImage

    internal func decodeImage(from data: Data) throws -> NSImage {
        guard let bitmapImageRep = NSBitmapImageRep(data: data) else {
            throw NetworkImageError.invalidData(data)
        }

        let image = NSImage(
            size: NSSize(
                width: bitmapImageRep.pixelsWide,
                height: bitmapImageRep.pixelsHigh
            )
        )
        image.addRepresentation(bitmapImageRep)

        return image
    }
#endif
