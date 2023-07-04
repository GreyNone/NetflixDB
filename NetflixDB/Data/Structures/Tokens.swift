//
//  Tokens.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 7/4/23.
//

import Foundation

struct Session: Decodable {
    var success: Bool
    var sessionId: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case sessionId = "session_id"
    }
}

struct RequestToken: Decodable {
    var success: Bool
    var expires: String
    var token: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case expires = "expires_at"
        case token = "request_token"
    }
}
