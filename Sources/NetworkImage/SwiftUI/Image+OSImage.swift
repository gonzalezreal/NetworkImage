#if canImport(SwiftUI)
    import SwiftUI

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public extension Image {
        init(osImage: OSImage) {
            #if os(iOS) || os(tvOS) || os(watchOS)
                self.init(uiImage: osImage)
            #elseif os(macOS)
                self.init(nsImage: osImage)
            #endif
        }
    }
#endif
