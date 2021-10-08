import SwiftUI

public extension Image {
    init(osImage: OSImage) {
        #if os(iOS) || os(tvOS) || os(watchOS)
            self.init(uiImage: osImage)
        #elseif os(macOS)
            self.init(nsImage: osImage)
        #endif
    }
}
