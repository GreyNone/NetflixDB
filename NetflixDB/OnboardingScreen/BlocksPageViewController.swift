//
//  BlocksPageViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/22/23.
//

import Foundation
import UIKit

class BlocksPageViewController: UIPageViewController {
    
    private(set) lazy var orderedViewControllers: [UIViewController] = createViewControllers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true)
        }
        
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [BlocksPageViewController.self])
        pageControl.currentPageIndicatorTintColor = .red
        pageControl.pageIndicatorTintColor = .lightGray
    }
    
    private func createViewControllers() -> [UIViewController] {
        let descriptionViewControllerStoryboard = UIStoryboard(name: "DescriptionViewController", bundle: nil)
        let descriptionViewController = descriptionViewControllerStoryboard.instantiateViewController(identifier: "DescriptionViewController")
        
        let signUpViewControllerStoryboard = UIStoryboard(name: "SignUpViewController", bundle: nil)
        let signUpViewController = signUpViewControllerStoryboard.instantiateViewController(withIdentifier: "SignUpViewController")
        
        return [descriptionViewController,signUpViewController]
    }
}

//MARK: - UIPageViewControllerDataSourse
extension BlocksPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil}
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return orderedViewControllers.last }
        guard orderedViewControllers.count > previousIndex else { return nil }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else { return orderedViewControllers.first }
        guard orderedViewControllersCount > nextIndex else { return nil }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
              let firstViewControllerIndex = orderedViewControllers.firstIndex(of: firstViewController) else { return 0 }
        
        return firstViewControllerIndex
    }
}
