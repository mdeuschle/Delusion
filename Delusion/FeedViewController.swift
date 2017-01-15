//
//  FeedViewController.swift
//  Delusion
//
//  Created by Matt Deuschle on 1/8/17.
//  Copyright © 2017 Matt Deuschle. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var feedTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
    }



    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {

        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("*Removed keychain: \(keychainResult)")
        do {
            try FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "LoginSegue", sender: nil)
        } catch {
            print("Unable to sign out \(error)")
        }


    }

}
