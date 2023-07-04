//
//  WebViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 7/4/23.
//

import Foundation
import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var webView: WKWebView!
    var token: String?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = webView

        let headers = [
          "accept": "application/json",
          "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0MGNhZGEwMmVlMDNkMGY2NGI2OTUyZmM1ZTRjYjY5MyIsInN1YiI6IjY0OTU3NGEzZDVmZmNiMDBjNTk0YjM3OSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.SYCl9DneiRF3uQ7rbXeRp1JEJ52-3h3ODaBLBhWDy4c"
        ]

        let tokenRequest = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/authentication/token/new")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        tokenRequest.httpMethod = "GET"
        tokenRequest.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let tokenTask = session.dataTask(with: tokenRequest as URLRequest, completionHandler: { [weak self] (data, response, error) -> Void in
          if (error != nil) {
            print(error as Any)
          } else {
              let fetchedData = try! JSONDecoder().decode(RequestToken.self, from: data!)
              DispatchQueue.main.async {
                  self?.token = fetchedData.token
                  SessionManager.shared.write(token: fetchedData.token)
                  let url = URL(string: "https://www.themoviedb.org/authenticate/\(fetchedData.token)")
                  let myrequest = URLRequest(url: url!)
                  self?.webView.load(myrequest)
                  self?.webView.allowsBackForwardNavigationGestures = true
              }
          }
        })

        tokenTask.resume()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
}
