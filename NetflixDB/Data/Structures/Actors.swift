//
//  Actors.swift
//  NetflixDB
//
//  Created by Александр Василевич on 24.07.23.
//

import Foundation

struct Actor: Decodable {
    var department: String?
    var name: String?
    var profilePath: String?
    var character: String?
    
    enum CodingKeys: String, CodingKey {
        case department = "known_for_department"
        case name
        case profilePath = "profile_path"
        case character
    }
}

struct Actors: Decodable {
    var actors: [Actor]
    
    enum CodingKeys: String, CodingKey {
        case actors = "cast"
    }
}
