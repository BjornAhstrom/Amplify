//
//  ProfileViewController.swift
//  TestingAmplify
//
//  Created by Björn Åhström on 2019-12-18.
//  Copyright © 2019 Björn Åhström. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var profileImage: UIImageView = {
        let image = UIImageView()
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.gray.cgColor
        image.layer.cornerRadius = 50
        image.clipsToBounds = true
        image.image = UIImage(named: "dummy")
        
        return image
    }()
    
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .black
        label.text = "Test name"
        
        return label
    }()
    
    
    var phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        label.textColor = .black
        label.text = " ✆ +46701234567"
        
        return label
    }()
    
    
    var mailLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        label.textColor = .black
        label.text = " ✉︎  mail@mail.com"
        
        return label
    }()
    
    
    lazy var flowLayout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
        layout.itemSize = CGSize(width: 80, height: 80) //layout.itemSize.width*6
        
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
    var userId: String = ""
    var userName: String = ""
    var links: [Link] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(displayP3Red: 243/255, green: 240/255, blue: 240/255, alpha: 1)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
//        let mockData = MockData.addMockLinks()
        
//        links = mockData
        
        self.profileImage.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        self.mailLabel.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.profileImage)
        self.view.addSubview(self.nameLabel)
        self.view.addSubview(self.phoneNumberLabel)
        self.view.addSubview(self.mailLabel)
        self.view.addSubview(self.collectionView)
        
        self.nameLabel.text = userName
        
        self.setConstraints()
    }
    
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            self.profileImage.heightAnchor.constraint(equalToConstant: 100),
            self.profileImage.widthAnchor.constraint(equalToConstant: 100),
            self.profileImage.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 150),
            self.profileImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40)
        ])
        
        NSLayoutConstraint.activate([
            self.nameLabel.heightAnchor.constraint(equalToConstant: 30),
            self.nameLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 155),
            self.nameLabel.leadingAnchor.constraint(equalTo: self.profileImage.trailingAnchor, constant: 20),
            self.nameLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            self.phoneNumberLabel.heightAnchor.constraint(equalToConstant: 40),
            self.phoneNumberLabel.topAnchor.constraint(equalTo: self.profileImage.bottomAnchor, constant: 40),
            self.phoneNumberLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            self.phoneNumberLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30)
        ])
        
        NSLayoutConstraint.activate([
            self.mailLabel.heightAnchor.constraint(equalToConstant: 40),
            self.mailLabel.topAnchor.constraint(equalTo: self.phoneNumberLabel.bottomAnchor, constant: 10),
            self.mailLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            self.mailLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: mailLabel.bottomAnchor, constant: 30),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }
}


// MARK: collection view
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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

// "sms:%@"
// "tel:%@"
// "mailto:%@"
// "facetime:%@"
// "https://stackoverflow.com" Safari


// MARK: Mock data
extension UIViewController {
    
//    func addMockLinks() -> [Link] {
//        var links: [Link] = []
//
//        let email = Link(linkImage:  UIImage(named: "email"), name: "email")
//        links.append(email)
//        let facebook = Link(linkImage: UIImage(named: "facebook"), name: "facebook")
//        links.append(facebook)
//        let facetime = Link(linkImage: UIImage(named: "facetime"), name: "facetime")
//        links.append(facetime)
//        let instagram = Link(linkImage: UIImage(named: "instagram"), name: "instagram")
//        links.append(instagram)
//        let linkedin = Link(linkImage: UIImage(named: "linkedin"), name: "linkedin")
//        links.append(linkedin)
//        let phone = Link(linkImage: UIImage(named: "phone"), name: "phone")
//        links.append(phone)
//        let pinterest = Link(linkImage: UIImage(named: "pinterest"), name: "pinterest")
//        links.append(pinterest)
//        let skype = Link(linkImage: UIImage(named: "skype"), name: "skype")
//        links.append(skype)
//        let sms = Link(linkImage: UIImage(named: "sms"), name: "sms")
//        links.append(sms)
//        let snapshat = Link(linkImage: UIImage(named: "snapshat"), name: "snapshat")
//        links.append(snapshat)
//        let soundcloud = Link(linkImage: UIImage(named: "soundcloud"), name: "soundcloud")
//        links.append(soundcloud)
//        let tumblr = Link(linkImage: UIImage(named: "tumblr"), name: "tumblr")
//        links.append(tumblr)
//        let twitter = Link(linkImage: UIImage(named: "twitter"), name: "twitter")
//        links.append(twitter)
//        let whatsapp = Link(linkImage: UIImage(named: "whatsapp"), name: "whatsapp")
//        links.append(whatsapp)
//
//        return links
//    }
    
}
