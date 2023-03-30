// Image+Trim.swift
//
// Copyright © 2020 Christopher Zielinski.
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// https://gist.github.com/chriszielinski/aec9a2f2ba54745dc715dd55f5718177
// Modified to work on black/white mask images

import CoreGraphics

extension CGImage {

    var rect: CGRect {
        CGRect(origin: .zero, size: CGSize(width: self.width, height: self.height))
    }
    
    func trimmedRect(minBlackValue: UInt8 = 80) -> CGRect {
        return _CGImageTrimCalculator(image: self, minBlackValue: minBlackValue)?.trimedRect() ?? rect
    }
    
}

private struct _CGImageTrimCalculator {

    let image: CGImage
    let minBlackValue: UInt8
    let cgContext: CGContext
    let zeroByteBlock: UnsafeMutableRawPointer
    let pixelRowRange: Range<Int>
    let pixelColumnRange: Range<Int>

    init?(image: CGImage, minBlackValue: UInt8) {
        guard let cgContext = CGContext(data: nil,
                                        width: image.width,
                                        height: image.height,
                                        bitsPerComponent: 8,
                                        bytesPerRow: 0,
                                        space: CGColorSpaceCreateDeviceGray(),
                                        bitmapInfo: CGImageAlphaInfo.none.rawValue),
            cgContext.data != nil
            else { return nil }

        cgContext.draw(image, in: image.rect)

        guard let zeroByteBlock = calloc(image.width, MemoryLayout<UInt8>.size)
            else { return nil }

        self.image = image
        self.minBlackValue = minBlackValue
        self.cgContext = cgContext
        self.zeroByteBlock = zeroByteBlock

        pixelRowRange = 0..<image.height
        pixelColumnRange = 0..<image.width
    }

    func trimedRect() -> CGRect? {
        guard let topInset = firstOpaquePixelRow(in: pixelRowRange),
            let bottomOpaqueRow = firstOpaquePixelRow(in: pixelRowRange.reversed()),
            let leftInset = firstOpaquePixelColumn(in: pixelColumnRange),
            let rightOpaqueColumn = firstOpaquePixelColumn(in: pixelColumnRange.reversed())
            else { return nil }

        let bottomInset = (image.height - 1) - bottomOpaqueRow
        let rightInset = (image.width - 1) - rightOpaqueColumn

        guard !(topInset == 0 && bottomInset == 0 && leftInset == 0 && rightInset == 0)
        else { return nil }

        let origin = CGPoint(x: leftInset, y: topInset)
        let width = image.width - (leftInset + rightInset)
        let height = image.height - (topInset + bottomInset)
        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }

    @inlinable
    func isPixelOpaque(column: Int, row: Int) -> Bool {
        // Sanity check: It is safe to get the data pointer in iOS 4.0+ and macOS 10.6+ only.
        guard let data = cgContext.data else {
            assertionFailure("_CGImageTransparencyTrimmer.isPixelOpaque context data is nil!")
            return true
        }
        return data.load(fromByteOffset: (row * cgContext.bytesPerRow) + column, as: UInt8.self)
            < minBlackValue
    }

    @inlinable
    func isPixelRowTransparent(_ row: Int) -> Bool {
        assert(cgContext.data != nil)
        // `memcmp` will efficiently check if the entire pixel row has zero alpha values
        return memcmp(cgContext.data! + (row * cgContext.bytesPerRow), zeroByteBlock, image.width) == 0
            // When the entire row is NOT zeroed, we proceed to check each pixel's alpha
            // value individually until we locate the first "opaque" pixel (very ~not~ efficient).
            || !pixelColumnRange.contains(where: { isPixelOpaque(column: $0, row: row) })
    }

    @inlinable
    func firstOpaquePixelRow<T: Sequence>(in rowRange: T) -> Int? where T.Element == Int {
        return rowRange.first(where: { !isPixelRowTransparent($0) })
    }

    @inlinable
    func firstOpaquePixelColumn<T: Sequence>(in columnRange: T) -> Int? where T.Element == Int {
        return columnRange.first(where: { column in
            pixelRowRange.contains(where: { isPixelOpaque(column: column, row: $0) })
        })
    }

}
