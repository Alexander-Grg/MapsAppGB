//
//  LoginViewController.swift
//  MapsAppGB
//
//  Created by Alexander Grigoryev on 9.11.2022.
//

import Foundation
import UIKit
import RealmSwift

class LoginViewController: UIViewController {
    
    private var usersRealm: Results<UserRealm>?
    private var isExists = false

    private(set) lazy var loginLabel: UILabel = {
       let label = UILabel()
        label.text = "MapApp"
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    private(set) lazy var loginField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your login"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .gray
        
        return textField
    }()
    
    private(set) lazy var passwordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.textColor = .gray
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    private(set) lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.addTarget(self, action: #selector(signInAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()

        return button
    }()
    
    private(set) lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.addTarget(self, action: #selector(signUpAction), for: .touchUpInside)
        button.configuration = .gray()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
    }
    
    private func configureUI() {
        self.view.backgroundColor = .white
        self.addingSubviews()
        self.configureConstraints()
    }
    
    private func addingSubviews() {
        self.view.addSubview(loginLabel)
        self.view.addSubview(loginField)
        self.view.addSubview(passwordField)
        self.view.addSubview(signInButton)
        self.view.addSubview(signUpButton)
    }
    
    private func configureConstraints() {
    
        NSLayoutConstraint.activate([
            self.loginLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100),
            self.loginLabel.widthAnchor.constraint(equalToConstant: 111),
            self.loginLabel.heightAnchor.constraint(equalToConstant: 36),
            self.loginLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),

            self.loginField.topAnchor.constraint(equalTo: self.loginLabel.bottomAnchor, constant: 20),
            self.loginField.widthAnchor.constraint(equalToConstant: 200),
            self.loginField.heightAnchor.constraint(equalToConstant: 30),
            self.loginField.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            
            self.passwordField.topAnchor.constraint(equalTo: self.loginField.bottomAnchor, constant: 5),
            self.passwordField.widthAnchor.constraint(equalToConstant: 200),
            self.passwordField.heightAnchor.constraint(equalToConstant: 30),
            self.passwordField.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            
            self.signInButton.topAnchor.constraint(equalTo: self.passwordField.bottomAnchor, constant: 15),
            self.signInButton.widthAnchor.constraint(equalToConstant: 100),
            self.signInButton.heightAnchor.constraint(equalToConstant: 30),
            self.signInButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            
            self.signUpButton.topAnchor.constraint(equalTo: self.signInButton.bottomAnchor, constant: 5),
            self.signUpButton.widthAnchor.constraint(equalToConstant: 100),
            self.signUpButton.heightAnchor.constraint(equalToConstant: 30),
            self.signUpButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    @objc func signInAction() {
        let nextVC = MapViewController()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc func signUpAction() {
        guard let login = self.loginField.text,
              let password = self.passwordField.text
        else { return }
        
        if !login.isEmpty && !password.isEmpty {
            self.savingUserToTheDB(login: login, password: password)
        }
    }
    
    private func savingUserToTheDB(login: String, password: String) {
        let user = User(login: login, password: password)
        var users: [User] = []
        
        users.append(user)
//
//
//        do {
//            usersRealm = try RealmService.load(typeOf: User.self).filter(NSPredicate(format: "login == %d", login))
//        } catch {
//            print("Such User is already exists")
//            self.isExists = true
//        }
//
//        if self.isExists {
//
//        }
//        do {
//            try RealmService.save(items: users)
//        } catch {
//            print("Saving a User to Realm failed")
//        }
//
    }
    
    
}
