//
//  LoginViewController.swift
//  Delusion
//
//  Created by Matt Deuschle on 1/8/17.
//  Copyright © 2017 Matt Deuschle. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigation = navigationController {
            navigation.setNavigationBarHidden(true, animated: true)
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        if let retrievedString = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "feedSegue", sender: nil)
            print("KEY UID: \(retrievedString)")
        }
    }


    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField {
            emailTextField.placeholder = ""
        }
        if textField == passwordTextField {
            passwordTextField.placeholder = ""
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField && emailTextField.text == "" {
            emailTextField.placeholder = "Email"
        }
        if textField == passwordTextField && passwordTextField.text == "" {
            passwordTextField.placeholder = "Password"
        }
    }

    @IBAction func fbButtonTapped(_ sender: RoundedButton) {

        let fbLogin = FBSDKLoginManager()
        fbLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if let res = result {
                if error != nil {
                    print("Not Able To Login To FB \(error?.localizedDescription)")
                } else if result?.isCancelled == true {
                    print("User cancelled FB auth \(res.debugDescription)")
                } else {
                    print("Successfully authenticated with FB \(res)")
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    self.fireBaseAuth(credential)
                }
            }
        }
    }

    func fireBaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if let fbUser = user {
                if error != nil {
                    print("Not able to authenticate with Firebase \(error?.localizedDescription)")
                } else {
                    print("Successfully authenticated with Firebase \(fbUser.debugDescription)")
                    self.keyChainSignIn(id: fbUser.uid)
                }
            }
        })
    }

    @IBAction func loginButtonTapped(_ sender: RoundedButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if let oldUser = user {
                    if error == nil {
                        print("User email authenciated with Firebase \(oldUser.email)")
                        self.keyChainSignIn(id: oldUser.uid)
                    } else {
                        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                            if let newUser = user {
                                if error != nil {
                                    print("Error during email login \(error?.localizedDescription)")
                                } else {
                                    print("New user created \(newUser.email)")
                                    self.keyChainSignIn(id: newUser.uid)
                                }
                            }
                        })
                    }
                }
            })
        }
    }

    func keyChainSignIn(id: String) {
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        performSegue(withIdentifier: "feedSegue", sender: nil)
    }
}

