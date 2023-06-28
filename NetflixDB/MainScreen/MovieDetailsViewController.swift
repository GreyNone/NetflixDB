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
    
    @IBOutlet weak private var posterImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var durationLabel: UILabel!
    @IBOutlet weak private var voteLabel: UILabel!
    @IBOutlet weak private var releaseDateLabel: UILabel!
    @IBOutlet weak private var overviewLabel: UILabel!
    @IBOutlet weak private var collectionView: UICollectionView!
    var overview: String?
    var movieTitle: String?
    var vote: CGFloat?
    var releaseDate: String?
    var backdropPath: String?
    var movieId: Int?
    var relatedMovies: [Movie]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let backdropPath,
              let backdropUrl = URL(string: "https://image.tmdb.org/t/p/" + "original" + backdropPath) else { return }
        let moviesRequest = AF.request(backdropUrl, method: HTTPMethod.get, headers: ImageService.shared.headers)
        ImageService.shared.image(request: moviesRequest) { [weak self] image in
            self?.posterImageView.image = image
        }
        
        overviewLabel.text = overview
        titleLabel.text = movieTitle
        voteLabel.text = "\(vote ?? 10)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: releaseDate!)
        dateFormatter.dateFormat = "MMMM d,yyyy"
        releaseDateLabel.text = dateFormatter.string(from: date!)
        
        guard let relatedMoviesUrl = URL(string: "https://api.themoviedb.org/3/movie/" + "\(movieId ?? 0)" + "/similar?language=en-US&page=1") else { return }
        let relatedMoviewRequest = AF.request(relatedMoviesUrl, method: HTTPMethod.get, headers: MoviesService.shared.headers)
        MoviesService.shared.movies(request: relatedMoviewRequest) { [weak self] fetchedMovies in
            self?.relatedMovies = fetchedMovies.movies
        }
    }
}

//MARK: - UICollectionViewDataSource
extension MovieDetailsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = relatedMovies?.count else { return 0 }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension MovieDetailsViewController: UICollectionViewDelegateFlowLayout {
    
}
