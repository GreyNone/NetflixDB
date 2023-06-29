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
    @IBOutlet weak private var imageViewContainer: UIView!
    let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0)
    var overview: String?
    var movieTitle: String?
    var vote: CGFloat?
    var releaseDate: String?
    var backdropPath: String?
    var movieId: Int?
    var relatedMovies: [Movie]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let backdropPath = backdropPath {
            guard let backdropUrl = URL(string: "https://image.tmdb.org/t/p/" + "original" + backdropPath) else { return }
            let moviesRequest = AF.request(backdropUrl, method: HTTPMethod.get, headers: ImageService.shared.headers)
            ImageService.shared.image(request: moviesRequest) { [weak self] image in
                self?.posterImageView.image = image
            }
        } else {
            posterImageView.image = UIImage(systemName: "questionmark")
        }
        
        overviewLabel.text = overview
        titleLabel.text = movieTitle
        voteLabel.text = "\(vote ?? 10) (IMDb)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: releaseDate!)
        dateFormatter.dateFormat = "MMMM d,yyyy"
        releaseDateLabel.text = dateFormatter.string(from: date!)
        
        guard let relatedMoviesUrl = URL(string: "https://api.themoviedb.org/3/movie/" + "\(movieId ?? 0)" + "/similar?language=en-US&page=1") else { return }
        let relatedMoviewRequest = AF.request(relatedMoviesUrl, method: HTTPMethod.get, headers: MoviesService.shared.headers)
        MoviesService.shared.movies(request: relatedMoviewRequest) { [weak self] fetchedMovies in
            self?.relatedMovies = fetchedMovies.movies
            self?.collectionView.reloadData()
        }
    }
    
//    func subscribeOnUpdates(view: UIView) {
//        observers.append(view.observe(\UIView.contentOffset, options: [.new, .old], changeHandler: { [weak self](_, change) in
//            guard let self = self else { return }
//            if let newY = change.newValue?.y, let oldY = change.oldValue?.y {
//                // maximum used to ignore overscroll in constraint calculation
//                let change = CGFloat.maximum(newY, -self.maximumContentHeight) - CGFloat.maximum(oldY, -self.maximumContentHeight)
//                if change < 0 {
//                    // scroll up logic
//                    if newY < -self.composeContentHeight {
//                        self.heightConstraint.constant = CGFloat.minimum(self.heightConstraint.constant - change, self.maximumContentHeight)
//                    }
//                } else if change > 0 {
//                    self.heightConstraint.constant = CGFloat.maximum(self.heightConstraint.constant - change, self.minimumContentHeight)
//                } else {
//                    // possibly inset change, recheck state
//                    if newY <= 0 {
//                        self.heightConstraint.constant = CGFloat.minimum(-newY, self.maximumContentHeight)
//                    }
//                }
//                self.didChangeStretchFactor((self.heightConstraint.constant - self.minimumContentHeight) / (self.maximumContentHeight - self.minimumContentHeight))
//            }
//        }))
//    }

//    func didChangeStretchFactor(_ stretchFactor: CGFloat) {
//        let limitedStretchFactor = min(1.0, max(stretchFactor, 0.0))
//        searchBottomOffsetConstraint.constant = 20 + min(limitedStretchFactor  2.0, 1.0)  50.0
//    }
}

//MARK: - UICollectionViewDataSource
extension MovieDetailsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = relatedMovies?.count else { return 0 }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath)
                as? MovieCollectionViewCell,
              let relatedMovie = relatedMovies?[indexPath.row] else { return MovieCollectionViewCell() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var date = dateFormatter.date(from: relatedMovie.releaseDate ?? "") ?? Date()
        dateFormatter.dateFormat = "yyyy"

        let fullMovieTitle = (relatedMovie.title ?? "placeholder") + "(" + dateFormatter.string(from: date) + ")"
    
        if let image = CacheManager.shared.getValue(for: relatedMovie.posterPath ?? "") {
            cell.configure(image: image, title: fullMovieTitle)
            return cell
        }

        let url = URL(string: "https://image.tmdb.org/t/p/" + "w200" + (relatedMovie.posterPath ?? ""))
        if let url = url {
            cell.configure(url: url, for: relatedMovie.posterPath ?? "", title: fullMovieTitle)
        }
        
        return cell
    }
}


//MARK: - UICollectionViewDelegateFlowLayout
//extension MovieDetailsViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let avaibleWidth = self.view.bounds.width - insets.left * 3
//        let widthPerItem = avaibleWidth / 2
//        return .init(width: widthPerItem, height: self.collectionView.bounds.height - insets.top)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return insets
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return insets.left
//    }
//}
