//
//  SplashViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/21/23.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let onboardingStoryboard = UIStoryboard(name: "OnboardingViewController", bundle: nil)
        let onboardingViewController = onboardingStoryboard.instantiateViewController(identifier: "OnboardingViewController")
//        self.navigationController?.popViewController(animated: true)
        self.navigationController?.pushViewController(onboardingViewController, animated: true)
    }
    
}
