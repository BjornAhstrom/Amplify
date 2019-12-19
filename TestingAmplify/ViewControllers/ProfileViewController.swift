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
        image.image = UIImage(named: "dummyContact")
        
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
        label.text = "+46701234567"
        
        return label
    }()
    
    var mailLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        label.textColor = .black
        label.text = "mail@mail.com"
        
        return label
    }()

    var userId: String = ""
    var userName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(displayP3Red: 229, green: 229, blue: 229, alpha: 0.9)
        
        self.profileImage.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        self.mailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.profileImage)
        self.view.addSubview(self.nameLabel)
        self.view.addSubview(self.phoneNumberLabel)
        self.view.addSubview(self.mailLabel)
        
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
            self.phoneNumberLabel.heightAnchor.constraint(equalToConstant: 50),
            self.phoneNumberLabel.topAnchor.constraint(equalTo: self.profileImage.bottomAnchor, constant: 40),
            self.phoneNumberLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
            self.phoneNumberLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            self.mailLabel.heightAnchor.constraint(equalToConstant: 50),
            self.mailLabel.topAnchor.constraint(equalTo: self.phoneNumberLabel.bottomAnchor, constant: 10),
            self.mailLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
            self.mailLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40)
        ])
    }
    
}
