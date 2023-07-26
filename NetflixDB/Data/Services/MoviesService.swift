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
    
    func movies(request: DataRequest, completion: @escaping (Movies) -> Void) {
        request.validate().responseDecodable(of: Movies.self) { (response) in
            guard let movies = response.value else { return }
            completion(movies)
        }
    }
    
    func genres(request: DataRequest, completion: @escaping ([Genre]) -> Void) {
        request.validate().responseDecodable(of: Genres.self) { (response) in
            guard let genres = response.value else { return }
            completion(genres.genres)
        }
    }
    
    func movieDetails(request: DataRequest, completion: @escaping (MovieDetail) -> Void) {
        request.validate().responseDecodable(of: MovieDetail.self) { (response) in
            guard let movieDetails = response.value else { return }
            completion(movieDetails)
        }
    }
    
    func actors(request: DataRequest, completion: @escaping ([Actor]) -> Void) {
        request.validate().responseDecodable(of: Actors.self) { (response) in
            guard let actors = response.value else { return }
            completion(actors.actors)
        }
    }
}
