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
    
    var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let provider = MoyaProvider<MyService>()
        provider.request(.popularMovies) { [weak self] result in
            switch result {
            case .success(let response):
                let data = try? response.map(Movies.self)
                self?.movies = data?.movies ?? []
                print(self?.movies)
            case .failure(let error):
                print(error)
            }
        }
        
//        let headers = [
//          "accept": "application/json",
//          "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0MGNhZGEwMmVlMDNkMGY2NGI2OTUyZmM1ZTRjYjY5MyIsInN1YiI6IjY0OTU3NGEzZDVmZmNiMDBjNTk0YjM3OSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.SYCl9DneiRF3uQ7rbXeRp1JEJ52-3h3ODaBLBhWDy4c"
//        ]
//
//        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1")! as URL,
//                                                cachePolicy: .useProtocolCachePolicy,
//                                            timeoutInterval: 10.0)
//        request.httpMethod = "GET"
//        request.allHTTPHeaderFields = headers
//
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//          if (error != nil) {
//            print(error as Any)
//          } else {
//            let httpResponse = response as? HTTPURLResponse
//              let movies = try? JSONDecoder().decode(Movies.self, from: data!).movies
//              print(movies)
//          }
//        })
//
//        dataTask.resume()
    }
}
