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

    let pixelThinner = 5

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

        findColors(image) { [weak self] imageColors in
            guard let sSelf = self else { return }
            var (primaryColor, secondaryColor, detailColor) = sSelf.findMainColors(imageColors)

            if primaryColor == nil { primaryColor = .black }
            if secondaryColor == nil { secondaryColor = .white }
            if detailColor == nil { detailColor = .white }

            sSelf.view.backgroundColor = primaryColor
            sSelf.primaryLabel.textColor = primaryColor
            sSelf.secondaryLabel.textColor = secondaryColor
            sSelf.detailLabel.textColor = detailColor
        }
    }

    func findColors(_ image: UIImage, completion: @escaping ([String: Int]) -> Void) {
        guard let pixelData = image.cgImage?.dataProvider?.data else { completion([:]); return }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        var countedColors: [String: Int] = [:]

        let pixelsWide = Int(image.size.width * image.scale)
        let pixelsHigh = Int(image.size.height * image.scale)

        //  let widthRange = 0..<pixelsWide
        //  let heightRange = 0..<pixelsHigh

        let widthThinner = Int(pixelsWide / pixelThinner) + 1
        let heightThinner = Int(pixelsHigh / pixelThinner) + 1
        let widthRange = stride(from: 0, to: pixelsWide, by: widthThinner)
        let heightRange = stride(from: 0, to: pixelsHigh, by: heightThinner)

        for x in widthRange {
            for y in heightRange {
                let pixelInfo: Int = ((pixelsWide * y) + x) * 4
                let color = "\(data[pixelInfo]).\(data[pixelInfo + 1]).\(data[pixelInfo + 2])"
                if countedColors[color] == nil {
                    countedColors[color] = 0
                } else {
                    countedColors[color]! += 1
                }
            }
        }

        completion(countedColors)
    }

    func findMainColors(_ colors: [String: Int]) -> (UIColor?, UIColor?, UIColor?) {

        var primaryColor: UIColor?, secondaryColor: UIColor?, detailColor: UIColor?
        for (colorString, _) in colors.sorted(by: { $0.value > $1.value }) {
            let colorParts: [String] = colorString.components(separatedBy: ".")
            let color: UIColor = UIColor(red: CGFloat(Int(colorParts[0])!) / 255,
                                         green: CGFloat(Int(colorParts[1])!) / 255,
                                         blue: CGFloat(Int(colorParts[2])!) / 255,
                                         alpha: 1).color(withMinimumSaturation: 0.15)

            guard !color.isBlackOrWhite() else { continue }
            if primaryColor == nil {
                primaryColor = color
            } else if secondaryColor == nil {
                if primaryColor!.isDistinct(color) {
                    secondaryColor = color
                }
            } else if detailColor == nil {
                if secondaryColor!.isDistinct(color) && primaryColor!.isDistinct(color) {
                    detailColor = color
                    break
                }
            }
        }
        return (primaryColor, secondaryColor, detailColor)
    }
}
