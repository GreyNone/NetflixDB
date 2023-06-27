//
//  ComingSoonViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/23/23.
//

import Foundation
import UIKit

class ComingSoonViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var upcomingMovies = [Movie]()
    var posters = [UIImage]()
    let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
    private let minWidthPerItem: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headers = [
          "accept": "application/json",
          "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0MGNhZGEwMmVlMDNkMGY2NGI2OTUyZmM1ZTRjYjY5MyIsInN1YiI6IjY0OTU3NGEzZDVmZmNiMDBjNTk0YjM3OSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.SYCl9DneiRF3uQ7rbXeRp1JEJ52-3h3ODaBLBhWDy4c"
        ]

        let upcomingMoviesRequest = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/movie/upcoming?language=en-US&page=1")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        upcomingMoviesRequest.httpMethod = "GET"
        upcomingMoviesRequest.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: upcomingMoviesRequest as URLRequest, completionHandler: { [weak self] (data, response, error) -> Void in
            guard let data = data,
                  error == nil,
                  let self = self else { return }
            
            let responseData = try? JSONDecoder().decode(Movies.self, from: data)
            self.upcomingMovies = responseData?.movies ?? []
            
            for movie in self.upcomingMovies {
                let postersRequest = NSMutableURLRequest(url: NSURL(string:"https://image.tmdb.org/t/p/"
                                                                    + "w400"
                                                                    + (movie.posterPath))! as URL,
                                                         cachePolicy: .useProtocolCachePolicy,
                                                         timeoutInterval: 10)
                postersRequest.httpMethod = "GET"
                postersRequest.allHTTPHeaderFields = headers
                
                let posterDataTask = session.dataTask(with: postersRequest as URLRequest, completionHandler: { (data, response, error) -> Void in
                    guard let data = data,
                          error == nil,
                          let image = UIImage(data: data) else { return }
                    
                    self.posters.append(image)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                })
                posterDataTask.resume()
            }
        })
        dataTask.resume()
        
    }
}

//MARK: - UICollectionViewDataSource
extension ComingSoonViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UpcomingCollectionViewCell.identifier, for: indexPath)
                as? UpcomingCollectionViewCell else { return UpcomingCollectionViewCell() }
        
        cell.configure(image: posters[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}

//MARK: - UICollectionViewDelegate
extension ComingSoonViewController: UICollectionViewDelegate {
    
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxColumns = columns
        let paddingSpace = insets.left * (maxColumns + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = calculateWidth(columns: maxColumns, avaliableWidth: availableWidth)
        
        return CGSize(width: widthPerItem, height: widthPerItem * 1.5)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insets.left
    }
}
