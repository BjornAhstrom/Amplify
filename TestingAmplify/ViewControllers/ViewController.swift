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
        label.text = "Name"
        
        return label
    }()
    
    var surnameTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.font = .boldSystemFont(ofSize: 25)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Surname"
        
        return label
    }()
    
    var mutationLanguageTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.placeholder = "Code language"
        
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
    
    //    var mutationUserButton: UIButton = {
    //        let button = UIButton()
    //        button.layer.borderWidth = 1
    //        button.layer.borderColor = UIColor.black.cgColor
    //        button.layer.cornerRadius = 8
    //        button.setTitle("Save", for: .normal)
    //        button.setTitleColor(.black, for: .normal)
    //        button.setTitleColor(.gray, for: .highlighted)
    //        button.addTarget(self, action: #selector(onMutationUserTapped), for: .touchUpInside)
    //
    //        return button
    //    }()
    
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
        tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: self.cellId)
        
        return tableView
    }()
    
    
    let cellId: String = "MyCell"
    
    var timer: DispatchSourceTimer?
    var name: String = ""
    var surname: String = ""
    var typeId: String = ""
    var appSyncClient: AWSAppSyncClient?
    var discard: Cancellable?
    var type: [Type] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showSignInScreen()
        
        self.view.backgroundColor = .white
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.nameTextLabel.translatesAutoresizingMaskIntoConstraints = false
        self.surnameTextLabel.translatesAutoresizingMaskIntoConstraints = false
        self.mutationLanguageTextField.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.mutationButton.translatesAutoresizingMaskIntoConstraints = false
        //        self.mutationUserButton.translatesAutoresizingMaskIntoConstraints = false
        self.updateTypeButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteTypeButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.nameTextLabel)
        self.view.addSubview(self.surnameTextLabel)
        self.view.addSubview(self.mutationLanguageTextField)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.mutationButton)
        //        self.view.addSubview(self.mutationUserButton)
        self.view.addSubview(self.updateTypeButton)
        self.view.addSubview(self.deleteTypeButton)
        
        let signOutButton = UIBarButtonItem(title: "SignOut", style: .done, target: self, action: #selector(onSignOutButtonTapped))
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(onEditButtonTapped))
        self.navigationItem.leftBarButtonItem = signOutButton
        self.navigationItem.rightBarButtonItem = editButton
        
        setConstraints()
        
        
        
        //        DispatchQueue.main.async {
        //            self.nameTextLabel.text = UserDefaults.standard.string(forKey: "name") ?? ""
        //            self.surnameTextLabel.text = UserDefaults.standard.string(forKey: "surname") ?? ""
        //        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
        
        self.hideKeyBoard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        DispatchQueue.main.async {
            self.runUserQuery()
            self.runtypeQuery()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNameAndSurname), name: NSNotification.Name(rawValue: "refreshUserQuery"), object: nil)
    }
    
    @objc func updateNameAndSurname() {
        DispatchQueue.main.async {
            self.runUserQuery()
        }
    }
    
    @objc func onMutationTapped() {
        runCodeLanguagesMutation(language: "\(mutationLanguageTextField.text ?? "")")
    }
    
    @objc func onUpdateButtontapped() {
        DispatchQueue.main.async {
            self.runUpdateTypeMutation(id: self.typeId, typeName: self.mutationLanguageTextField.text ?? "")
        }
    }
    
    @objc func onDeleteButtonTapped() {
        DispatchQueue.main.async {
            self.deleteTypeMutation(id: self.typeId)
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
        self.showSpinner(onView: self.view)
        AWSMobileClient.default().initialize { (userState, error) in
            if let userState = userState {
                switch(userState){
                case .signedIn:
                    print("!!!!!!!!!!! SignedIn")
                    self.removeSpinner()
                case .signedOut:
                    AWSMobileClient.default().showSignIn(navigationController: self.navigationController!, signInUIOptions: SignInUIOptions(canCancel: false, logoImage: UIImage(named: "sum logo"), backgroundColor: UIColor.black)) { (result, err) in
                        if let result = result {
                            switch (result) {
                            case .signedIn:
                                print("SignedIn")
                                self.removeSpinner()
                                
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
    func runUpdateTypeMutation(id: String, typeName: String) {
        let updateMutation = UpdateCodeLanguagesInput(id: id, type: typeName)
        appSyncClient?.perform(mutation: UpdateCodeLanguagesMutation(input: updateMutation)) {(result, error) in
            
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
                return
            }
            print("Mutation complete.")
        }
        DispatchQueue.main.async {
            self.mutationLanguageTextField.text = ""
            self.runtypeQuery()
        }
    }
    
    func deleteTypeMutation(id: String) {
        let deleteMutation = DeleteCodeLanguagesInput(id: id)
        appSyncClient?.perform(mutation: DeleteCodeLanguagesMutation(input: deleteMutation)) {(result, error) in
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
            }
            print("Delete complete.")
        }
        
        DispatchQueue.main.async {
            self.runtypeQuery()
        }
    }
    
    func runCodeLanguagesMutation(language: String) {
        let mutationInput = CreateCodeLanguagesInput(type: language)
        appSyncClient?.perform(mutation: CreateCodeLanguagesMutation(input: mutationInput)) {(result, error) in
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
                return
            }
            print("Mutation complete.")
        }
        DispatchQueue.main.async {
            self.mutationLanguageTextField.text = ""
            self.runtypeQuery()
            self.tableView.reloadData()
        }
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
                DispatchQueue.main.async {
                    self.nameTextLabel.text = res?.name
                    self.surnameTextLabel.text = res?.surname
                }
            }
        }
    }
    
    func runtypeQuery() {
        
        appSyncClient?.fetch(query: ListCodeLanguagessQuery(), cachePolicy: .returnCacheDataAndFetch) {(result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            print("Query complete.")
            self.type = []
            result?.data?.listCodeLanguagess?.items?.forEach { ($0?.id ?? "") + " " + ($0?.type ?? "") }
            
            DispatchQueue.main.async {
                for res in (result?.data?.listCodeLanguagess?.items ?? []) {
                    
                    let type: Type = Type(id: res?.id, type: res?.type)
                    self.type.append(type)
                }
                self.tableView.reloadData()
                self.removeSpinner()
            }
        }
    }
    
    func runSubscribe() {
        do {
            discard = try appSyncClient?.subscribe(subscription: OnCreateUserSubscription(owner: AWSMobileClient.default().identityId ?? ""), resultHandler: {(result, transaction, error) in
                if let result = result {
                    print("CreateTodo subscription data:" + (result.data?.onCreateUser?.name ?? "") )
                } else if let error = error {
                    print(error.localizedDescription)
                }
            })
            print("Subscribed to CreateTodo Mutations.")
        } catch {
            print("Error starting subscription.")
        }
    }
    
    func optimisticCreateTodo(input: CreateUserInput, query:ListUsersQuery){
        let createTodoInput = CreateUserInput(name: input.name, surname: input.surname)
        let createTodoMutation = CreateUserMutation(input: createTodoInput)
        let UUID = NSUUID().uuidString
        
        self.appSyncClient?.perform(mutation: createTodoMutation, optimisticUpdate: { (transaction) in
            do {
                try transaction?.update(query: query) { (data: inout ListUsersQuery.Data) in
                    data.listUsers?.items?.append(ListUsersQuery.Data.ListUser.Item.init(id: UUID, name: input.name, surname: input.surname))
                }
            } catch {
                print("Error updating cache with optimistic response for \(createTodoInput)")
            }
        }, resultHandler: { (result, error) in
            if let result = result {
                print("Added Todo Response from service: \(String(describing: result.data?.createUser?.name))")
                //Now remove the outdated entry in cache from optimistic write
                let _ = self.appSyncClient?.store?.withinReadWriteTransaction { transaction in
                    try transaction.update(query: ListUsersQuery())
                    { (data: inout ListUsersQuery.Data) in
                        var pos = -1, counter = 0
                        for item in (data.listUsers?.items!)! {
                            if item?.id == UUID {
                                pos = counter
                                continue
                            }; counter += 1
                        }
                        if pos != -1 { data.listUsers?.items?.remove(at: pos) }
                    }
                }
            } else if let error = error {
                print("Error adding Todo: \(error.localizedDescription)")
            }
        })
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            //            self.nameTextField.widthAnchor.constraint(equalToConstant: 250),
            self.nameTextLabel.heightAnchor.constraint(equalToConstant: 40),
            self.nameTextLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            self.nameTextLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.nameTextLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            //            self.descriptionTextField.widthAnchor.constraint(equalToConstant: 250),
            self.surnameTextLabel.heightAnchor.constraint(equalToConstant: 40),
            self.surnameTextLabel.topAnchor.constraint(equalTo: self.nameTextLabel.bottomAnchor, constant: 10),
            self.surnameTextLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.surnameTextLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
        
        //        NSLayoutConstraint.activate([
        //            self.mutationUserButton.widthAnchor.constraint(equalToConstant: 150),
        //            self.mutationUserButton.heightAnchor.constraint(equalToConstant: 40),
        //            self.mutationUserButton.topAnchor.constraint(equalTo: self.surnameTextLabel.bottomAnchor, constant: 40),
        //            self.mutationUserButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        //        ])
        
        NSLayoutConstraint.activate([
            self.mutationButton.widthAnchor.constraint(equalToConstant: 40),
            self.mutationButton.heightAnchor.constraint(equalToConstant: 40),
            self.mutationButton.topAnchor.constraint(equalTo: self.surnameTextLabel.bottomAnchor, constant: 40),
            // self.button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            // self.mutationButton.leadingAnchor.constraint(greaterThanOrEqualTo: self.mutationTextField.leadingAnchor, constant: 20),
            self.mutationButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            // self.descriptionTextField.widthAnchor.constraint(equalToConstant: 250),
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
        
        //        NSLayoutConstraint.activate([
        //            self.signOutButton.widthAnchor.constraint(equalToConstant: 150),
        //            self.signOutButton.heightAnchor.constraint(equalToConstant: 40),
        //            self.signOutButton.topAnchor.constraint(equalTo: self.queryButton.bottomAnchor, constant: 20),
        ////            self.signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        //            self.signOutButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
        //            self.signOutButton.trailingAnchor.constraint(greaterThanOrEqualTo: self.subscribeButton.leadingAnchor, constant: 20)
        //        ])
        
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.deleteTypeButton.bottomAnchor, constant: 20),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10)
        ])
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return type.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId) as? PersonTableViewCell else {
            fatalError()
        }
        let t = type[indexPath.row]
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        cell.setTextToLabels(type: "\(indexPath.row + 1): \(t.type ?? "")")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let t = type[indexPath.row]
        
        typeId = t.id ?? ""
        self.mutationLanguageTextField.text = t.type
    }
}

// MARK: Hide keyboard
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

var vSpinner : UIView?

// UIActivityIndicator
extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

