//
//  ShadowLabel.swift
//  Seth Rininger
//
//  Created by Seth Rininger on 7/14/17.
//  Copyright © 2017 Seth Rininger. All rights reserved.
//

import UIKit

@IBDesignable
class ShadowLabel: UILabel {

    @IBInspectable
    public var labelColor: UIColor = .black {
        didSet {
            configureView()
        }
    }

    @IBInspectable
    public var opacity: Float = 1 {
        didSet {
            configureView()
        }
    }

    @IBInspectable
    public var offset: CGSize = .zero {
        didSet {
            configureView()
        }
    }

    @IBInspectable
    public var radius: CGFloat = 1 {
        didSet {
            configureView()
        }
    }

    override public class var layerClass: AnyClass {
        return CALayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }

    func configureView() {
        layer.shadowColor = labelColor.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }

}
