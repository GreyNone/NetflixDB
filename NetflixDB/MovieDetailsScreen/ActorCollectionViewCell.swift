//
//  ActorCollectionViewCell.swift
//  NetflixDB
//
//  Created by Александр Василевич on 24.07.23.
//

import Foundation
import UIKit
import Alamofire

class ActorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var characterLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    static let identifier = "ActorCollectionViewCell"
    var request: DataRequest?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 20
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        nameLabel.text = nil
        characterLabel.text = nil
        roleLabel.text = nil
        request?.cancel()
    }
    
    func configure(image: UIImage, name: String, character: String, role: String) {
        imageView.image = image
        nameLabel.text = name
        characterLabel.text = character
        roleLabel.text = role
    }
    
    func configure(url: URL, for key: String, name: String, character: String, role: String) {
        request = AF.request(url, method: HTTPMethod.get, headers: headers)
        if let request = request {
            ImageService.shared.image(request: request, key: key) { [weak self] image in
                self?.imageView.image = image
                self?.nameLabel.text = name
                self?.characterLabel.text = character
                self?.roleLabel.text = role
            }
        }
    }
}
