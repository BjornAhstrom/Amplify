//
//  SplashScreenViewController.swift
//  TestingAmplify
//
//  Created by Björn Åhström on 2019-12-09.
//  Copyright © 2019 Björn Åhström. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {
    
    var splashScreen: UIImageView = {
        let splashView = UIImageView()
        splashView.layer.borderColor = UIColor.black.cgColor
        splashView.layer.borderWidth = 2
        splashView.layer.cornerRadius = 10
        splashView.layer.masksToBounds = true
        splashView.image = UIImage(named: "sum logo")
        
        return splashView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        splashScreen.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.splashScreen)

        setConstraints()
    }

    func setConstraints() {
        NSLayoutConstraint.activate([
            self.splashScreen.widthAnchor.constraint(equalToConstant: 255),
            self.splashScreen.heightAnchor.constraint(equalToConstant: 330),
            self.splashScreen.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.splashScreen.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
}
