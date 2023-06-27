//
//  MoyaProvider.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/23/23.
//

import Foundation
import Moya

enum MyService {
    case popularMovies
}

extension MyService: TargetType {
    
    var headers: [String : String]? {
        switch self {
        case .popularMovies:
            let headers = ["accept": "application/json",
                           "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0MGNhZGEwMmVlMDNkMGY2NGI2OTUyZmM1ZTRjYjY5MyIsInN1YiI6IjY0OTU3NGEzZDVmZmNiMDBjNTk0YjM3OSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.SYCl9DneiRF3uQ7rbXeRp1JEJ52-3h3ODaBLBhWDy4c"]
            return headers
        }
    }
    
    var baseURL: URL {
        switch self {
        case .popularMovies:
            return URL(string: "https://api.themoviedb.org")!
        }
    }
    
    var path: String {
        switch self {
        case .popularMovies:
            return "/3/movie/popular?language=en-US&page=1"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .popularMovies:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .popularMovies:
            return .requestPlain
        }
    }
    
}

protocol CachePolicyGettable {
    var cachePolicy: URLRequest.CachePolicy { get }
}

final class CachePolicyPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if let cachePolicyGettable = target as? CachePolicyGettable {
            var mutableRequest = request
            mutableRequest.cachePolicy = cachePolicyGettable.cachePolicy
            return mutableRequest
        }
        
        return request
    }
}

extension MyService: CachePolicyGettable {
    var cachePolicy: URLRequest.CachePolicy {
        switch self {
        case .popularMovies:
            return .useProtocolCachePolicy
        }
    }
}
