//
//  GenreView.swift
//  NetflixDB
//
//  Created by Александр Василевич on 11.07.23.
//

import UIKit

class GenreView: UIView {
    
    var genreLabel: UILabel?
    var imageView: UIImageView?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        genreLabel = UILabel()
        genreLabel?.textColor = .systemGray4
        if let genreLabel = genreLabel {
            self.addSubview(genreLabel)
        }
        
        imageView = UIImageView(image: UIImage(systemName: "circle.fill"))
        imageView?.tintColor = .systemRed
        if let imageView = imageView {
            self.addSubview(imageView)
        }
        
        setupConstraint()
    }
    
    private func setupConstraint() {
        guard let imageView = imageView,
              let genreLabel = genreLabel else { return }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: genreLabel.leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 25),
            imageView.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            genreLabel.topAnchor.constraint(equalTo: self.topAnchor),
            genreLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            genreLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}
