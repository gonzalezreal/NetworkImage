#if !(os(iOS) && (arch(i386) || arch(arm))) && canImport(SwiftUI)

    import SwiftUI

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
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
