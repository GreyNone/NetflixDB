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

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainPosterImageView: UIImageView!
    @IBOutlet weak var lastReleaseTitleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var stackView: UIStackView!
    private var isVisible = false
    private var movies: [Movie]?
    private let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private var itemWidth: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return 250
        case .phone:
            return 175
        default:
            return 150
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVisible = true
    }
    
    //MARK: - ControllerLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        guard let moviesUrl = URL(string: "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1") else { return }
        let moviesRequest = AF.request(moviesUrl, method: HTTPMethod.get, headers: ImageService.shared.headers)
        MoviesService.shared.movies(request: moviesRequest) { [weak self] fetchedMovies in
            self?.movies = self?.sort(movies: fetchedMovies.movies)
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
            
            guard let lastRelease = self?.movies?[0] else { return }
            
            if let isAdult = lastRelease.isAdult, !isAdult {
                self?.visualEffectView.removeFromSuperview()
            }
            
            let poster = lastRelease.posterPath ?? lastRelease.backdropPath
            
            if let poster = poster {
                guard let mainPosterUrl = URL(string: "https://image.tmdb.org/t/p/" + "original" + (poster)) else { return }
                self?.movies?.remove(at: 0)
                let request = AF.request(mainPosterUrl, method: HTTPMethod.get, headers: ImageService.shared.headers)
                ImageService.shared.image(request: request, key: poster) { image in
                    DispatchQueue.main.async {
                        self?.mainPosterImageView.image = image
                        self?.lastReleaseTitleLabel.text = lastRelease.title
                    }
                }
            } else {
                self?.mainPosterImageView.image = UIImage(systemName: "questionmark")
                self?.lastReleaseTitleLabel.text = lastRelease.title
            }
            
            guard let genresUrl = URL(string: "https://api.themoviedb.org/3/genre/movie/list?language=en") else { return }
            let genresRequest = AF.request(genresUrl, method: HTTPMethod.get, headers: MoviesService.shared.headers)
            MoviesService.shared.genres(request: genresRequest) { fetchedGenres in
                for lastReleaseGenre in lastRelease.genreIds! {
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

        let url = URL(string: "https://image.tmdb.org/t/p/" + "w200" + (movie.posterPath ?? ""))
        if let url = url {
            cell.configure(url: url, for: movie.posterPath ?? "")
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
        
        movieDetailsViewController.overview = movie.overview
        movieDetailsViewController.movieTitle = movie.title
        movieDetailsViewController.releaseDate = movie.releaseDate
        movieDetailsViewController.vote = movie.voteAverage
        movieDetailsViewController.backdropPath = movie.backdropPath
        movieDetailsViewController.movieId = movie.id
        
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
