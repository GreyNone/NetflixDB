//
//  MovieCollectionViewCell.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/28/23.
//

import Foundation
import UIKit
import Alamofire

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    static let identifier = "MovieCollectionViewCell"
    private var request: DataRequest?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        posterImageView.layer.cornerRadius = 20
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        posterImageView.image = nil
        titleLabel.text = nil
        request?.cancel()
    }
    
    //MARK: - Configuration
    func configure(image: UIImage, title: String) {
        posterImageView.image = image
        titleLabel.text = title
    }
    
    func configure(url: URL, for key: String, title: String) {
        request = AF.request(url, method: HTTPMethod.get, headers: headers)
        if let request = request {
            ImageService.shared.image(request: request, key: key) { [weak self] image in
                self?.posterImageView.image = image
                self?.titleLabel.text = title
            }
        }
    }
}

