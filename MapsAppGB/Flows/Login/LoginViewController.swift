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
    private var usersCollection: [UserRealm] = []
    private var repeatedUsersLogins: [String] = []
    
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
        self.transitionToTheNextVC()
    }
    
    @objc func signUpAction() {
        guard let login = self.loginField.text,
              let password = self.passwordField.text
        else { return }
        
        if !login.isEmpty && !password.isEmpty {
            self.savingUserToRealm(User(login: login, password: password))
        }
    }
    
    private func transitionToTheNextVC() {
        let nextVC = MapViewController()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    private func savingUserToRealm(_ user: User) {
        let userRealmCreation = UserRealm(user)
        self.loadingUsersFromRealm(user.login)
        do {
            try RealmService.saveSingleObject(items: userRealmCreation)
        } catch {
            print("Saving to Realm failed")
        }
    }
    
    private func loadingUsersFromRealm(_ userLogin: String) {
        do {
            let predicate = NSPredicate(format: "login == %@", userLogin)
            usersRealm = try RealmService.load(typeOf: UserRealm.self).filter(predicate)
            guard let user = usersRealm else { return }
            if !user.isEmpty {
                self.alarmOfNewPassword(userLogin)
            }
        } catch {
            print("Loading from Realm failed")
        }
    }
    
    private func updatingUserFromRealm(_ user: UserRealm) {
        do {
            try RealmService.saveSingleObject(items: user)
        } catch {
            print("UserUpdate has failed")
        }
    }
    
    private func alarmOfNewPassword(_ userLogin: String) {
        let alertController = UIAlertController(title: "Error", message: "Such user is already exists, please add new password", preferredStyle: .alert)
        let alertController2 = UIAlertController(title: "Success", message: "Your password has been changed for \(userLogin) login", preferredStyle: .alert)
        
        alertController.addTextField { text in
            text.placeholder = "Enter new password"
        }
        let action = UIAlertAction(title: "Confirm", style: .default) { [weak self] action in
            guard let self = self else { return }
            guard let textField = alertController.textFields?[0],
                  let text = textField.text
            else { return }
            let newObject = UserRealm(User(login: userLogin, password: text))
            self.updatingUserFromRealm(newObject)
            self.present(alertController2, animated: true)
        }
        let action2 = UIAlertAction(title: "Cool", style: .default) { action in
            self.transitionToTheNextVC()
        }
        alertController.addAction(action)
        alertController2.addAction(action2)
        present(alertController, animated: true)
    }
}
