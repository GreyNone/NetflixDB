//
//  ImageService.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/27/23.
//

import Foundation
import UIKit
import Alamofire

final class ImageService {
    
    static let shared = ImageService()
    let headers: HTTPHeaders = [
        "accept": "application/json",
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0MGNhZGEwMmVlMDNkMGY2NGI2OTUyZmM1ZTRjYjY5MyIsInN1YiI6IjY0OTU3NGEzZDVmZmNiMDBjNTk0YjM3OSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.SYCl9DneiRF3uQ7rbXeRp1JEJ52-3h3ODaBLBhWDy4c"
    ]
    
    func image(request: DataRequest, key: String, completion: @escaping (UIImage?) -> Void) {
        request.validate().response { response in
            var image: UIImage?
            
            defer {
                DispatchQueue.main.async {
                    if let image = image {
                        CacheManager.shared.write(value: image, for: key)
                    }
                    completion(image)
                }
            }
            
            guard let data = response.data else { return }
            image = UIImage(data: data)
        }
    }
    
    func image(request: DataRequest, completion: @escaping (UIImage?) -> Void) {
        request.validate().response { response in
            var image: UIImage?
            
            defer {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            
            guard let data = response.data else { return }
            image = UIImage(data: data)
        }
    }
}
