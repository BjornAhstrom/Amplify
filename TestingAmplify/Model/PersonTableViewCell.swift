//
//  PersonTableViewCell.swift
//  amplifyTest
//
//  Created by Björn Åhström on 2019-12-04.
//  Copyright © 2019 Björn Åhström. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    
    var typeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 18)
        label.adjustsFontSizeToFitWidth = true
            
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:  style, reuseIdentifier: reuseIdentifier)
        
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(typeLabel)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTextToLabels(type: String) {
        typeLabel.text = "\(type)"
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            typeLabel.heightAnchor.constraint(equalToConstant: 40),
            typeLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            typeLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            typeLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            typeLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5)
        ])
    }
    
}
