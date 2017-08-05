//
//  ViewController.swift
//  AverageColor
//
//  Created by Seth Rininger on 8/3/17.
//  Copyright © 2017 Seth Rininger. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    let numberOfImages = 15
    var images: [String]!

    var pointer: Int = 0 {
        didSet {
            if pointer < 0 { pointer = images.count - 1 }
            if pointer >= images.count { pointer = 0 }
        }
    }

    var imageFromPointer: UIImage {
        guard let image = UIImage(named: images[pointer]) else { fatalError() }
        return image
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        images = []
        for i in 0..<numberOfImages { images.append("\(i + 1)") }

        nextImage()
    }

    @IBAction func swipedLeft(_ sender: UISwipeGestureRecognizer) {
        previousImage()
    }

    @IBAction func swipedRight(_ sender: UISwipeGestureRecognizer) {
        nextImage()
    }

    @IBAction func nextButtonWasPressed(_ sender: UIButton) {
        nextImage()
    }

    func previousImage() {
        pointer -= 1
        analizeImage(imageFromPointer)
    }

    func nextImage() {
        pointer += 1
        analizeImage(imageFromPointer)
    }

    func analizeImage(_ image: UIImage) {

        imageView.image = image
        view.backgroundColor = image.areaAverage()

        let imageColors = findColors(image)
        var (primaryColor, secondaryColor, detailColor) = findMainColors(imageColors)

        if primaryColor == nil { primaryColor = .black }
        if secondaryColor == nil { secondaryColor = .white }
        if detailColor == nil { detailColor = .white }

        primaryLabel.textColor = primaryColor
        secondaryLabel.textColor = secondaryColor
        detailLabel.textColor = detailColor
    }

    func findColors(_ image: UIImage) -> [UIColor: Int] {

        let pixelsWide = Int(image.size.width)
        let pixelsHigh = Int(image.size.height)

        guard let pixelData = image.cgImage?.dataProvider?.data else { return [:] }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        var countedColors: [UIColor: Int] = [:]
        for x in 0..<pixelsWide {
            for y in 0..<pixelsHigh {
                let pixelInfo: Int = ((pixelsWide * y) + x) * 4
                let color = UIColor(red: CGFloat(data[pixelInfo]) / 255.0,
                                    green: CGFloat(data[pixelInfo + 1]) / 255.0,
                                    blue: CGFloat(data[pixelInfo + 2]) / 255.0,
                                    alpha: CGFloat(data[pixelInfo + 3]) / 255.0)
                if countedColors[color] == nil {
                    countedColors[color] = 0
                } else {
                    countedColors[color]! += 1
                }
            }
        }

        return countedColors
    }

    func findMainColors(_ colors: [UIColor: Int]) -> (UIColor?, UIColor?, UIColor?) {

        let sortedKeys = colors.sorted { $0.value > $1.value }
                                .map { $0.key.color(withMinimumSaturation: 0.15) }

        var primaryColor: UIColor?, secondaryColor: UIColor?, detailColor: UIColor?
        for color in sortedKeys {
            guard !color.isBlackOrWhite() else { continue }
            if primaryColor == nil {
                primaryColor = color
            } else if secondaryColor == nil {
                if !primaryColor!.isDistinct(color) {
                    continue
                }
                secondaryColor = color
            } else if detailColor == nil {
                if !secondaryColor!.isDistinct(color) || !primaryColor!.isDistinct(color) {
                    continue
                }
                detailColor = color
                break
            }
        }

        return (primaryColor, secondaryColor, detailColor)
    }
}
