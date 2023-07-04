//
//  SignUpViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/22/23.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {

    override func loadView() {
        super.loadView()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapOnSignUpButton(_ sender: Any) {
        let webViewController = WebViewController()
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
}
