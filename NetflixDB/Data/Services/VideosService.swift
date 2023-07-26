//
//  VideosManager.swift
//  NetflixDB
//
//  Created by Александр Василевич on 26.07.23.
//

import Foundation
import Alamofire

final class VideosService {
    
    static let shared = VideosService()
    
    func videos(request: DataRequest, completion: @escaping ([Video]?) -> Void) {
        request.validate().responseDecodable(of: Videos.self) { (response) in
            guard let videos = response.value else { return }
            completion(videos.videos)
        }
    }
}
