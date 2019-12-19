//
//  HideKeyboard.swift
//  TestingAmplify
//
//  Created by Björn Åhström on 2019-12-18.
//  Copyright © 2019 Björn Åhström. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyBoard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dissmissKeyboard() {
        view.endEditing(true)
    }
}
