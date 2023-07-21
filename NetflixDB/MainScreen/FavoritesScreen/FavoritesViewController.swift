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
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        tableView.register(FavoritesTableViewCell.nib, forCellReuseIdentifier: FavoritesTableViewCell.identifier)
    }
}

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let favoriteMovie = SessionManager.shared.favoriteMovies[indexPath.row]
        
        let movieDetailsViewControllerStoryboard = UIStoryboard(name: "MovieDetailsViewController", bundle: nil)
        let movieDetailsViewController = movieDetailsViewControllerStoryboard.instantiateViewController(identifier: "MovieDetailsViewController") as? MovieDetailsViewController
        
        movieDetailsViewController?.movieId = favoriteMovie.id
        movieDetailsViewController?.movie = favoriteMovie
        
        self.navigationController?.pushViewController(movieDetailsViewController ?? movieDetailsViewControllerStoryboard.instantiateViewController(identifier: "MovieDetailsViewController"), animated: true)
    }
}

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
            let backdropUrl = URL(string: "https://image.tmdb.org/t/p/" + "original" + poster)!
            cell.configure(url: backdropUrl, for: poster)
        } else {
            cell.configure(image: UIImage(systemName: "questionmark")!)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
}
