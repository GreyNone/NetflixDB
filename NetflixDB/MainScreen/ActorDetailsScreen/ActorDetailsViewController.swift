//
//  ActorDetailsViewController.swift
//  NetflixDB
//
//  Created by Александр Василевич on 2.08.23.
//

import Foundation
import UIKit

class ActorDetailsViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var placeOfBirthLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    var actor: Actor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let profilePath = actor?.profilePath, let image = CacheManager.shared.getValue(for: profilePath) {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: "user")
        }
        
        MoviesService.shared.actorDetails(actorId: actor?.id ?? 0) { [weak self] actorDetails in
            self?.nameLabel.text = actorDetails.name
            self?.departmentLabel.text = actorDetails.department
            self?.birthdayLabel.text = (actorDetails.birthday ?? "") + (" - " + (actorDetails.deathday ?? ""))
            self?.placeOfBirthLabel.text = actorDetails.placeOfBirth
            self?.biographyLabel.text = actorDetails.biography
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
}


