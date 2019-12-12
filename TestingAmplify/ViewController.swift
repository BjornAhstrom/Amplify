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
    
    var nameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.placeholder = "Name"
        
        return textField
    }()
    
    var descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.placeholder = "Description"
        
        return textField
    }()
    
    var button: UIButton = {
        let button = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 8
        button.setTitle("Run Mutation", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.addTarget(self, action: #selector(onMutationTapped), for: .touchUpInside)
        
        return button
    }()
    
    var queryButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.setTitle("Run Query", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.addTarget(self, action: #selector(onQuerytapped), for: .touchUpInside)
        
        return button
    }()
    
    var subscribeButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.setTitle("Run subscribe", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.addTarget(self, action: #selector(onSubscribeTapped), for: .touchUpInside)
        
        return button
    }()
    
//    var signOutButton: UIButton = {
//        let button = UIButton()
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor.black.cgColor
//        button.layer.cornerRadius = 8
//        button.setTitle("Sign out", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//        button.setTitleColor(.gray, for: .highlighted)
//        button.addTarget(self, action: #selector(onSignOutButtonTapped), for: .touchUpInside)
//
//        return button
//    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: self.cellId)
        
        return tableView
    }()
    
    let signOutButton = UIBarButtonItem(title: "SignOut", style: .done, target: self, action: #selector(onSignOutButtonTapped))
    let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(onEditButtonTapped))
    let cellId: String = "MyCell"
    
    var appSyncClient: AWSAppSyncClient?
    var discard: Cancellable?
    var persons: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showSignInScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.view.backgroundColor = .white
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.nameTextField.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.queryButton.translatesAutoresizingMaskIntoConstraints = false
        self.subscribeButton.translatesAutoresizingMaskIntoConstraints = false
//        self.signOutButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.nameTextField)
        self.view.addSubview(self.descriptionTextField)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.button)
        self.view.addSubview(self.queryButton)
        self.view.addSubview(self.subscribeButton)
//        self.view.addSubview(self.signOutButton)
        
        self.navigationItem.leftBarButtonItem = signOutButton
        self.navigationItem.rightBarButtonItem = editButton
        
        setConstraints()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
        
        DispatchQueue.main.async {
            self.runQuery()
        }
        
        self.hideKeyBoard()
    }
    
    @objc func onMutationTapped() {
        print("Mutation")
        runMutation(name: "\(nameTextField.text ?? "")", description: "\(descriptionTextField.text ?? "")")
    }
    
    @objc func onQuerytapped() {
        print("Query")
        runQuery()
    }
    
    @objc func onSubscribeTapped() {
        print("Subscribe")
        runSubscribe()
    }
    
    @objc func onSignOutButtonTapped() {
        // Sign out
        print("Sign out")
        signOut()
    }
    
    @objc func onEditButtonTapped() {
        print("Edit")
    }
    
    func showSignInScreen() {
        
        AWSMobileClient.default().initialize { (userState, error) in
            if let userState = userState {
                switch(userState){
                case .signedIn:
                    DispatchQueue.main.async {

                    }
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
    
    func deleteMutation() {
        let deleteMutation = DeleteTodoInput(id: "")
        appSyncClient?.perform(mutation: DeleteTodoMutation(input: deleteMutation)) {(result, error) in
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
            }
            print("Delete complete.")
        }
        
        DispatchQueue.main.async {
            self.runQuery()
        }
    }

    
    func runMutation(name: String, description: String) {
        
        let mutationInput = CreateTodoInput(name: name, description: description)
        appSyncClient?.perform(mutation: CreateTodoMutation(input: mutationInput)) {(result, error) in
            
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
            self.runQuery()
        }
        nameTextField.text = ""
        descriptionTextField.text = ""
    }
    
    func runQuery() {
        self.persons = []
        appSyncClient?.fetch(query: ListTodosQuery(), cachePolicy: .returnCacheDataAndFetch) {(result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            print("Query complete.")
            result?.data?.listTodos?.items?.forEach { ($0?.name ?? "") + " " + ($0?.description ?? "") }
            
            
            DispatchQueue.main.async {
                for res in (result?.data?.listTodos?.items ?? []) {

                    let person: Person = Person(id: res?.id ?? "", name: res?.name ?? "", description: res?.description ?? "")
                     self.persons.append(person)
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    func runSubscribe() {
        do {
            discard = try appSyncClient?.subscribe(subscription: OnCreateTodoSubscription(), resultHandler: {(result, transaction, error) in
                if let result = result {
                    print("CreateTodo subscription data:" + (result.data?.onCreateTodo?.name ?? "") )
                } else if let error = error {
                    print(error.localizedDescription)
                }
            })
            print("Subscribed to CreateTodo Mutations.")
        } catch {
            print("Error starting subscription.")
        }
    }
    
    func optimisticCreateTodo(input: CreateTodoInput, query:ListTodosQuery){
        let createTodoInput = CreateTodoInput(name: input.name, description: input.description)
        let createTodoMutation = CreateTodoMutation(input: createTodoInput)
        let UUID = NSUUID().uuidString
        
        self.appSyncClient?.perform(mutation: createTodoMutation, optimisticUpdate: { (transaction) in
            do {
                try transaction?.update(query: query) { (data: inout ListTodosQuery.Data) in
                    data.listTodos?.items?.append(ListTodosQuery.Data.ListTodo.Item.init(id: UUID, name: input.name, description: input.description!))
                }
            } catch {
                print("Error updating cache with optimistic response for \(createTodoInput)")
            }
        }, resultHandler: { (result, error) in
            if let result = result {
                print("Added Todo Response from service: \(String(describing: result.data?.createTodo?.name))")
                //Now remove the outdated entry in cache from optimistic write
                let _ = self.appSyncClient?.store?.withinReadWriteTransaction { transaction in
                    try transaction.update(query: ListTodosQuery())
                    { (data: inout ListTodosQuery.Data) in
                        var pos = -1, counter = 0
                        for item in (data.listTodos?.items!)! {
                            if item?.id == UUID {
                                pos = counter
                                continue
                            }; counter += 1
                        }
                        if pos != -1 { data.listTodos?.items?.remove(at: pos) }
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
            self.nameTextField.heightAnchor.constraint(equalToConstant: 40),
            self.nameTextField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            self.nameTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.nameTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
//            self.descriptionTextField.widthAnchor.constraint(equalToConstant: 250),
            self.descriptionTextField.heightAnchor.constraint(equalToConstant: 40),
            self.descriptionTextField.topAnchor.constraint(equalTo: self.nameTextField.bottomAnchor, constant: 10),
            self.descriptionTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.descriptionTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            self.button.widthAnchor.constraint(equalToConstant: 150),
            self.button.heightAnchor.constraint(equalToConstant: 40),
            self.button.topAnchor.constraint(equalTo: self.descriptionTextField.bottomAnchor, constant: 30),
//            self.button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            self.button.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20)
            
        ])
        
        NSLayoutConstraint.activate([
            self.queryButton.widthAnchor.constraint(equalToConstant: 150),
            self.queryButton.heightAnchor.constraint(equalToConstant: 40),
            self.queryButton.topAnchor.constraint(equalTo: self.descriptionTextField.bottomAnchor, constant: 30),
//            self.queryButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            self.queryButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.queryButton.trailingAnchor.constraint(greaterThanOrEqualTo: self.button.leadingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            self.subscribeButton.widthAnchor.constraint(equalToConstant: 150),
            self.subscribeButton.heightAnchor.constraint(equalToConstant: 40),
            self.subscribeButton.topAnchor.constraint(equalTo: self.button.bottomAnchor, constant: 20),
//            self.subscribeButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            self.subscribeButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20)
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
            self.tableView.topAnchor.constraint(equalTo: self.subscribeButton.bottomAnchor, constant: 20),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10)
        ])
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId) as? PersonTableViewCell else {
            fatalError()
        }
        let person = persons[indexPath.row] //.sorted(by: { $0.name?.lowercased() < $1.name?.lowercased() })         //[indexPath.row]
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        cell.setTextToLabels(id: person.id ?? "", name: person.name ?? "", description: person.description ?? "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 105
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = persons[indexPath.row]
        
        print(person.id)

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

