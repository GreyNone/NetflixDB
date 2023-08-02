//
//  MovieDetailsViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/28/23.
//

import Foundation
import UIKit
import AVKit
import Alamofire
import YouTubeiOSPlayerHelper

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak private var posterImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var durationLabel: UILabel!
    @IBOutlet weak private var voteLabel: UILabel!
    @IBOutlet weak private var releaseDateLabel: UILabel!
    @IBOutlet weak private var overviewLabel: UILabel!
    @IBOutlet weak private var moviesCollectionView: UICollectionView!
    @IBOutlet weak private var actorsCollectionView: UICollectionView!
    @IBOutlet weak private var imageViewContainer: UIView!
    @IBOutlet weak private var likeImageView: UIImageView!
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var tableViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var videosTableView: UITableView!
    private var playerView: YTPlayerView?
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
    private let insets = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
    private var relatedMovies: [Movie]?
    private var actors: [Actor]?
    private var videos: [Video]?
    private var isLiked = false
    var movieId: Int?
    var movie: Movie?
    
    //MARK: - ControllerLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    
        //Moving scrollView's down so our imageView could stretch
        scrollView.contentInset = UIEdgeInsets(top: initialViewHeight, left: 0, bottom: 0, right: 0)
        
        //TableView setup
        videosTableView.register(VideoTableViewCell.nib, forCellReuseIdentifier: VideoTableViewCell.identifier)
        
        //downloading backdrop if it exists or setting default backdrop if it doesnt
        if let backdropPath = movie?.backdropPath {
            guard let backdropUrl = URL(string: "https://image.tmdb.org/t/p/" + "w500" + backdropPath) else { return }
            let backdropRequest = AF.request(backdropUrl, method: HTTPMethod.get, headers: headers)
            ImageService.shared.image(request: backdropRequest) { [weak self] image in
                self?.posterImageView.image = image
            }
        } else {
            self.posterImageView.image = UIImage(systemName: "questionmark")
        }
        
        //downloading movie details
        MoviesService.shared.movieDetails(movieId: movieId ?? 0) { [weak self] movieDetail in
            //setting details
            self?.overviewLabel.text = movieDetail.overview
            self?.titleLabel.text = movieDetail.originalTitle
            self?.voteLabel.text = "\(movieDetail.voteAverage ?? 0.0) (IMDb)"
            self?.durationLabel.text = "\(movieDetail.runtime ?? 0) minutes"
            
            //setting release date
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
        
        //downloading actors
        MoviesService.shared.actors(movieId: movieId ?? 0) { [weak self] actors in
            self?.actors = actors
            self?.actorsCollectionView.reloadData()
        }
        
        //downloading relatedMovies
        MoviesService.shared.relatedMovies(movieId: movieId ?? 0) { [weak self] fetchedMovies in
            self?.relatedMovies = fetchedMovies.movies
            self?.moviesCollectionView.reloadData()
        }
        
        //downloading videos
        MoviesService.shared.videos(movieId: movieId ?? 0) { [weak self] videos in
            self?.videos = videos
            self?.videosTableView.reloadData()
        }
        
        //setting isLiked to true if the movie is in favorites
        SessionManager.shared.favoriteMovies.forEach { favoriteMovie in
            if favoriteMovie.id == movieId {
                isLiked = true
                likeImageView.image = UIImage(systemName: "heart.fill")
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        heightConstraint.constant = initialViewHeight
        tableViewContainerHeightConstraint.constant = 0
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
        navigationItem.setHidesBackButton(false, animated: false)
    }
    
    //MARK: - PlayerView setup
    private func setupPlayerView() {
        playerView = YTPlayerView()
        if let playerView = playerView {
            imageViewContainer.addSubview(playerView)
            playerView.delegate = self
            
            playerView.translatesAutoresizingMaskIntoConstraints = false
            playerView.leadingAnchor.constraint(equalTo: imageViewContainer.leadingAnchor).isActive = true
            playerView.trailingAnchor.constraint(equalTo: imageViewContainer.trailingAnchor).isActive = true
            playerView.topAnchor.constraint(equalTo: imageViewContainer.topAnchor).isActive = true
            playerView.bottomAnchor.constraint(equalTo: imageViewContainer.bottomAnchor).isActive = true
            
            self.navigationController?.navigationBar.isHidden = false
            let barItem = UIBarButtonItem(barButtonSystemItem: .done,
                                          target: self,
                                          action: #selector(didTapOnCloseButton(sender: )))
            barItem.tintColor = .red
            self.navigationItem.rightBarButtonItem = barItem
        }
    }

    //MARK: - Actions
    @IBAction func didTapOnBack(_ sender: UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapOnLike(_ sender: UITapGestureRecognizer) {
        guard let movieId = movieId else { return }
        if isLiked {
            SessionManager.shared.removeFromFavorites(movieId: movieId) { [weak self] success in
                if success {
                    let index = SessionManager.shared.favoriteMovies.firstIndex { movie in
                        return movie.id == movieId
                    }
                    if let index = index {
                        SessionManager.shared.favoriteMovies.remove(at: index)
                    }
                    self?.likeImageView.image = UIImage(systemName: "heart")
                    self?.isLiked = false
                    SessionManager.shared.notify()
                }
            }
        } else {
            SessionManager.shared.addToFavorites(movieId: movieId) { [weak self] success in
                if success {
                    guard let movie = self?.movie else { return }
                    SessionManager.shared.favoriteMovies.append(movie)
                    self?.likeImageView.image = UIImage(systemName: "heart.fill")
                    self?.isLiked = true
                    SessionManager.shared.notify()
                }
            }
        }
    }
    
    @IBAction func didTapOnPlayButton(_ sender: UIButton) {
        self.tableViewContainerHeightConstraint.constant = 200
        UIView.animate(withDuration: 0.5 ) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc func didTapOnCloseButton(sender: UIBarButtonItem) {
        navigationController?.navigationBar.isHidden = true
        playerView?.stopVideo()
        playerView?.removeFromSuperview()
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
        if collectionView == moviesCollectionView {
            guard let count = relatedMovies?.count else { return 0 }
            return count
        } else {
            guard let count = actors?.count else { return 0 }
            return count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == moviesCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath)
                    as? MovieCollectionViewCell,
                  let relatedMovie = relatedMovies?[indexPath.row] else { return MovieCollectionViewCell() }
            
            //changing date format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: relatedMovie.releaseDate ?? "") ?? Date()
            dateFormatter.dateFormat = "yyyy"
            
            let fullMovieTitle = (relatedMovie.title ?? "placeholder") + "(" + dateFormatter.string(from: date) + ")"
            
            //checking if the image is already downloaded and stored in cache
            if let image = CacheManager.shared.getValue(for: relatedMovie.posterPath ?? "") {
                cell.configure(image: image, title: fullMovieTitle)
                return cell
            }
            
            //getting posterPath if it exists or backdropPath if it doesn't
            let posterPath = relatedMovie.posterPath ?? relatedMovie.backdropPath
            
            //loading poster or setting default image if it doesn't exist
            if let posterPath {
                guard let url = URL(string: "https://image.tmdb.org/t/p/" + "w200" + posterPath) else { return MovieCollectionViewCell() }
                cell.configure(url: url, for: posterPath, title: fullMovieTitle)
            } else {
                cell.configure(image: UIImage(named: "posterPlaceholder")!, title: fullMovieTitle)
            }
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActorCollectionViewCell.identifier, for: indexPath)
                    as? ActorCollectionViewCell,
                  let actor = actors?[indexPath.row] else { return ActorCollectionViewCell() }
            
            if let image = CacheManager.shared.getValue(for: actor.profilePath ?? "") {
                cell.configure(image: image,
                               name: actor.name ?? "No info",
                               character: actor.character ?? "No info",
                               role: actor.department ?? "No info")
                return cell
            }
            
            if let profilePath = actor.profilePath {
                guard let url = URL(string: "https://image.tmdb.org/t/p/" + "w200" + profilePath) else { return ActorCollectionViewCell() }
                cell.configure(url: url,
                               for: profilePath,
                               name: actor.name ?? "No info",
                               character: actor.character ?? "No info",
                               role: actor.department ?? "No info")
            } else {
                cell.configure(image: UIImage(named: "user")!,
                               name: actor.name ?? "No info",
                               character: actor.character ?? "No info",
                               role: actor.department ?? "No info")
            }
            
            return cell
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension MovieDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: itemWidth, height: self.moviesCollectionView.bounds.height - insets.top - insets.bottom)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insets.left
    }
}

//MARK: - UITableViewDataSource
extension MovieDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = videos?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell") as? VideoTableViewCell,
              let video = videos?[indexPath.row] else { return VideoTableViewCell() }
        
        cell.titleLabel.text = video.name
        cell.hostingLabel.text = video.site
        cell.typeLabel.text = video.type
        if let isOfficial = video.isOfficial {
            cell.isOfficialLabel.textColor = isOfficial ? UIColor.green : UIColor.red
        } else {
            cell.isOfficialLabel.textColor = .gray
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension MovieDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let video = videos?[indexPath.row],
              let id = video.key else { return }
        
        setupPlayerView()
        tableViewContainerHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.5 ) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        playerView?.load(withVideoId: id, playerVars: ["playsinline" : 1])
    }
}

//MARK: - YTPlayerViewDelegate
extension MovieDetailsViewController: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {

    }
}
