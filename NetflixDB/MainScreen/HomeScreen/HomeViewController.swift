//
//  HomeViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/23/23.
//

import Foundation
import UIKit
import Alamofire

class HomeViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var mainPosterImageView: UIImageView!
    @IBOutlet private weak var lastReleaseTitleLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var mainPosterHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    private var isVisible = false
    private var isLiked = false
    private var movies: [Movie]?
    private var lastRelease: Movie?
    private let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private var posterViewHeight: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return 400
        case .pad:
            return 700
        default:
            return 100
        }
    }
    private var collectionViewHeight: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return 250
        case .pad:
            return 400
        default:
            return 100
        }
    }
    private var itemWidth: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return 300
        case .phone:
            return 175
        default:
            return 150
        }
    }
    
    //MARK: - ControllerLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        //downloading latest popular releases
        guard let moviesUrl = URL(string: "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1") else { return }
        let moviesRequest = AF.request(moviesUrl, method: HTTPMethod.get, headers: headers)
        MoviesService.shared.movies(request: moviesRequest) { [weak self] fetchedMovies in
            //sorting latest releases by date
            self?.movies = self?.sort(movies: fetchedMovies.movies)
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
            
            self?.lastRelease = self?.movies?[0]
            //checking if the latest is liked by the user
            SessionManager.shared.favoriteMovies.forEach { favoriteMovie in
                if favoriteMovie.id == self?.lastRelease?.id {
                    self?.isLiked = true
                    self?.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                }
            }
            //if the latest movie is not for adults,then remove the blur
            if let isAdult = self?.lastRelease?.isAdult, !isAdult {
                self?.visualEffectView.removeFromSuperview()
            }
            
            let poster = self?.lastRelease?.posterPath ?? self?.lastRelease?.backdropPath
            
            //downloading poster or backdrop if it exists
            if let poster = poster {
                guard let mainPosterUrl = URL(string: "https://image.tmdb.org/t/p/" + "original" + poster) else { return }
                self?.movies?.remove(at: 0)
                let request = AF.request(mainPosterUrl, method: HTTPMethod.get, headers: headers)
                ImageService.shared.image(request: request, key: poster) { image in
                    DispatchQueue.main.async {
                        self?.mainPosterImageView.image = image
                        self?.lastReleaseTitleLabel.text = self?.lastRelease?.title
                    }
                }
            } else {
                //setting default image if poster doesn't exists
                self?.mainPosterImageView.image = UIImage(named: "posterPlaceholder")
                self?.lastReleaseTitleLabel.text = self?.lastRelease?.title
            }
            
            //downloading all genres for movies
            guard let genresUrl = URL(string: "https://api.themoviedb.org/3/genre/movie/list?language=en") else { return }
            let genresRequest = AF.request(genresUrl, method: HTTPMethod.get, headers: headers)
            MoviesService.shared.genres(request: genresRequest) { fetchedGenres in
                //setting genres for the latest release
                guard let genreIds = self?.lastRelease?.genreIds else { return }
                for lastReleaseGenre in genreIds {
                    for genre in fetchedGenres {
                        if lastReleaseGenre == genre.id {
                            let genreView = GenreView()
                            genreView.genreLabel?.text = genre.name
                            self?.stackView.addArrangedSubview(genreView)
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainPosterHeightConstraint.constant = posterViewHeight
        collectionViewHeightConstraint.constant = collectionViewHeight
        isVisible = true
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if isVisible {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
    }
    
    //MARK: - AdditionalMethod
    private func sort(movies: [Movie]) -> [Movie] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return movies.sorted {dateFormatter.date(from: $0.releaseDate ?? "")! > dateFormatter.date(from: $1.releaseDate ?? "")!}
    }
    
    //MARK: - Actions
    @IBAction func didTapOnAccountButton(_ sender: Any) {
        let accountViewControllerStoryboard = UIStoryboard(name: "AccountViewController", bundle: nil)
        let accountViewController = accountViewControllerStoryboard.instantiateViewController(identifier: "AccountViewController")
        self.navigationController?.pushViewController(accountViewController, animated: true)
    }
    
    @IBAction func didTapOnMainPoster(_ sender: Any) {
        let movieDetailsViewControllerStoryboard = UIStoryboard(name: "MovieDetailsViewController", bundle: nil)
        let movieDetailsViewController = movieDetailsViewControllerStoryboard.instantiateViewController(identifier: "MovieDetailsViewController") as? MovieDetailsViewController
        
        movieDetailsViewController?.movieId = lastRelease?.id
        movieDetailsViewController?.movie = lastRelease
        
        self.navigationController?.pushViewController(movieDetailsViewController ?? movieDetailsViewControllerStoryboard.instantiateViewController(identifier: "MovieDetailsViewController"), animated: true)
    }
    
    @IBAction func didTapOnLikeButton(_ sender: Any) {
        guard let movieId = lastRelease?.id else { return }
        if isLiked {
            SessionManager.shared.removeFromFavorites(movieId: movieId) { [weak self] success in
                if success {
                    let index = SessionManager.shared.favoriteMovies.firstIndex { movie in
                        return movie.id == movieId
                    }
                    if let index = index {
                        SessionManager.shared.favoriteMovies.remove(at: index)
                    }
                    self?.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    self?.isLiked = false
                    SessionManager.shared.notify()
                }
            }
        } else {
            SessionManager.shared.addToFavorites(movieId: movieId) { [weak self] success in
                if success {
                    guard let movie = self?.lastRelease else { return }
                    SessionManager.shared.favoriteMovies.append(movie)
                    self?.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    self?.isLiked = true
                    SessionManager.shared.notify()
                }
            }
        }
    }
}

//MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = movies?.count else { return 0 }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCollectionViewCell.identifier, for: indexPath)
                as? PosterCollectionViewCell,
              let movie = movies?[indexPath.row] else { return PosterCollectionViewCell() }
        
        if let image = CacheManager.shared.getValue(for: movie.posterPath ?? "") {
            cell.configure(image: image)
            return cell
        }
        
        let posterPath = movie.posterPath ?? movie.backdropPath
        
        if let posterPath {
            guard let url = URL(string: "https://image.tmdb.org/t/p/" + "w200" + posterPath) else { return PosterCollectionViewCell() }
            cell.configure(url: url, for: posterPath)
        } else {
            cell.configure(image: UIImage(named: "posterPlaceholder")!)
        }
        
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieDetailsViewControllerStoryboard = UIStoryboard(name: "MovieDetailsViewController", bundle: nil)
        guard let movie = movies?[indexPath.row],
              let movieDetailsViewController = movieDetailsViewControllerStoryboard.instantiateViewController(identifier: "MovieDetailsViewController")
                as? MovieDetailsViewController else { return }
        
        movieDetailsViewController.movieId = movie.id
        movieDetailsViewController.movie = movie
        
        self.navigationController?.pushViewController(movieDetailsViewController, animated: true)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return .init(width: itemWidth, height: self.collectionView.bounds.height - insets.top - insets.bottom)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insets.left
    }
}
