//
//  NameTableViewCell.swift
//  TestingAmplify
//
//  Created by Björn Åhström on 2019-12-19.
//  Copyright © 2019 Björn Åhström. All rights reserved.
//

import UIKit

class NameTableViewCell: UITableViewCell {
    
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = true
        label.font = .boldSystemFont(ofSize: 25)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.text = "Name"
        
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
        view.register(LinkCollectionViewCell.self, forCellWithReuseIdentifier: self.myCell)
        view.backgroundColor = .init(white: 0, alpha: 0.0)
        view.allowsMultipleSelection = true
        
        return view
    }()
    
    let myCell: String = "MyCell"
    
    var links: [Link] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        let mockData = MockData.addMockLinks()
        
        links = mockData
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(self.nameLabel)
        addSubview(self.collectionView)
        
        self.setConstraints()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(name: String) {
        nameLabel.text = name
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            self.nameLabel.widthAnchor.constraint(equalToConstant: 150),
            self.nameLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.nameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.collectionView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.nameLabel.trailingAnchor, constant: 10),
            self.collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
}


// MARK: collection view
extension NameTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return links.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.myCell, for: indexPath) as? LinkCollectionViewCell else {
            fatalError("Something went wrong with the cell")
        }
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        
        let link = links[indexPath.row]
        
        cell.setImage(image: link.linkImage ?? UIImage())
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = .lightGray
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = links[indexPath.row]
        
        if selectedImage.name == "sms" {
            openDeepLink()
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = nil
        }
    }
    
    
    //    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    //        return true
    //    }
    //
    //    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    //        let device = devices.remove(at: sourceIndexPath.item)
    //        devices.insert(device, at: destinationIndexPath.item)
    //    }
    
    
    func openDeepLink() {
        
        let sms: String = "sms:%@"          //"sms:+46736482006&body=Hello Abc How are You I am ios developer."
        let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
    }
}
