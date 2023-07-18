//
//  PopularMovies.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/23/23.
//

import Foundation

struct Movie: Decodable {
    var isAdult: Bool?
    var backdropPath: String?
    var genreIds: [Int]?
    var id: Int?
    var posterPath: String?
    var releaseDate: String?
    var title: String?
    
    enum CodingKeys: String,CodingKey {
        case isAdult = "adult"
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case id
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
    }
}

struct Movies: Decodable {
    var movies: [Movie]
    var page: Int
    
    enum CodingKeys: String, CodingKey {
        case movies = "results"
        case page
    }
}

struct MovieDetail: Decodable {
    var isAdult: Bool?
    var backdropPath: String?
    var budget: CGFloat?
    var originalTitle: String?
    var overview: String?
    var popularity: CGFloat?
    var releaseDate: String?
    var revenue: CGFloat?
    var runtime: Int?
    var voteAverage: CGFloat?
    
    enum CodingKeys: String, CodingKey {
        case isAdult = "adult"
        case backdropPath = "backdrop_path"
        case budget
        case originalTitle = "original_title"
        case overview
        case popularity
        case releaseDate = "release_date"
        case revenue
        case runtime
        case voteAverage = "vote_average"
    }
}
