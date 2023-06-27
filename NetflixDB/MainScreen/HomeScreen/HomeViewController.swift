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
    var movies: [Movie]?
    let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let provider = MoyaProvider<MyService>(plugins: [CachePolicyPlugin()])
//        provider.request(.popularMovies) { [weak self] result in
//            switch result {
//            case .success(let response):
//                let data = try? response.map(Movies.self)
//                self?.movies = data?.movies ?? []
//                print(self?.movies as Any)
//            case .failure(let error):
//                print(error)
//            }
//        }
        
        guard let moviesUrl = URL(string: "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1") else { return }
        let request = AF.request(moviesUrl, method: HTTPMethod.get, headers: ImageService.shared.headers)
        MoviesService.shared.movies(request: request) { movies in
            self.movies = self.sort(movies: movies.movies)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        
            let lastRelease = self.movies![0]
            self.movies?.remove(at: 0)

            guard let mainPosterUrl = URL(string: "https://image.tmdb.org/t/p/" + "original" + lastRelease.posterPath) else { return }
            let request = AF.request(mainPosterUrl, method: HTTPMethod.get, headers: ImageService.shared.headers)
            ImageService.shared.image(request: request, key: lastRelease.posterPath) { [weak self] image in
                DispatchQueue.main.async {
                    self?.mainPosterImageView.image = image
                }
            }
        }
    }

    private func sort(movies: [Movie]) -> [Movie] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return movies.sorted {dateFormatter.date(from: $0.releaseDate)! > dateFormatter.date(from: $1.releaseDate)!}
    }
}

//MARK: = UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = movies?.count else { return 0 }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCollectionViewCell.identifier, for: indexPath)
                as? PosterCollectionViewCell,
              let movie = movies?[indexPath.row] else { return PosterCollectionViewCell() }
        
        cell.activityIndicatorView.startAnimating()

        if let image = CacheManager.shared.getValue(for: movie.posterPath) {
            cell.configure(image: image)
            cell.activityIndicatorView.stopAnimating()
            return cell
        }

        let url = URL(string: "https://image.tmdb.org/t/p/" + "w200" + movie.posterPath)
        if let url = url {
            cell.configure(url: url, for: movie.posterPath)
        }

        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 125, height: self.collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insets.left
    }
}
