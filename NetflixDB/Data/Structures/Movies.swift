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
    var originalLanguage: String?
    var originalTitle: String?
    var overview: String?
    var popularity: CGFloat?
    var posterPath: String?
    var releaseDate: String?
    var title: String?
    var voteAverage: CGFloat?
    var voteCount: Int?
    
    enum CodingKeys: String,CodingKey {
        case isAdult = "adult"
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
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

