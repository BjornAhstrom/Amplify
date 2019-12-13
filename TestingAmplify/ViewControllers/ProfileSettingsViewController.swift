//
//  ProfileSettingsViewController.swift
//  TestingAmplify
//
//  Created by Björn Åhström on 2019-12-13.
//  Copyright © 2019 Björn Åhström. All rights reserved.
//

import UIKit
import AWSAppSync
import AWSMobileClient

class ProfileSettingsViewController: UIViewController {
    
    var uiView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = .init(white: 0.3, alpha: 1)
        
        return view
    }()
    
    var upperTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.font = .boldSystemFont(ofSize: 25)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Profile settings"
        
        return label
    }()
    
    var nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = .white
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.placeholder = "Name"
        
        return textField
    }()
    
    var surnameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = .white
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.placeholder = "Surname"
        
        return textField
    }()
    
    var updateButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 8
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.systemGray2, for: .highlighted)
        
        return button
    }()
    
    var saveButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 8
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.systemGray2, for: .highlighted)
        
        return button
    }()
    
    var cancelButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 8
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.systemGray2, for: .highlighted)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(onCancelButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    var appSyncClient: AWSAppSyncClient?
    var viewController: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        upperTextLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        surnameTextField.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(uiView)
        uiView.addSubview(upperTextLabel)
        uiView.addSubview(nameTextField)
        uiView.addSubview(surnameTextField)
        uiView.addSubview(cancelButton)
        uiView.addSubview(updateButton)
        uiView.addSubview(saveButton)
        
        view.backgroundColor = .init(white: 0, alpha: 0.5)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
        
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        runUserQuery()
    }
    
    func runUserQuery() {
        appSyncClient?.fetch(query: ListUsersQuery(), cachePolicy: .returnCacheDataAndFetch) {(result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            print("Query complete.")
            result?.data?.listUsers?.items?.forEach { ($0?.name ?? "") + " " + ($0?.surname ?? "") }
            
            for res in result?.data?.listUsers?.items ?? [] {
                self.nameTextField.text = res?.name
                self.surnameTextField.text = res?.surname
            }
            
            if self.nameTextField.text != "" || self.surnameTextField.text != "" {
                self.saveButton.isHidden = true
                self.updateButton.setTitle("Update", for: .normal)
                self.updateButton.addTarget(self, action: #selector(self.onUpdateButtonPressed), for: .touchUpInside)
            }
            else if self.nameTextField.text == "" && self.surnameTextField.text == "" {
                self.updateButton.isHidden = true
                self.saveButton.setTitle("Save", for: .normal)
                self.saveButton.addTarget(self, action: #selector(self.onSaveButtonPressed), for: .touchUpInside)
            }
        }
    }
    
    func runMutation(name: String, surname: String) {
        
        let mutationInput = CreateUserInput(id: AWSMobileClient.default().identityId ?? "", name: name, surname: surname)
        appSyncClient?.perform(mutation: CreateUserMutation(input: mutationInput)) {(result, error) in
            
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
                return
            }
            print("Mutation complete.")
        }
    }
    
    func runUpdateUserMutation(name: String, surname: String) {
        let updateMutation = UpdateUserInput(id: AWSMobileClient.default().identityId ?? "", name: name, surname: surname)
        appSyncClient?.perform(mutation: UpdateUserMutation(input: updateMutation)) {(result, error) in
            
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
                return
            }
            print("Mutation complete.")
        }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            uiView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uiView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            uiView.widthAnchor.constraint(equalToConstant: 300),
            uiView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        NSLayoutConstraint.activate([
            upperTextLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            upperTextLabel.topAnchor.constraint(equalTo: uiView.topAnchor, constant: 10),
            upperTextLabel.leadingAnchor.constraint(equalTo: uiView.leadingAnchor, constant: 10),
            upperTextLabel.trailingAnchor.constraint(equalTo: uiView.trailingAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            self.nameTextField.heightAnchor.constraint(equalToConstant: 40),
            self.nameTextField.topAnchor.constraint(equalTo: self.upperTextLabel.bottomAnchor, constant: 30),
            self.nameTextField.leadingAnchor.constraint(equalTo: self.uiView.leadingAnchor, constant: 20),
            self.nameTextField.trailingAnchor.constraint(equalTo: self.uiView.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            self.surnameTextField.heightAnchor.constraint(equalToConstant: 40),
            self.surnameTextField.topAnchor.constraint(equalTo: self.nameTextField.bottomAnchor, constant: 10),
            self.surnameTextField.leadingAnchor.constraint(equalTo: self.uiView.leadingAnchor, constant: 20),
            self.surnameTextField.trailingAnchor.constraint(equalTo: self.uiView.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.widthAnchor.constraint(equalToConstant: 100),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.leadingAnchor.constraint(equalTo: uiView.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: uiView.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            updateButton.widthAnchor.constraint(equalToConstant: 100),
            updateButton.heightAnchor.constraint(equalToConstant: 40),
            updateButton.leadingAnchor.constraint(greaterThanOrEqualTo: cancelButton.trailingAnchor),
            updateButton.trailingAnchor.constraint(equalTo: uiView.trailingAnchor, constant: -20),
            updateButton.bottomAnchor.constraint(equalTo: uiView.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            saveButton.leadingAnchor.constraint(greaterThanOrEqualTo: cancelButton.trailingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: uiView.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: uiView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc func onCancelButtonPressed() {
        self.view.removeFromSuperview()
    }
    
    @objc func onUpdateButtonPressed() {
        print("Update")
        self.showSpinner(onView: self.view)
        self.runUpdateUserMutation(name: self.nameTextField.text ?? "", surname: self.surnameTextField.text ?? "")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserQuery"), object: nil, userInfo: nil)
            self.view.removeFromSuperview()
            self.removeSpinner()
        }
    }
    
    @objc func onSaveButtonPressed() {
        print("Save")
        self.showSpinner(onView: self.view)
        self.runMutation(name: self.nameTextField.text ?? "", surname: self.surnameTextField.text ?? "")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshUserQuery"), object: nil, userInfo: nil)
            self.view.removeFromSuperview()
            self.removeSpinner()
        }
    }
    
}

