//
//  GradientView.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/26/23.
//

import UIKit

class GradientView: UIView {
    
    open var gradientColors: (startColor: UIColor, endColor: UIColor) = (UIColor.white, UIColor.white) {
        didSet {
            (layer as? CAGradientLayer)?.colors = [gradientColors.startColor.resolvedColor(with: traitCollection).cgColor, gradientColors.endColor.resolvedColor(with: traitCollection).cgColor]
        }
    }

    @IBInspectable fileprivate var endColor: UIColor {
        get {
            return gradientColors.endColor
        }
        set {
            gradientColors = (self.gradientColors.startColor, newValue)
        }
    }

    @IBInspectable fileprivate var startColor: UIColor {
        get {
            return gradientColors.startColor
        }
        set {
            gradientColors = (newValue, self.gradientColors.endColor)
        }
    }

    @IBInspectable open var startPoint: CGPoint = CGPoint(x: 0, y: 0.5) {
        didSet {
            (layer as? CAGradientLayer)?.startPoint = startPoint
        }
    }

    @IBInspectable open var endPoint: CGPoint = CGPoint(x: 1, y: 0.5) {
        didSet {
            (layer as? CAGradientLayer)?.endPoint = endPoint
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        guard let theLayer = self.layer as? CAGradientLayer else {
            return
        }
        theLayer.colors = [gradientColors.startColor.cgColor, gradientColors.endColor.cgColor]
        theLayer.locations = [0.0, 1.0]
        theLayer.startPoint = startPoint
        theLayer.endPoint = endPoint
        theLayer.frame = self.bounds
    }

    override class open var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}


