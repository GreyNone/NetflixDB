//
//  UpcomingPostersCollectionViewCell.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/27/23.
//

import Foundation
import UIKit

class UpcomingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "UpcomingCollectionViewCell"
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override class func awakeFromNib() {
        
    }
    
    func configure(image: UIImage) {
        posterImageView.image = image
    }
    
    func configure(image: UIImage, for key: String) {
        let image = CacheManager.shared.getValue(for: key)
        posterImageView.image = image
    }
}
