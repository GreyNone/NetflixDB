//
//  SessionManager.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 7/4/23.
//

import Foundation
import Alamofire

private enum Keys: String {
    case isUserLoggedIn
    case session
    case listId
    case favoriteMovies
}

class SessionManager {
    
    static let shared = SessionManager()
    private let userDefaults = UserDefaults()
    private var observers = NSMutableSet()
    
    var favoriteMovies = [Movie]()
    
    var isUserLoggedIn: Bool {
        return userDefaults.bool(forKey: Keys.isUserLoggedIn.rawValue)
    }
    
    var sessionId: String {
        return userDefaults.string(forKey: Keys.session.rawValue) ?? "no value"
    }
    
    var listId: Int {
        return userDefaults.integer(forKey: Keys.listId.rawValue)
    }
    
    func set(isUserLoggedIn: Bool) {
        userDefaults.set(isUserLoggedIn, forKey: Keys.isUserLoggedIn.rawValue)
    }
    
    func set(session: String) {
        userDefaults.setValue(session, forKey: Keys.session.rawValue)
    }
    
    func set(listId: Int) {
        userDefaults.setValue(listId, forKey: Keys.listId.rawValue)
    }
    
    func cleanDefaults() {
        userDefaults.removeObject(forKey: Keys.session.rawValue)
        userDefaults.removeObject(forKey: Keys.listId.rawValue)
        userDefaults.removeObject(forKey: Keys.favoriteMovies.rawValue)
    }
    
    func login(login: String, password: String, completion: @escaping (Bool) -> Void) {
        guard let tokenUrl = URL(string: "https://api.themoviedb.org/3/authentication/token/new") else { return }
        let tokenRequest = AF.request(tokenUrl, method: HTTPMethod.get, headers: headers)
        //creating request token
        tokenRequest.validate().responseDecodable(of: RequestToken.self) { [weak self] (response) in
            guard let fetchedToken = response.value,
                let success = fetchedToken.success else { return }
            
            if success {
                guard let tokenValidationUrl = URL(string: "https://api.themoviedb.org/3/authentication/token/validate_with_login") else { return }
                
                let parameters = ["username": "\(login)",
                                  "password": "\(password)",
                                  "request_token": "\(fetchedToken.token ?? "")"
                ] as [String : Any]       
                let validationRequest = AF.request(tokenValidationUrl, method: HTTPMethod.post, parameters: parameters, headers: headers)
                //validating request token with user's login and password
                validationRequest.validate().responseDecodable(of: RequestToken.self) { (response) in
                    guard let validatedToken = response.value,
                          let success = validatedToken.success else { return }
                    
                    if success {
                        guard let sessionUrl = URL(string: "https://api.themoviedb.org/3/authentication/session/new"),
                              let listUrl = URL(string: "https://api.themoviedb.org/3/account/20052144/lists?page=1") else { return }
        
                        //creating new session
                        let tokenParameters = ["request_token": "\(validatedToken.token ?? "")"] as [String : Any]
                        let sessionRequest = AF.request(sessionUrl,method: HTTPMethod.post, parameters: tokenParameters, headers: headers)
                        
                        sessionRequest.validate().responseDecodable(of: Session.self) { (response) in
                            guard let session = response.value,
                                  let sessionId = session.sessionId,
                                  let success = session.success else { return }
                            
                            if success {
                                self?.set(session: sessionId)
                                self?.set(isUserLoggedIn: success)
                            }
                            
                            //fetching lists
                            let listsRequest = AF.request(listUrl, method: HTTPMethod.get, headers: headers)
                            
                            listsRequest.validate().responseDecodable(of: Lists.self) { (response) in
                                guard let lists = response.value,
                                      let result = lists.results else { return }
                                
                                //checking existence of lists
                                if result.isEmpty {
                                    //creating list
                                    guard let createListUrl = URL(string: "https://api.themoviedb.org/3/list") else { return }
                                    
                                    let parameters = [
                                      "name": "Favorites",
                                    ] as [String : Any]
                                    let creatingListsRequest = AF.request(createListUrl,
                                                                          method: HTTPMethod.post,
                                                                          parameters: parameters,
                                                                          headers: headers)
                                    
                                    creatingListsRequest.validate().responseDecodable(of: NewList.self) { (response) in
                                        guard let newList = response.value,
                                              let listId = newList.listId else { return }
                                        
                                        self?.set(listId: listId)
                                        completion(success)
                                    }
                                } else {
                                    //setting list if it exists
                                    guard let id = result[0].id else { return }
                                    self?.set(listId: id)
                                    
                                    self?.getFavoriteMovies { success in
                                        completion(success)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addToFavorites(movieId: Int, completion: @escaping (Bool) -> Void) {
        guard let favoritesAddUrl = URL(string: "https://api.themoviedb.org/3/list/\(SessionManager.shared.listId)/add_item") else { return }
        
        let parameters = ["media_id": (movieId)] as [String : Any]
        let favoritesAddRequest = AF.request(favoritesAddUrl,
                                              method: HTTPMethod.post,
                                              parameters: parameters,
                                              headers: headers)
        favoritesAddRequest.validate().response { response in
            switch response.result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    func removeFromFavorites(movieId: Int, completion: @escaping (Bool) -> Void) {
        guard let favoritesRemoveUrl = URL(string: "https://api.themoviedb.org/3/list/\(SessionManager.shared.listId)/remove_item") else { return }
        
        let parameters = ["media_id": movieId] as [String : Any]
        let favoritesRemoveRequest = AF.request(favoritesRemoveUrl,
                                                method: HTTPMethod.post,
                                                parameters: parameters,
                                                headers: headers)
        favoritesRemoveRequest.validate().response { response in
            switch response.result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    func getFavoriteMovies(completion: @escaping (Bool) -> Void) {
        guard let favoritesUrl = URL(string: "https://api.themoviedb.org/3/list/\(listId)") else { return }
        
        let favoritesRequest = AF.request(favoritesUrl,method: HTTPMethod.get, headers: headers)
        favoritesRequest.validate().responseDecodable(of: FavoriteMovies.self) { [weak self] response in
            guard let fetchedMovies = response.value,
                  let fetchedFavoriteMovies = fetchedMovies.movies  else { return }
            
            self?.favoriteMovies = fetchedFavoriteMovies
            completion(true)
        }
    }
}

//MARK: - Observer protocol
extension SessionManager: Subject {
    
    func addObserver(observer: Observer) {
        observers.add(WeakObserver(value: observer))
    }
    
    func removeObserver(observer: Observer) {
        observers.remove(observer)
    }
    
    func notify() {
        for observer in observers {
            guard let weakObserver = observer as? WeakObserver,
                  let value = weakObserver.value  else { return }
            value.update()
        }
    }
}

