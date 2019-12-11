//
//  LoginViewController.swift
//  TestingAmplify
//
//  Created by Björn Åhström on 2019-12-09.
//  Copyright © 2019 Björn Åhström. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSUserPoolsSignIn

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AWSMobileClient.default().initialize { (userState, error) in
            if let userState = userState {
                switch(userState){
                case .signedIn:
                    DispatchQueue.main.async {
                        let viewController = ViewController()
                        viewController.title = "\(AWSMobileClient.default().username ?? "")"
                        self.navigationController?.pushViewController(viewController, animated: true)
                        
//                        let popup = ViewController()
//                        self.addChild(popup)
//                        popup.view.frame = self.view.frame
//                        self.view.addSubview(popup.view)
//                        popup.didMove(toParent: self)
                    }
                case .signedOut:
                    AWSMobileClient.default().showSignIn(navigationController: self.navigationController!, { (userState, error) in
                        if(error == nil){       //Successful signin
                            DispatchQueue.main.async {
//                                let viewController = ViewController()
//                                viewController.title = "\(AWSMobileClient.default().username ?? "")"
//                                self.navigationController?.pushViewController(viewController, animated: true)
                            }
                        }
                    })
                default:
                    AWSMobileClient.default().signOut()
                }
                
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
    }
}
