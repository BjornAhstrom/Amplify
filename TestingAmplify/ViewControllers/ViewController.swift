//
//  ViewController.swift
//  TestingAmplify
//
//  Created by Björn Åhström on 2019-12-04.
//  Copyright © 2019 Björn Åhström. All rights reserved.
//

import UIKit
import AWSAppSync
import AWSMobileClient

class ViewController: UIViewController {
    
    lazy var nameTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.font = .boldSystemFont(ofSize: 25)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = " Name"
        
        return label
    }()
    
    
    var surnameTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.font = .boldSystemFont(ofSize: 25)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = " Surname"
        
        return label
    }()
    
    
    var mutationLanguageTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = .black
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.attributedPlaceholder = NSAttributedString(string: " Name",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        return textField
    }()
    
    
    var mutationButton: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 8
        button.setTitle("+", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.addTarget(self, action: #selector(onMutationTapped), for: .touchUpInside)
        
        return button
    }()
    
    
    var updateTypeButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.setTitle("Update", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.addTarget(self, action: #selector(onUpdateButtontapped), for: .touchUpInside)
        
        return button
    }()
    
    
    var deleteTypeButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.addTarget(self, action: #selector(onDeleteButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: self.cellId)
        
        return tableView
    }()
    
    
    let cellId: String = "MyCell"
    let refreshControl = UIRefreshControl()
    var userId: String = ""
    
    var timer: DispatchSourceTimer?
    var isSelected: Bool = false
    var name: String = ""
    var surname: String = ""
    var typeId: String = ""
    var appSyncClient: AWSAppSyncClient?
    var discard: Cancellable?
    var type: [CodeLanguagesInput] = []
    var languages: [Language] = []
    var links: [Link] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showSignInScreen()
        
        self.view.backgroundColor = UIColor(displayP3Red: 243/255, green: 240/255, blue: 240/255, alpha: 1)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.nameTextLabel.translatesAutoresizingMaskIntoConstraints = false
        self.surnameTextLabel.translatesAutoresizingMaskIntoConstraints = false
        self.mutationLanguageTextField.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.mutationButton.translatesAutoresizingMaskIntoConstraints = false
        self.updateTypeButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteTypeButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.nameTextLabel)
        self.view.addSubview(self.surnameTextLabel)
        self.view.addSubview(self.mutationLanguageTextField)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.mutationButton)
        self.view.addSubview(self.updateTypeButton)
        self.view.addSubview(self.deleteTypeButton)
        
        let signOutButton = UIBarButtonItem(title: "SignOut", style: .done, target: self, action: #selector(onSignOutButtonTapped))
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(onEditButtonTapped))
        self.navigationItem.leftBarButtonItem = signOutButton
        self.navigationItem.rightBarButtonItem = editButton
        
        setConstraints()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
        
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
        
        self.hideKeyBoard()
        
        let l = MockData.addMockLinks()
        self.links = l
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        DispatchQueue.main.async {
            self.checkUser()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNameAndSurname), name: NSNotification.Name(rawValue: "refreshUserQuery"), object: nil)
    }
    
    
    @objc func refreshTableView() {
        print("Refresh")
        DispatchQueue.main.async {
            self.checkUser()
        }
    }
    
    
    @objc func updateNameAndSurname() {
        DispatchQueue.main.async {
            self.checkUser()
            self.removeSpinner()
        }
    }
    
    
    @objc func onMutationTapped() {
        
        let uuid = UUID()
        
        let mutation = CodeLanguagesInput(id: uuid.uuidString, type: self.mutationLanguageTextField.text ?? "")
        self.type.append(mutation)
        self.mutationLanguageTextField.text = ""
        
        DispatchQueue.main.async {
            self.updateMutation()
        }
    }
    
    
    @objc func onUpdateButtontapped() {
        self.checkUser()
    }
    
    
    @objc func onDeleteButtonTapped() {
        DispatchQueue.main.async {
            //            self.deleteTypeMutation(id: self.typeId)
        }
    }
    
    
    @objc func onSignOutButtonTapped() {
        signOut()
    }
    
    
    @objc func onEditButtonTapped() {
        let popup = ProfileSettingsViewController()
        self.addChild(popup)
        popup.view.frame = self.view.frame
        self.view.addSubview(popup.view)
        popup.didMove(toParent: self)
    }
    
    
    func showSignInScreen() {
        AWSMobileClient.default().initialize { (userState, error) in
            if let userState = userState {
                switch(userState){
                case .signedIn:
                    print("SignedIn")
                case .signedOut:
                    AWSMobileClient.default().showSignIn(navigationController: self.navigationController!, signInUIOptions: SignInUIOptions(canCancel: false, logoImage: UIImage(named: "sum logo"), backgroundColor: UIColor.black)) { (result, err) in
                        if let result = result {
                            switch (result) {
                            case .signedIn:
                                print("SignedIn")
                                
                            case .signedOut:
                                print("SignedOut")
                            default:
                                AWSMobileClient.default().signOut()
                            }
                        } else if let error = err {
                            print(error.localizedDescription)
                        }
                    }
                default:
                    AWSMobileClient.default().signOut()
                }
                
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func signOut() {
        self.showSpinner(onView: self.view)
        
        AWSMobileClient.default().signOut(options: SignOutOptions(signOutGlobally: true)) { (error) in
            print("Error: \(error.debugDescription)")
        }
        
        DispatchQueue.main.async {
            do {
                try self.appSyncClient?.clearCaches()
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1500), execute: {
            self.showSignInScreen()
            self.removeSpinner()
        })
    }
    
    
    func createMutation() {
        let createMutation = CreateUserInput(name: "" , surname: "", codeList: [])
        
        appSyncClient?.perform(mutation: CreateUserMutation(input: createMutation)) {(result, error) in
            
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
                return
            }
            print("Mutation complete.")
            self.checkUser()
        }
    }
    
    
    func updateMutation() {
        var mutationInput = UpdateUserInput(id: userId)
        
        mutationInput.codeList = self.type
        appSyncClient?.perform(mutation: UpdateUserMutation(input: mutationInput)) {(result, error) in
            
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
                return
            }
            print("Mutation complete.")
            self.checkUser()
        }
    }
    
    
    func checkUser(){
        appSyncClient?.fetch(query: ListUsersQuery(), cachePolicy: .returnCacheDataAndFetch){ (result, error) in
            if error != nil{
                print(error?.localizedDescription ?? "error fetching")
                return
            }
            print("Fetching Userinfo")
            self.languages = []
            self.type = []
            result?.data?.listUsers?.items?.forEach {
                
                $0?.codeList?.forEach {
                    let langList = Language(id: $0?.id ?? "", type: $0?.type ?? "")
                    self.languages.append(langList)
                    
                    let item = CodeLanguagesInput(id: $0?.id ?? "", type: $0?.type ?? "")
                    self.type.append(item)
                }
                
                let person = Person(id: ($0?.id)!, name: ($0?.name)!, surname:($0?.surname)!, languages: [] )
                
                self.userId = person.id
                self.nameTextLabel.text = person.name
                self.surnameTextLabel.text = person.surname
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            self.nameTextLabel.heightAnchor.constraint(equalToConstant: 40),
            self.nameTextLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            self.nameTextLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.nameTextLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            self.surnameTextLabel.heightAnchor.constraint(equalToConstant: 40),
            self.surnameTextLabel.topAnchor.constraint(equalTo: self.nameTextLabel.bottomAnchor, constant: 10),
            self.surnameTextLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.surnameTextLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            self.mutationButton.widthAnchor.constraint(equalToConstant: 40),
            self.mutationButton.heightAnchor.constraint(equalToConstant: 40),
            self.mutationButton.topAnchor.constraint(equalTo: self.surnameTextLabel.bottomAnchor, constant: 40),
            self.mutationButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            self.mutationLanguageTextField.heightAnchor.constraint(equalToConstant: 40),
            self.mutationLanguageTextField.topAnchor.constraint(equalTo: self.surnameTextLabel.bottomAnchor, constant: 40),
            self.mutationLanguageTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.mutationLanguageTextField.trailingAnchor.constraint(equalTo: self.mutationButton.leadingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            self.updateTypeButton.widthAnchor.constraint(equalToConstant: 150),
            self.updateTypeButton.heightAnchor.constraint(equalToConstant: 40),
            self.updateTypeButton.topAnchor.constraint(equalTo: self.mutationLanguageTextField.bottomAnchor, constant: 20),
            self.updateTypeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            self.deleteTypeButton.widthAnchor.constraint(equalToConstant: 150),
            self.deleteTypeButton.heightAnchor.constraint(equalToConstant: 40),
            self.deleteTypeButton.topAnchor.constraint(equalTo: self.mutationLanguageTextField.bottomAnchor, constant: 20),
            self.deleteTypeButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.deleteTypeButton.bottomAnchor, constant: 20),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 1),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -1),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -1)
        ])
    }
}

