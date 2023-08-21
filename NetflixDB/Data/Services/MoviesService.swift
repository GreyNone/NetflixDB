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
    
    func popularMovies(completion: @escaping (Movies) -> Void) {
        guard let popularMoviesUrl = URL(string: "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1") else { return }
        let popularMoviesRequest = AF.request(popularMoviesUrl, method: HTTPMethod.get, headers: headers)
        popularMoviesRequest.validate().responseDecodable(of: Movies.self) { (response) in
            guard let movies = response.value else { return }
            completion(movies)
        }
    }
    
    func upcomingMovies(page: Int, completion: @escaping (Movies) -> Void) {
        guard let upcomingMoviesUrl = URL(string: "https://api.themoviedb.org/3/movie/upcoming?language=en-US&page=\(page)") else { return }
        let upcomingMoviesRequest = AF.request(upcomingMoviesUrl, method: HTTPMethod.get, headers: headers)
        upcomingMoviesRequest.validate().responseDecodable(of: Movies.self) { (response) in
            guard let movies = response.value else { return }
            completion(movies)
        }
    }
    
    func topRatedMovies(page: Int, completion: @escaping (Movies) -> Void) {
        guard let topRatedUrl = URL(string: "https://api.themoviedb.org/3/movie/top_rated?page=\(page)") else { return }
        let topRatedRequest = AF.request(topRatedUrl, method: HTTPMethod.get, headers: headers)
        topRatedRequest.validate().responseDecodable(of: Movies.self) { (response) in
            guard let movies = response.value else { return }
            completion(movies)
        }
    }
    
    func genres(completion: @escaping ([Genre]) -> Void) {
        guard let genresUrl = URL(string: "https://api.themoviedb.org/3/genre/movie/list?language=en") else { return }
        let genresRequest = AF.request(genresUrl, method: HTTPMethod.get, headers: headers)
        genresRequest.validate().responseDecodable(of: Genres.self) { (response) in
            guard let genres = response.value else { return }
            completion(genres.genres)
        }
    }
    
    func movieDetails(movieId: Int, completion: @escaping (MovieDetail) -> Void) {
        guard let movieDetailsUrl = URL(string: "https://api.themoviedb.org/3/movie/" + "\(movieId)" + "?language=en-US") else { return }
        let movieDetailsRequest = AF.request(movieDetailsUrl, method: HTTPMethod.get, headers: headers)
        movieDetailsRequest.validate().responseDecodable(of: MovieDetail.self) { (response) in
            guard let movieDetails = response.value else { return }
            completion(movieDetails)
        }
    }
    
    func actors(movieId: Int, completion: @escaping ([Actor]) -> Void) {
        guard let actorsUrl = URL(string: "https://api.themoviedb.org/3/movie/" + "\(movieId)" + "/credits") else { return }
        let actorsRequest = AF.request(actorsUrl,method: HTTPMethod.get, headers: headers)
        actorsRequest.validate().responseDecodable(of: Actors.self) { (response) in
            guard let actors = response.value else { return }
            completion(actors.actors)
        }
    }
    
    func relatedMovies(movieId: Int, completion: @escaping (Movies) -> Void) {
        guard let relatedMoviesUrl = URL(string: "https://api.themoviedb.org/3/movie/" + "\(movieId)" + "/similar?language=en-US&page=1") else { return }
        let relatedMoviesRequest = AF.request(relatedMoviesUrl, method: HTTPMethod.get, headers: headers)
        relatedMoviesRequest.validate().responseDecodable(of: Movies.self) { (response) in
            guard let movies = response.value else { return }
            completion(movies)
        }
    }
    
    
    func videos(movieId: Int, completion: @escaping ([Video]?) -> Void) {
        guard let videosUrl = URL(string: "https://api.themoviedb.org/3/movie/" + "\(movieId)" + "/videos") else { return }
        let videosRequest = AF.request(videosUrl, method: HTTPMethod.get, headers: headers)
        videosRequest.validate().responseDecodable(of: Videos.self) { (response) in
            guard let videos = response.value else { return }
            completion(videos.videos)
        }
    }
    
    func actorDetails(actorId: Int, completion: @escaping (ActorDetails) -> Void) {
        guard let actorDetailsUrl = URL(string: "https://api.themoviedb.org/3/person/" + "\(actorId)" + "?language=en-US") else { return }
        let actorDetailsRequest = AF.request(actorDetailsUrl, method: HTTPMethod.get, headers: headers)
        actorDetailsRequest.validate().responseDecodable(of: ActorDetails.self) { (response) in
            guard let actorDetails = response.value else { return }
            completion(actorDetails)
        }
    }
}
