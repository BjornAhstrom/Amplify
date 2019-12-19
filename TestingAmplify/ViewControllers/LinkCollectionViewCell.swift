//
//  LinkCollectionViewCell.swift
//  TestingAmplify
//
//  Created by Björn Åhström on 2019-12-19.
//  Copyright © 2019 Björn Åhström. All rights reserved.
//

import UIKit

class LinkCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView = {
        var image = UIImageView()
        image.image = UIImage(named: "dummy") ?? UIImage()
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 10
        
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(self.imageView)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(image: UIImage) {
        self.imageView.image = image
    }
    
    func setConstraints() {
        
        NSLayoutConstraint.activate([
            self.imageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.imageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 25),
            self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25),
            self.imageView.trailingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: -25),
            self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -25)
        ])

    }
    
}
