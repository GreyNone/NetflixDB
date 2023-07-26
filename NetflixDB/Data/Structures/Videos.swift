//
//  Videos.swift
//  NetflixDB
//
//  Created by Александр Василевич on 26.07.23.
//

import Foundation

struct Video: Decodable {
    var name: String?
    var key: String?
    var site: String?
    var isOfficial: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name
        case key
        case site
        case isOfficial = "official"
    }
}

struct Videos: Decodable {
    var videos: [Video]?
    
    enum CodingKeys: String, CodingKey {
        case videos = "results"
    }
}
