//
//  ViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/21/23.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var leftStackView: UIStackView!
    @IBOutlet weak var centralStackView: UIStackView!
    @IBOutlet weak var rightStackView: UIStackView!
    private let leftPosters = (1...4).compactMap({ UIImage(named: "poster\($0)")})
    private let centralPosters = (5...10).compactMap({ UIImage(named: "poster\($0)")})
    private let rightPosters = (11...14).compactMap({ UIImage(named: "poster\($0)")})
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for leftPoster in leftPosters {
            let imageView = UIImageView(image: leftPoster)
//            imageView.contentMode = .scaleAspectFill
            leftStackView.addArrangedSubview(imageView)
        }
        
        for centralPoster in centralPosters {
            let imageView = UIImageView(image: centralPoster)
//            imageView.contentMode = .scaleAspectFill
            centralStackView.addArrangedSubview(imageView)
        }
        
        for rightPoster in rightPosters {
            let imageView = UIImageView(image: rightPoster)
//            imageView.contentMode = .scaleAspectFill
            rightStackView.addArrangedSubview(imageView)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
    }
    
    //MARK: - IBActions
    @IBAction func didTapOnSignInButton(_ sender: Any) {
        let loginStoryboard = UIStoryboard(name: "LoginViewController", bundle: nil)
        let loginViewController = loginStoryboard.instantiateViewController(identifier: "LoginViewController")
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
}
