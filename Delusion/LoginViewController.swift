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

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()

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
            if error != nil {
                print("Not Able To Login To FB \(error?.localizedDescription)")
            } else if result?.isCancelled == true {
                print("User cancelled FB auth \(result?.debugDescription)")
            } else {
                print("Successfully authenticated with FB \(result)")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.fireBaseAuth(credential)
            }
        }
    }

    func fireBaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if let use = user {
                if error != nil {
                    print("Not able to authenticate with Firebase \(error?.localizedDescription)")
                } else {
                    print("Successfully authenticated with Firebase \(use.debugDescription)")
                }
            }
        })
    }

    @IBAction func loginButtonTapped(_ sender: RoundedButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("User email authenciated with Firebase \(user?.email)")
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("Error during email login \(error?.localizedDescription)")
                        } else {
                            print("New user created \(user?.email)")
                        }
                    })
                }
            })
        }
    }
}

