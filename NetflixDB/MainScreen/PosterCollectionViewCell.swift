//
//  posterCollectionViewCell.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/26/23.
//

import UIKit

class PosterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    static let identifier = "PosterCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        posterImageView.layer.cornerRadius = 10
    }
    
    func configure(image: UIImage) {
        posterImageView.image = image
    }
}
