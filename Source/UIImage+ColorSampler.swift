//
//  UIImage+ColorSampler.swift
//
// Copyright (c) 2015 Miles Hollingsworth
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
//

import UIKit

enum ColorSamplingError: ErrorType {
    case InvalidSampleCount
    case InvalidSamplingArea
}

extension UIImage {
    /**
     Samples colors from an image to find up to `count` prominent colors from the image
     
     - parameter count: The maximum number of colors to be returned
     
     - throws: `ColorSamplingError.InvalidSampleCount` if `count` is less than or equal to 0
     
     - returns: An optional array of UIColors with a maximum length of count.  Fewer colors will be returned if there are less than `count` colors in the sampled image.
     */
    public func sampleColors(count: Int, colorDepth: Int = 4) throws -> [UIColor]? {
        guard count > 0 else {
            throw ColorSamplingError.InvalidSampleCount
        }
        
        let octree = ColorOctree(colorDepth: colorDepth)
        let pixelColors = pixelColorData()
        
        for color in pixelColors {
            octree.insertColor(color)
        }
        
        return octree.quantizeToColorCount(count)
    }
    
    /**
     Samples colors from a subregion of an image to find up to `count` prominent colors from the image
     
     - parameter count: The maximum number of colors to be returned
     - parameter rect:  The subregion of the image to be sampled
     
     - throws: `ColorSamplingError.InvalidSampleCount` if `count` is less than or equal to 0
                `ColorSamplingError.InvalidSamplingArea` if `rect` is not contained within the bounds of the image
     
     - returns: An optional array of UIColors with a maximum length of `count`.  Fewer colors will be returned if there are less than `count` colors in the sampled image area.
     */
    public func sampleColors(count: Int, rect: CGRect, colorDepth: Int = 4) throws -> [UIColor]? {
        let bounds = CGRectMake(0, 0, size.width, size.height)
        if (CGRectContainsRect(bounds, rect)) {
            let croppedCgImage = CGImageCreateWithImageInRect(CGImage, rect)
            let croppedImage = UIImage(CGImage: croppedCgImage!)
            
            return try croppedImage.sampleColors(count, colorDepth: colorDepth)
        }
        
        return nil
    }
    
    /**
     Transforms an image into an array of unsigned 32bit integers describing raw pixel data
     
     - returns: An array of UInt32 containing RGBA pixel data
     */
    private func pixelColorData() -> [UInt32] {
        let cgImage = self.CGImage
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitsPerPixel = 32, bitsPerComponent = 8, bytesPerPixel = bitsPerPixel/8
        let width = CGImageGetWidth(cgImage), height = CGImageGetHeight(cgImage)
        let bytesPerRow = width * bytesPerPixel
        let bufferLength = width * height
        
        let bitmapData = UnsafeMutablePointer<UInt32>.alloc(bufferLength)
        let context = CGBitmapContextCreate(bitmapData, width, height, bitsPerComponent, bytesPerRow, colorSpace, 1)
        
        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)), cgImage)
        
        return Array(UnsafeBufferPointer(start: bitmapData, count: bufferLength))
    }
}



