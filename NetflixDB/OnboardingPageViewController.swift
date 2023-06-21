//
//  ViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/21/23.
//

import UIKit

class OnboardingPageViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let loginStoryboard = UIStoryboard(name: "LoginViewController", bundle: nil)
        let loginViewController = loginStoryboard.instantiateViewController(identifier: "LoginViewController")
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }


}

