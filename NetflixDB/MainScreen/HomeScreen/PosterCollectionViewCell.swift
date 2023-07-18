//
//  posterCollectionViewCell.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/26/23.
//

import UIKit
import Alamofire

class PosterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    static let identifier = "PosterCollectionViewCell"
    private var request: DataRequest?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        posterImageView.image = nil
        request?.cancel()
    }
    
    //MARK: - Configuration
    func configure(image: UIImage) {
        posterImageView.image = image
    }
    
    func configure(url: URL, for key: String) {
        request = AF.request(url, method: HTTPMethod.get, headers: headers)
        if let request = request {
            ImageService.shared.image(request: request, key: key) { [weak self] image in
                self?.posterImageView.image = image
            }
        }
    }

}