// MARK: View controller
extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }

    
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 44
       }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId) as? PersonTableViewCell else {
            fatalError()
        }
        
        let person = languages[indexPath.row]
        
        if person.id == "633CBC6E-16E4-4F41-91F8-EB65BEC55629" {
            let links1 = MockData.addMockLinks()
            cell.links = links1
            
        } else if person.id == "57B425B4-3C25-4891-A98B-F52E120AD573" {
            let links2 = MockData.addMockLinks1()
            cell.links = links2
            
        } else if person.id == "CC8F4BED-AF86-461C-A704-094635B497FF" {
            let links3 = MockData.addMockLinks2()
            cell.links = links3
            
        } else if person.id == "E17EDAC2-BDDF-402F-B521-08171608C643" {
            let links4 = MockData.addMockLinks3()
            cell.links = links4
        } else if person.id == "D4527963-CA31-404F-9CDB-E645D1B0F17C" {
            let links5 = MockData.addMockLinks4()
            cell.links = links5
        } else {
            cell.links = self.links
        }
        
        
        cell.backgroundColor = .white
        cell.layer.masksToBounds = true
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        cell.setupCell(name: person.type)
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if languages.count != 0 {
            let person = languages[indexPath.row]
            
            if person.id == "633CBC6E-16E4-4F41-91F8-EB65BEC55629" {
                let links1 = MockData.addMockLinks()
                
                goToProfileController(userId: person.id, userName: person.type, links: links1)
                
            } else if person.id == "57B425B4-3C25-4891-A98B-F52E120AD573" {
                let links2 = MockData.addMockLinks1()
                goToProfileController(userId: person.id, userName: person.type, links: links2)
                
            } else if person.id == "CC8F4BED-AF86-461C-A704-094635B497FF" {
                let links3 = MockData.addMockLinks2()
                goToProfileController(userId: person.id, userName: person.type, links: links3)
                
            } else if person.id == "E17EDAC2-BDDF-402F-B521-08171608C643" {
                let links4 = MockData.addMockLinks3()
                goToProfileController(userId: person.id, userName: person.type, links: links4)
                
            } else if person.id == "D4527963-CA31-404F-9CDB-E645D1B0F17C" {
                let links5 = MockData.addMockLinks4()
                goToProfileController(userId: person.id, userName: person.type, links: links5)
                
            } else {
                goToProfileController(userId: person.id, userName: person.type, links: self.links)
            }
            
            typeId = person.id
            
        } else {
            return
        }
    }
    
    
    func goToProfileController(userId: String, userName: String, links: [Link]) {
        let profileController = ProfileViewController()
        profileController.userId = userId
        profileController.userName = userName
        profileController.links = links
        
        self.navigationController?.pushViewController(profileController, animated: true)
    }
}
