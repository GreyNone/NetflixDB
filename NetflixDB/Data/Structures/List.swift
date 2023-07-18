//
//  File.swift
//  NetflixDB
//
//  Created by Александр Василевич on 13.07.23.
//

import Foundation

struct List: Decodable {
    var name: String?
    var id: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case id = "id"
    }
}

struct Lists: Decodable {
    var results: [List]?
    var totalPages: Int?
    
    enum CodingKeys: String, CodingKey {
        case results
        case totalPages = "total_pages"
    }
}

struct NewList: Decodable {
    var listId: Int?
    
    enum CodingKeys: String, CodingKey {
        case listId = "list_id"
    }
}
