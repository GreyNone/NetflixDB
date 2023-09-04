//
//  FavoritesViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/23/23.
//

import Foundation
import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var posterViewHeight: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return 175
        case .pad:
            return 300
        default:
            return 100
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        tableView.register(FavoritesTableViewCell.nib, forCellReuseIdentifier: FavoritesTableViewCell.identifier)
//        tableView.isEditing = true
        SessionManager.shared.addObserver(observer: self)
    }
}

//MARK: - UITableViewDelegate
extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let favoriteMovie = SessionManager.shared.favoriteMovies[indexPath.row]
        
        let movieDetailsViewControllerStoryboard = UIStoryboard(name: "MovieDetailsViewController", bundle: nil)
        let movieDetailsViewController = movieDetailsViewControllerStoryboard.instantiateViewController(identifier: "MovieDetailsViewController") as? MovieDetailsViewController

        movieDetailsViewController?.movie = favoriteMovie
        
        self.navigationController?.pushViewController(movieDetailsViewController ?? movieDetailsViewControllerStoryboard.instantiateViewController(identifier: "MovieDetailsViewController"), animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //Getting movie id in order to remove it from favorites
        guard let movieId = SessionManager.shared.favoriteMovies[indexPath.row].id else { return }
        if editingStyle == .delete {
            SessionManager.shared.removeFromFavorites(movieId: movieId) { [weak self] success in
                if success {
                    SessionManager.shared.favoriteMovies.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
}

//MARK: - UITableViewDAtaSource
extension FavoritesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SessionManager.shared.favoriteMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = SessionManager.shared.favoriteMovies[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoritesTableViewCell.identifier)
                as? FavoritesTableViewCell else { return FavoritesTableViewCell() }
        
        let poster = movie.backdropPath ?? movie.posterPath
        
        if let poster {
            if let image = CacheManager.shared.getValue(for: poster) {
                cell.configure(image: image)
                return cell
            }
            let backdropUrl = URL(string: "https://image.tmdb.org/t/p/" + "w500" + poster)
            if let backdropUrl = backdropUrl {
                cell.configure(url: backdropUrl, for: poster)
            }
        } else {
            if let questionmarkImage = UIImage(systemName: "questionmark") {
                cell.configure(image: questionmarkImage)
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return posterViewHeight
    }
}

extension FavoritesViewController: Observer {
    
    func update() {
        self.tableView.reloadData()
    }
}
