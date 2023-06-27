//
//  MainTabBarController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/23/23.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.backgroundColor = .black
        tabBar.scrollEdgeAppearance?.backgroundColor = .black
        tabBar.standardAppearance.backgroundColor = .black
        
        let homeViewControllerStoryboard = UIStoryboard(name: "HomeViewController", bundle: nil)
        let homeViewController = homeViewControllerStoryboard.instantiateViewController(withIdentifier: "HomeViewController")
        let homeNavigationController = UINavigationController(rootViewController: homeViewController)
        
        let comingSoonViewControllerStoryboard = UIStoryboard(name: "ComingSoonViewController", bundle: nil)
        let comingSoonViewController = comingSoonViewControllerStoryboard.instantiateViewController(identifier: "ComingSoonViewController")
        let comingSoonNavigationController = UINavigationController(rootViewController: comingSoonViewController)
        
        let favoritesViewControllerStoryboard = UIStoryboard(name: "FavoritesViewController", bundle: nil)
        let favotitesViewController = favoritesViewControllerStoryboard.instantiateViewController(withIdentifier: "FavoritesViewController")
        let favoritesNavigationController = UINavigationController(rootViewController: favotitesViewController)
        
        homeNavigationController.title = "Home"
        comingSoonNavigationController.title = "Coming Soon"
        favoritesNavigationController.title = "Favorites"
        
        self.setViewControllers([homeNavigationController,comingSoonNavigationController,favoritesNavigationController], animated: false)
        
        guard let items = self.tabBar.items else { return }
        
        let images = ["house","play.rectangle.on.rectangle","heart"]
        
        for x in 0...2 {
            items[x].image = UIImage(systemName: images[x])
        }
    }
    
}
