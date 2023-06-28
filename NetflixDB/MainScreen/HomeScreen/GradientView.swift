//
//  GradientView.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/26/23.
//

import UIKit

class GradientView: UIView {
        
    @IBOutlet var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("GradientView", owner: self)
        
        contentView?.frame = self.bounds
        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = contentView.bounds
//        gradientLayer.locations = [0.7,1]
//        gradientLayer.colors = [
//            UIColor.black.withAlphaComponent(0.3).cgColor,
//            UIColor.lightGray.withAlphaComponent(0.1).cgColor
//        ]
//        contentView.layer.addSublayer(gradientLayer)
        addSubview(contentView)
    }
}
