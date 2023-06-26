//
//  Genres.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/26/23.
//

import Foundation

struct Genre: Decodable {
    var id: Int
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case id,name
    }
}

struct Genres: Decodable {
    var genres: [Genre]
    
    enum CodingKeys: String, CodingKey {
        case genres
    }
}
