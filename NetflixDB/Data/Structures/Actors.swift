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
    var id: Int
    
    enum CodingKeys: String, CodingKey {
        case department = "known_for_department"
        case name
        case profilePath = "profile_path"
        case character
        case id
    }
}

struct Actors: Decodable {
    var actors: [Actor]
    
    enum CodingKeys: String, CodingKey {
        case actors = "cast"
    }
}

struct ActorDetails: Decodable {
    var biography: String
    var birthday: String
    var deathday: String
    var gender: Int
    var department: String
    var name: String
    var placeOfBirth: String
    
    enum CodingKeys: String, CodingKeys {
        case biography
        case birthday
        case deathday
        case gender
        case department = "known_for_department"
        case name
        case placeOfBirth = "place_of_birth"
    }
}
