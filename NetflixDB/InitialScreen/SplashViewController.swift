//
//  SplashViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/21/23.
//

import UIKit

class SplashViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if SessionManager.shared.isUserLoggedIn {
            SessionManager.shared.getFavoriteMovies { success in
                let mainTabBarController = MainTabBarController()
                self.navigationController?.pushViewController(mainTabBarController, animated: true)
            }
        } else {
            let onboardingStoryboard = UIStoryboard(name: "OnboardingViewController", bundle: nil)
            let onboardingViewController = onboardingStoryboard.instantiateViewController(identifier: "OnboardingViewController")
            self.navigationController?.pushViewController(onboardingViewController, animated: true)
        }
    }
    
}
