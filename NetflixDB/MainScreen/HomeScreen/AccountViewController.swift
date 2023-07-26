//
//  AccountViewController.swift
//  NetflixDB
//
//  Created by Александр Василевич on 11.07.23.
//

import UIKit

class AccountViewController: UIViewController {
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var scoreCounter: UILabel!
    @IBOutlet weak var moviesLikedCounter: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        moviesLikedCounter.text = "\(SessionManager.shared.favoriteMovies.count)"
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoutButton.layer.cornerRadius = 10
        logoutButton.layer.borderWidth = 2.0
        logoutButton.layer.borderColor = UIColor.red.cgColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    

    //MARK: - Actions
    @IBAction func didTapOnLogoutButton(_ sender: UIButton) {
        SessionManager.shared.set(isUserLoggedIn: false)
        SessionManager.shared.cleanDefaults()
        CacheManager.shared.clean()
        self.navigationController?.navigationController?.popToRootViewController(animated: true)
    }
}
