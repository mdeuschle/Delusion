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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var feedTableView: UITableView!

    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self

        DataService.ds.REF_POSTS.observe(.value, with: { (snapshots) in
            if let snaps = snapshots.children.allObjects as? [FIRDataSnapshot] {
                for snap in snaps {
                    print("SNAP: \(snap)")
                    if let postDic = snap.value as? [String: AnyObject] {
                        let post = Post(postKey: snap.key, postData: postDic)
                        self.posts.append(post)
                    }
                }
            }
            self.feedTableView.reloadData()
        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell else {
            return UITableViewCell()
        }
        let post = posts[indexPath.row]
        if let image = FeedViewController.imageCache.object(forKey: post.imageURL as NSString) {
            cell.configCell(post: post, img: image)
        } else {
            cell.configCell(post: post)
        }
        return cell
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            cameraButton.setBackgroundImage(image, for: .normal)
        } else {
            print("Image not found")
        }

        imagePicker.dismiss(animated: true, completion: nil)
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

    @IBAction func camButtonTapped(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
}










