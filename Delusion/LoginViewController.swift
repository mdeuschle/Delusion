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

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func fbButtonTapped(_ sender: RoundedButton) {

        let fbLogin = FBSDKLoginManager()
        fbLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if let res = result {
                if error != nil {
                    print("Not Able To Login To FB \(error?.localizedDescription)")
                } else if res.isCancelled == true {
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
            if let use = user {
                if error != nil {
                    print("Not able to authenticate with Firebase \(error?.localizedDescription)")
                } else {
                    print("Successfully authenticated with Firebase \(use.debugDescription)")
                }
            }
        })
    }

}

