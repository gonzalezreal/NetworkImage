//
// ImageDecoding.swift
//
// Copyright (c) 2020 Guille Gonzalez
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit

    #if os(watchOS)
        import WatchKit
    #endif

    public typealias Image = UIImage

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

    public typealias Image = NSImage

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
