//
//  HomeViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/23/23.
//

import Foundation
import UIKit
import Moya

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainPosterImageView: UIImageView!
    var movies = [Movie]()
    var posters = [UIImage]()
    var genres = [Genre]()
    let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let provider = MoyaProvider<MyService>(plugins: [CachePolicyPlugin()])
        provider.request(.popularMovies) { [weak self] result in
            switch result {
            case .success(let response):
                let data = try? response.map(Movies.self)
                self?.movies = data?.movies ?? []
                print(self?.movies as Any)
            case .failure(let error):
                print(error)
            }
        }
        
        //        let headers = [
        //          "accept": "application/json",
        //          "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0MGNhZGEwMmVlMDNkMGY2NGI2OTUyZmM1ZTRjYjY5MyIsInN1YiI6IjY0OTU3NGEzZDVmZmNiMDBjNTk0YjM3OSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.SYCl9DneiRF3uQ7rbXeRp1JEJ52-3h3ODaBLBhWDy4c"
        //        ]
        //
        //        let moviesRequest = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1")! as URL,
        //                                                cachePolicy: .useProtocolCachePolicy,
        //                                          timeoutInterval: 10.0)
        //        moviesRequest.httpMethod = "GET"
        //        moviesRequest.allHTTPHeaderFields = headers
        //
        //        let session = URLSession.shared
        //        let moviesDataTask = session.dataTask(with: moviesRequest as URLRequest, completionHandler: { [weak self] (data, response, error) -> Void in
        //            guard let data = data,
        //                  error == nil,
        //                  let movies = try? JSONDecoder().decode(Movies.self, from: data).movies,
        //                  let strongSelf = self else { return }
        //
        //            strongSelf.movies = strongSelf.sort(movies: movies)
        //
        //            let lastRelease = strongSelf.movies[0]
        //            strongSelf.movies.remove(at: 0)
        //
        //            let mainPosterRequest = NSMutableURLRequest(url: NSURL(string:"https://image.tmdb.org/t/p/"
        //                                                                   + "w400"
        //                                                                   + (lastRelease.posterPath))! as URL,
        //                                                        cachePolicy: .useProtocolCachePolicy,
        //                                                        timeoutInterval: 10)
        //            mainPosterRequest.httpMethod = "GET"
        //            mainPosterRequest.allHTTPHeaderFields = headers
        //
        //            let mainPosterDataTask = session.dataTask(with: mainPosterRequest as URLRequest, completionHandler: { (data, response, error) -> Void in
        //                guard error == nil,
        //                      let data = data,
        //                      let image = UIImage(data: data) else { return }
        //                DispatchQueue.main.async {
        //                    self?.mainPosterImageView.image = image
        //                }
        //            })
        //            mainPosterDataTask.resume()
        //
        //            for movie in strongSelf.movies {
        //                let postersRequest = NSMutableURLRequest(url: NSURL(string:"https://image.tmdb.org/t/p/"
        //                                                                    + "w400"
        //                                                                    + (movie.posterPath))! as URL,
        //                                                         cachePolicy: .useProtocolCachePolicy,
        //                                                         timeoutInterval: 10)
        //                postersRequest.httpMethod = "GET"
        //                postersRequest.allHTTPHeaderFields = headers
        //
        //                let posterDataTask = session.dataTask(with: postersRequest as URLRequest, completionHandler: { (data, response, error) -> Void in
        //                    guard error == nil,
        //                          let image = UIImage(data: data!) else { return }
        //
        //                    strongSelf.posters.append(image)
        //                    DispatchQueue.main.async {
        //                        self?.collectionView.reloadData()
        //                    }
        //                })
        //                posterDataTask.resume()
        //            }
        //        })
        //        moviesDataTask.resume()
        //
        //        let genresRequest = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/genre/movie/list?language=en")! as URL,
        //                                                cachePolicy: .useProtocolCachePolicy,
        //                                            timeoutInterval: 10.0)
        //        genresRequest.httpMethod = "GET"
        //        genresRequest.allHTTPHeaderFields = headers
        //
        //        let genresDataTask = session.dataTask(with: genresRequest as URLRequest, completionHandler: { (data, response, error) -> Void in
        //            guard let data = data,
        //                  error == nil else { return }
        //
        //
        //        })
        //
        //        genresDataTask.resume()
        //    }
        //
        //    private func sort(movies: [Movie]) -> [Movie] {
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "yyyy-MM-dd"
        //
        //        return movies.sorted {dateFormatter.date(from: $0.releaseDate)! > dateFormatter.date(from: $1.releaseDate)!}
        //    }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCollectionViewCell.identifier, for: indexPath)
                as? PosterCollectionViewCell else { return PosterCollectionViewCell() }
        
        cell.configure(image: posters[indexPath.row])
        
        return cell
    }
}

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
