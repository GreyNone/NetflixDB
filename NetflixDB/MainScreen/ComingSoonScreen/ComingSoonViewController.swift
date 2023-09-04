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
    private var upcomingMovies = [Movie]()
    private var topRatedMovies = [Movie]()
    private var filteredMovies: [Movie]?
    private var currentUpcomingPage = 1
    private var currentTopRatedPage = 1
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    private var isSwitched = false
    private let insets = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    private var columns: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return 5
        case .phone:
            return 3
        default:
            return 1
        }
    }
    private var minWidthPerItem: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return 200
        case .phone:
            return 125
        default:
            return 50
        }
    }
    private var isVisible = false
    
    //MARK: - ControllerLifecycle
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        isVisible = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchTextField.backgroundColor = .systemGray2
//        searchController.searchBar.searchTextField.textAlignment = .center
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.scopeButtonTitles = ["Upcoming", "Top Rated"]
        
        self.navigationItem.searchController = searchController
        
        MoviesService.shared.upcomingMovies(page: currentUpcomingPage) { [weak self] fetchedMovies in
            self?.currentUpcomingPage = fetchedMovies.page
            self?.upcomingMovies = fetchedMovies.movies
            self?.collectionView.reloadData()
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
}

//MARK: - UICollectionViewDataSource
extension ComingSoonViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            guard let count = filteredMovies?.count else { return 0 }
            return count
        } else {
            return isSwitched ? topRatedMovies.count : upcomingMovies.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCollectionViewCell.identifier, for: indexPath)
                as? PosterCollectionViewCell else { return PosterCollectionViewCell() }
        
        var movie: Movie

        if isFiltering {
            guard let filteredMovies = filteredMovies else { return PosterCollectionViewCell() }
            movie = filteredMovies[indexPath.row]
        } else {
            movie = isSwitched ? topRatedMovies[indexPath.row] : upcomingMovies[indexPath.row]
        }
        
//        if isFiltering {
//            movie = filteredMovies?[indexPath.row]
//        } else {
//            movie = upcomingMovies[indexPath.row]
//        }
        
//        movie = isFiltering ? filteredMovies[indexPath.row] : upcomingMovies[indexPath.row]
        
        let poster = movie.posterPath ?? movie.backdropPath
        
        if let poster = poster {
            if let image = CacheManager.shared.getValue(for: poster) {
                cell.configure(image: image)
                return cell
            }
            
            let url = URL(string: "https://image.tmdb.org/t/p/" + "w200" + poster)
            if let url = url {
                cell.configure(url: url, for: poster)
                return cell
            }
        }
        if let posterPlaceholderImage = UIImage(named: "posterPlaceholder") {
            cell.configure(image: posterPlaceholderImage)
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
            if !isSwitched {
                MoviesService.shared.upcomingMovies(page: currentUpcomingPage + 1) { [weak self] fetchedMovies in
                    self?.currentUpcomingPage = fetchedMovies.page
                    self?.upcomingMovies.append(contentsOf: fetchedMovies.movies)
                    self?.collectionView.reloadData()
                }
            } else {
                MoviesService.shared.topRatedMovies(page: currentTopRatedPage + 1) { [weak self] fetchedMovies in
                    self?.currentTopRatedPage = fetchedMovies.page
                    self?.topRatedMovies.append(contentsOf: fetchedMovies.movies)
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieDetailsViewControllerStoryboard = UIStoryboard(name: "MovieDetailsViewController", bundle: nil)
        let movieDetailsViewController = movieDetailsViewControllerStoryboard.instantiateViewController(identifier: "MovieDetailsViewController") as? MovieDetailsViewController
        var movie: Movie
        
        if isFiltering {
            guard let filteredMovies = filteredMovies else { return }
            movie = filteredMovies[indexPath.row]
        } else {
            movie = isSwitched ? topRatedMovies[indexPath.row] : upcomingMovies[indexPath.row]
        }

        movieDetailsViewController?.movie = movie
        
        self.navigationController?.pushViewController(movieDetailsViewController ?? movieDetailsViewControllerStoryboard.instantiateViewController(identifier: "MovieDetailsViewController"), animated: true)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension ComingSoonViewController: UICollectionViewDelegateFlowLayout {

    private func calculateWidth(columns: CGFloat, avaliableWidth: CGFloat) -> CGFloat {
        var width = avaliableWidth / columns
        var columns = columns
        if width < minWidthPerItem {
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

//MARK: - UISearchResultsUpdating
extension ComingSoonViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filterDataForSearchText(searchText: text)
    }
    
    private func filterDataForSearchText(searchText: String) {
        let dataToFilter: [Movie]
        dataToFilter = isSwitched ? topRatedMovies : upcomingMovies
        filteredMovies = []
        dataToFilter.forEach({ movie in
            if let title = movie.title {
                if title.lowercased().contains(searchText.lowercased()) {
                    filteredMovies?.append(movie)
                }
            }
        })
        collectionView.reloadData()
    }
}

//MARK: - UISearchControllerDelegate
extension ComingSoonViewController: UISearchControllerDelegate {
    
}

//MARK: - UISearchBarDelegate
extension ComingSoonViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == 1 {
            if topRatedMovies.isEmpty {
                MoviesService.shared.topRatedMovies(page: currentTopRatedPage) { [weak self] fetchedMovies in
                    self?.currentTopRatedPage = fetchedMovies.page
                    self?.topRatedMovies = fetchedMovies.movies
                    self?.isSwitched = true
                    self?.collectionView.reloadData()
                    return
                }
            }
            isSwitched = true
        } else {
            isSwitched = false
            self.collectionView.reloadData()
        }
    }
}


