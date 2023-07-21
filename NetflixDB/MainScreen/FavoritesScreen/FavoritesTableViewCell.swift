//
//  FavoritesTableVIewCellTableViewCell.swift
//  NetflixDB
//
//  Created by Александр Василевич on 18.07.23.
//

import UIKit
import Alamofire

class FavoritesTableViewCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    static let identifier = "FavoritesTableViewCell"
    static var nib: UINib {
        return UINib(nibName: "FavoritesTableViewCell", bundle: nil)
    }
    var request: DataRequest?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        request?.cancel()
    }
    
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
