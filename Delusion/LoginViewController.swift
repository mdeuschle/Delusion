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
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        if let retrievedString = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "FeedSegue", sender: nil)
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
                    let userData = self.createUserDataDic(providerID: credential.provider)
                    self.userSignIn(id: fbUser.uid, userData: userData)
                }
            }
        })
    }

    @IBAction func loginButtonTapped(_ sender: RoundedButton) {

        if let email = emailTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("User email authenciated with Firebase")
                    if let emailUser = user {
                        let userData = self.createUserDataDic(providerID: emailUser.providerID)
                        self.userSignIn(id: emailUser.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if let emailUser = user {
                            if error != nil {
                                print("Error during email login \(error)")
                            } else {
                                print("New user created")
                                let userData = self.createUserDataDic(providerID: emailUser.providerID)
                                self.userSignIn(id: emailUser.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }

    func createUserDataDic(providerID: String) -> [String: String] {
        return ["provider": providerID]
    }

    func userSignIn(id: String, userData: [String: String]) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        performSegue(withIdentifier: "FeedSegue", sender: nil)
    }

    func keyboardWillShow(notification: NSNotification) {

        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0{
                view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0{
                view.frame.origin.y += keyboardSize.height
            }
        }
    }

    
}



