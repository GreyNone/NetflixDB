//
//  ComingSoonViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/23/23.
//

import Foundation
import UIKit
import Alamofire

class ComingSoonViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var upcomingMovies: [Movie]?
    var movies: Movies?
    let insets = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    private var columns: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return 5
        case .phone:
            return 3
        default:
            return 3
        }
    }
    private let minWidthPerItem: CGFloat = 125
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let upcomingMoviesUrl = URL(string: "https://api.themoviedb.org/3/movie/upcoming?language=en-US&page=1") else { return }
        let request = AF.request(upcomingMoviesUrl, method: HTTPMethod.get, headers: ImageService.shared.headers)
        MoviesService.shared.movies(request: request) { [weak self] fetchedMovies in
            self?.movies = fetchedMovies
            self?.upcomingMovies = fetchedMovies.movies
            self?.collectionView.reloadData()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

//MARK: - UICollectionViewDataSource
extension ComingSoonViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = upcomingMovies?.count else { return 0 }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UpcomingCollectionViewCell.identifier, for: indexPath)
                as? UpcomingCollectionViewCell,
              let movie = upcomingMovies?[indexPath.row] else { return UpcomingCollectionViewCell() }
        
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
extension ComingSoonViewController: UICollectionViewDelegate {
    
    private func countRows(in previousSection: Int) -> Int {
        guard previousSection >= 0 else { return 0 }
        var rows = 0
        var i = 0
        repeat {
            rows += self.collectionView.numberOfItems(inSection: i)
            i += 1
        } while i < previousSection
        return rows
    }
    
    private func countAllRows() -> Int {
        var rows = 0
        for i in 0...collectionView.numberOfSections - 1 {
            rows += collectionView.numberOfItems(inSection: i)
        }
        return rows
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if countRows(in: indexPath.section - 1) + indexPath.row == countAllRows() - 3 {
            guard let upcomingMoviesUrl = URL(string: "https://api.themoviedb.org/3/movie/upcoming?language=en-US&page=\((movies?.page ?? 0) + 1)") else { return }
            let request = AF.request(upcomingMoviesUrl, method: HTTPMethod.get, headers: ImageService.shared.headers)
            MoviesService.shared.movies(request: request) { [weak self] fetchedMovies in
                self?.movies = fetchedMovies
                self?.upcomingMovies?.append(contentsOf: fetchedMovies.movies)
                self?.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension ComingSoonViewController: UICollectionViewDelegateFlowLayout {

    private func calculateWidth(columns: CGFloat, avaliableWidth: CGFloat) -> CGFloat {
        var width = avaliableWidth / columns
        var columns = columns
        if width < minWidthPerItem - 10 {
            columns = columns - 1
            let paddingSpace = insets.left * (columns + 1)
            let newAvailableWidth = view.frame.width - paddingSpace
            width = calculateWidth(columns: columns, avaliableWidth: newAvailableWidth)
        }
        return width
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = insets.left * (columns + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = calculateWidth(columns: columns, avaliableWidth: availableWidth)
  
        return CGSize(width: widthPerItem, height: widthPerItem * 1.5)
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
