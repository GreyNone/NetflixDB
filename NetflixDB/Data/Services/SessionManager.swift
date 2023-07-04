//
//  SessionManager.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 7/4/23.
//

import Foundation

struct SessionManager {
    
    static let shared = SessionManager()
    private let userDefaults = UserDefaults()
    
    var isUserLoggedIn: Bool {
        return userDefaults.bool(forKey: "isUserLoggedIn")
    }
    
    var sessionId: String {
        return userDefaults.string(forKey: "session") ?? "no value"
    }
    
    var requestToken: String {
        return userDefaults.string(forKey: "requestToken") ?? "no value"
    }
    
    func set(isUserLoggedIn: Bool) {
        userDefaults.set(isUserLoggedIn, forKey: "isUserLoggedIn")
    }
    
    func write(session: String) {
        userDefaults.setValue(session, forKey: "session")
    }
    
    func write(token: String) {
        userDefaults.setValue(token, forKey: "requestToken")
    }
}
