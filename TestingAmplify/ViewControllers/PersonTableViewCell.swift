//
//  PersonTableViewCell.swift
//  amplifyTest
//
//  Created by Björn Åhström on 2019-12-04.
//  Copyright © 2019 Björn Åhström. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 15)
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    
    lazy var flowLayout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        layout.itemSize = CGSize(width: 30, height: 30) //layout.itemSize.width*6
        
        return layout
    }()
    
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout)
        view.register(PersonLinkCollectionViewCell.self, forCellWithReuseIdentifier: self.myCell)
        view.backgroundColor = .init(white: 0, alpha: 0.0)
        view.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        
        return view
    }()
    
    let myCell: String = "MyCell"
    
    var links: [Link] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
//        let mockData = MockData.addMockLinks()
//        
//        links = mockData
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(self.nameLabel)
        addSubview(self.collectionView)
        
        self.setConstraints()
        
        let separatorLineHeight: CGFloat = 3//1/UIScreen.main.scale

        let separator = UIView()

        separator.frame = CGRect(x: self.frame.origin.x,
                                 y: self.frame.size.height - separatorLineHeight,
                             width: self.frame.size.width,
                            height: separatorLineHeight)

        separator.backgroundColor = UIColor(displayP3Red: 243/255, green: 240/255, blue: 240/255, alpha: 1)

        self.addSubview(separator)
    }
    
    func setupCell(name: String) {
        nameLabel.text = name
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            self.nameLabel.heightAnchor.constraint(equalToConstant: 40),
            self.nameLabel.widthAnchor.constraint(equalToConstant: 180),
            // self.nameLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,constant: 10),
            self.nameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.collectionView.heightAnchor.constraint(equalToConstant: 40),
            self.collectionView.widthAnchor.constraint(lessThanOrEqualToConstant: 160),
//             self.collectionView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.nameLabel.trailingAnchor, constant: 10),
            self.collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
}


// MARK: collection view
extension PersonTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return links.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.myCell, for: indexPath) as? PersonLinkCollectionViewCell else {
            fatalError("Something went wrong with the cell")
        }
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        let link = links[indexPath.row]
        
        cell.setImage(image: link.linkImage ?? UIImage())
        return cell
    }
    
}
