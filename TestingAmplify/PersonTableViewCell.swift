//
//  PersonTableViewCell.swift
//  amplifyTest
//
//  Created by Björn Åhström on 2019-12-04.
//  Copyright © 2019 Björn Åhström. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    
    var idLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 13)
        label.adjustsFontSizeToFitWidth = true
            
        return label
    }()
    
    var nameLabel: UILabel = {
           let label = UILabel()
           label.textColor = .black
           label.font = .boldSystemFont(ofSize: 13)
           label.adjustsFontSizeToFitWidth = true
               
           return label
       }()
    
    var descriptionLabel: UILabel = {
           let label = UILabel()
           label.textColor = .black
           label.font = .boldSystemFont(ofSize: 13)
           label.adjustsFontSizeToFitWidth = true
               
           return label
       }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:  style, reuseIdentifier: reuseIdentifier)
        
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(idLabel)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTextToLabels(id: String, name: String, description: String) {
        idLabel.text = "Id: \(id)"
        nameLabel.text = "Name: \(name)"
        descriptionLabel.text = "Description: \(description)"
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            idLabel.heightAnchor.constraint(equalToConstant: 20),
            idLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            idLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            idLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.heightAnchor.constraint(equalToConstant: 20),
            nameLabel.topAnchor.constraint(equalTo: self.idLabel.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.heightAnchor.constraint(equalToConstant: 20),
            descriptionLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5)
        ])
    }
    
}
