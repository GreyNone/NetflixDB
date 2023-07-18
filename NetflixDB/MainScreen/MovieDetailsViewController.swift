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
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    private var minStretchHeight: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return 100
        case .pad:
            return 450
        default:
            return 50
        }
    }
    private var initialViewHeight: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return 250
        case .pad:
            return 600
        default:
            return 100
        }
    }
    private var itemWidth: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return 300
        case .phone:
            return 225
        default:
            return 150
        }
    }
    let insets = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
    var overview: String?
    var movieTitle: String?
    var vote: CGFloat?
    var releaseDate: String?
    var backdropPath: String?
    var movieId: Int?
    var relatedMovies: [Movie]?
    
    //MARK: - ControllerLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    
        scrollView.contentInset = UIEdgeInsets(top: initialViewHeight, left: 0, bottom: 0, right: 0)
        
        guard let movieDetailsUrl = URL(string: "https://api.themoviedb.org/3/movie/" + "\(movieId ?? 0)" + "?language=en-US") else { return }
        let movieDetailsRequest = AF.request(movieDetailsUrl, method: HTTPMethod.get, headers: headers)
        MoviesService.shared.movieDetails(request: movieDetailsRequest) { [weak self] movieDetail in
            if let backdropPath = movieDetail.backdropPath {
                guard let backdropUrl = URL(string: "https://image.tmdb.org/t/p/" + "original" + backdropPath) else { return }
                let backdropRequest = AF.request(backdropUrl, method: HTTPMethod.get, headers: headers)
                ImageService.shared.image(request: backdropRequest) { image in
                    self?.posterImageView.image = image
                }
            } else {
                self?.posterImageView.image = UIImage(systemName: "questionmark")
            }
            
            self?.overviewLabel.text = movieDetail.overview
            self?.titleLabel.text = movieDetail.originalTitle
            self?.voteLabel.text = "\(movieDetail.voteAverage ?? 0.0) (IMDb)"
            self?.durationLabel.text = "\(movieDetail.runtime ?? 0) minutes"
            
            if let releaseDate = movieDetail.releaseDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: releaseDate)
                dateFormatter.dateFormat = "MMMM d,yyyy"
                self?.releaseDateLabel.text = dateFormatter.string(from: date!)
            } else {
                self?.releaseDateLabel.text = "no release date"
            }
        }

        guard let relatedMoviesUrl = URL(string: "https://api.themoviedb.org/3/movie/" + "\(movieId ?? 0)" + "/similar?language=en-US&page=1") else { return }
        let relatedMoviewRequest = AF.request(relatedMoviesUrl, method: HTTPMethod.get, headers: headers)
        MoviesService.shared.movies(request: relatedMoviewRequest) { [weak self] fetchedMovies in
            self?.relatedMovies = fetchedMovies.movies
            self?.collectionView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        heightConstraint.constant = initialViewHeight
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    

    //MARK: - Actions
    @IBAction func didTapOnBack(_ sender: UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapOnLike(_ sender: UITapGestureRecognizer) {
        likeImageView.image = UIImage(systemName: "heart.fill")
        
//        let headers = [
//          "accept": "application/json",
//          "content-type": "application/json",
//          "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0MGNhZGEwMmVlMDNkMGY2NGI2OTUyZmM1ZTRjYjY5MyIsInN1YiI6IjY0OTU3NGEzZDVmZmNiMDBjNTk0YjM3OSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.SYCl9DneiRF3uQ7rbXeRp1JEJ52-3h3ODaBLBhWDy4c"
//        ]
//        let parameters = [
//          "media_type": "movie",
//          "media_id": 550,
//          "favorite": true
//        ] as [String : Any]
//
//        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
//
//        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/account/20052144/favorite")! as URL,
//                                                cachePolicy: .useProtocolCachePolicy,
//                                            timeoutInterval: 10.0)
//        request.httpMethod = "POST"
//        request.allHTTPHeaderFields = headers
//        request.httpBody = postData as Data
//
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//          if (error != nil) {
//            print(error as Any)
//          } else {
//            let httpResponse = response as? HTTPURLResponse
//            print(httpResponse)
//          }
//        })
//
//        dataTask.resume()
    }
}

//MARK: - UIScrollViewDelegate
extension MovieDetailsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let yoffset = initialViewHeight - (scrollView.contentOffset.y + initialViewHeight)
            let headerHeight = max(min(yoffset, initialViewHeight), minStretchHeight)
            heightConstraint.constant = headerHeight
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath)
                as? MovieCollectionViewCell,
              let relatedMovie = relatedMovies?[indexPath.row] else { return MovieCollectionViewCell() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: relatedMovie.releaseDate ?? "") ?? Date()
        dateFormatter.dateFormat = "yyyy"

        let fullMovieTitle = (relatedMovie.title ?? "placeholder") + "(" + dateFormatter.string(from: date) + ")"
    
        if let image = CacheManager.shared.getValue(for: relatedMovie.posterPath ?? "") {
            cell.configure(image: image, title: fullMovieTitle)
            return cell
        }
        
        let posterPath = relatedMovie.posterPath ?? relatedMovie.backdropPath
        
        if let posterPath {
            guard let url = URL(string: "https://image.tmdb.org/t/p/" + "w200" + posterPath) else { return MovieCollectionViewCell() }
            cell.configure(url: url, for: posterPath, title: fullMovieTitle)
        } else {
            cell.configure(image: UIImage(named: "posterPlaceholder")!, title: fullMovieTitle)
        }
        
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension MovieDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: itemWidth, height: self.collectionView.bounds.height - insets.top - insets.bottom)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insets.left
    }
}
