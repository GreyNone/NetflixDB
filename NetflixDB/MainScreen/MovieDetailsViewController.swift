//
//  MovieDetailsViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/28/23.
//

import Foundation
import UIKit
import Alamofire

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var overview: String?
    var movieTitle: String?
    var vote: CGFloat?
    var releaseDate: String?
    var backdropPath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let backdropPath,
              let backdropUrl = URL(string: "https://image.tmdb.org/t/p/" + "original" + backdropPath) else { return }
        let moviesRequest = AF.request(backdropUrl, method: HTTPMethod.get, headers: ImageService.shared.headers)
        ImageService.shared.image(request: moviesRequest, key: backdropPath) { [weak self] image in
            self?.posterImageView.image = image
        }
        
        overviewLabel.text = overview
        titleLabel.text = movieTitle
        voteLabel.text = "\(vote ?? 10)"
        releaseDateLabel.text = releaseDate
    }
}
