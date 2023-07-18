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
        
        let url = URL(string: "https://www.themoviedb.org/signup")
        let myrequest = URLRequest(url: url!)
        webView.load(myrequest)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
}
