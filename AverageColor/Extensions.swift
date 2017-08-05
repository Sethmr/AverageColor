//
//  Extensions.swift
//  AverageColor
//
//  Created by Seth Rininger on 8/5/17.
//  Copyright © 2017 Vimvest. All rights reserved.
//

import UIKit

extension UIImage {

    func areaAverage() -> UIColor {
        var bitmap = [UInt8](repeating: 0, count: 4)

        // Get average color.
        let context = CIContext()
        let inputImage: CIImage = ciImage ?? CoreImage.CIImage(cgImage: cgImage!)
        let extent = inputImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
        let outputImage = filter.outputImage!
        let outputExtent = outputImage.extent
        assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)

        // Render to bitmap.
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())

        // Compute result.
        let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
        return result
    }

}

extension UIColor {

    var coreImageColor: CIColor {
        return CIColor(color: self)
    }

    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }

    func isDarkColor() -> Bool {
        let luminate: CGFloat = 0.2126 * components.red + 0.7152 * components.green + 0.0722 * components.blue
        if luminate < 0.5 { return true }
        return false
    }

    func isDistinct(_ compareColor: UIColor) -> Bool {

        let (r, g, b, a) = components
        let (r1, g1, b1, a1) = compareColor.components

        let threshold1: CGFloat = 0.25
        guard fabs(r - r1) > threshold1 ||
              fabs(g - g1) > threshold1 ||
              fabs(b - b1) > threshold1 ||
              fabs(a - a1) > threshold1 else { return false }

        // check for grays, prevent multiple gray colors
        let threshold2: CGFloat = 0.03
        guard fabs( r - g ) < threshold2 &&
              fabs( r - b ) < threshold2 &&
              fabs(r1 - g1) < threshold2 &&
              fabs(r1 - b1) < threshold2 else { return true }

        return false
    }

    func color(withMinimumSaturation minSaturation: CGFloat) -> UIColor {

        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        if saturation < minSaturation {
            return UIColor(hue: hue, saturation: minSaturation, brightness: brightness, alpha: alpha)
        } else {
            return self
        }
    }

    func isBlackOrWhite() -> Bool {

        let (r, g, b, _) = components

        // isWhite
        if r > 0.91 &&
            g > 0.91 &&
            b > 0.91 {
            return true
        }

        // isBlack
        if r < 0.09 &&
            g < 0.09 &&
            b < 0.09 {
            return true
        }

        return false
    }

    func isContrastingColor(_ color: UIColor) -> Bool {

        let (r, g, b, _) = components
        let (r2, g2, b2, _) = color.components

        let bLum: CGFloat = 0.2126 * r + 0.7152 * g + 0.0722 * b
        let fLum: CGFloat = 0.2126 * r2 + 0.7152 * g2 + 0.0722 * b2

        var contrast: CGFloat = 0.0
        if bLum > fLum {
            contrast = (bLum + 0.05) / (fLum + 0.05)
        } else {
            contrast = (fLum + 0.05) / (bLum + 0.05)
        }
        //return contrast > 3.0; //3-4.5 W3C recommends a minimum ratio of 3:1
        return contrast > 1.6
    }
    
}
