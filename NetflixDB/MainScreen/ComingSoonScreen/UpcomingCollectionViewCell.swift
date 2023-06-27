//
//  UpcomingPostersCollectionViewCell.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/27/23.
//

import Foundation
import UIKit
import Alamofire

class UpcomingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "UpcomingCollectionViewCell"
    private var request: DataRequest?
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override class func awakeFromNib() {
        
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
        request = AF.request(url, method: HTTPMethod.get, headers: ImageService.shared.headers)
        if let request = request {
            ImageService.shared.image(request: request, key: key) { [weak self] image in
                self?.posterImageView.image = image
                self?.activityIndicatorView.stopAnimating()
            }
        }
    }
}
