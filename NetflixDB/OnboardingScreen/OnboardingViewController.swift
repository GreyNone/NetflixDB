//
//  ViewController.swift
//  NetflixDB
//
//  Created by Aliaksandr Vasilevich on 6/21/23.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    private let columns: CGFloat = 3
    private let rows: CGFloat = 4
    var posters = (1...12).compactMap({ UIImage(named: "poster \($0)")})
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let loginStoryboard = UIStoryboard(name: "LoginViewController", bundle: nil)
//        let loginViewController = loginStoryboard.instantiateViewController(identifier: "LoginViewController")
//        self.navigationController?.pushViewController(loginViewController, animated: true)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

//MARK: - UICollectionViewDataSourse
extension OnboardingViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
                as? PosterCollectionViewCell else { return UICollectionViewCell() }
        
        cell.imageView.image = posters[indexPath.row]
        
        return cell
    }
    
    
}

//MARK: - UICollectionViewFlowLayout
extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    
//    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
//        return UICollectionViewCompositionalLayout { [weak self] (section, _) -> NSCollectionLayoutSection? in
//            guard let viewWidth = self?.view.bounds.width,
//                  let viewHeight = self?.view.bounds.height else { return nil }
//            if section == 0 {
//                let item = NSCollectionLayoutItem(layoutSize:
//                                                    NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
//                                                                           heightDimension: .fractionalHeight(1)))
//
//                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
//
//                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(viewWidth),
//                                                                                                heightDimension: .absolute(viewHeight)),
//                                                             repeatingSubitem: item,
//                                                             count: 4)
//
//                group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
//                let section = NSCollectionLayoutSection(group: group)
//
//                return section
//            }
//            return nil
//        }
//    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        ///ISPRAVIT' REALIZATSIU
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            let paddingSpace = sectionInsets.left * (columns + 1)
            let availableWidth = view.safeAreaLayoutGuide.layoutFrame.width - paddingSpace
            let width = availableWidth / columns
            var height = view.frame.height / rows
            if height <= 200 {
                 height = view.frame.height / rows - 1
            }
            return CGSize(width: width, height: height)
        } else {
            let paddingSpace = sectionInsets.left * (columns + 1)
            let availableWidth = view.bounds.width - paddingSpace
            let width = availableWidth / columns
            let height = view.safeAreaLayoutGuide.layoutFrame.height / rows
            
            return CGSize(width: width, height: height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
