//
//  MoviesService.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/27/23.
//

import Foundation
import Alamofire

final class MoviesService {
    
    static let shared = MoviesService()
    let headers: HTTPHeaders = [
      "accept": "application/json",
      "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0MGNhZGEwMmVlMDNkMGY2NGI2OTUyZmM1ZTRjYjY5MyIsInN1YiI6IjY0OTU3NGEzZDVmZmNiMDBjNTk0YjM3OSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.SYCl9DneiRF3uQ7rbXeRp1JEJ52-3h3ODaBLBhWDy4c"
    ]
    
    func movies(request: DataRequest, completion: @escaping (Movies) -> Void) {
        request.validate().responseDecodable(of: Movies.self) { (response) in
            guard let movies = response.value else { return }
            completion(movies)
        }
    }
    
    func genres(request: DataRequest, complection: @escaping ([Genre]) -> Void) {
        request.validate().responseDecodable(of: Genres.self) { (response) in
            guard let genres = response.value else { return }
            complection(genres.genres)
        }
    }
}
