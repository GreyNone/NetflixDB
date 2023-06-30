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
    private var maxStretchHeight: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return 350
        case .pad:
            return 700
        default:
            return 100
        }
    }
    private var initialViewHeight: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return 200
        case .pad:
            return 600
        default:
            return 50
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
    }
}

//MARK: - UIScrollViewDelegate
extension MovieDetailsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let yoffset = initialViewHeight - (scrollView.contentOffset.y + initialViewHeight)
            let headerHeight = min(max(yoffset, initialViewHeight), maxStretchHeight)
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

        let url = URL(string: "https://image.tmdb.org/t/p/" + "w200" + (relatedMovie.posterPath ?? ""))
        if let url = url {
            cell.configure(url: url, for: relatedMovie.posterPath ?? "", title: fullMovieTitle)
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
