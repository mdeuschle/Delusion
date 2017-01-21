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
    @IBOutlet var captionTextField: UITextField!

    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var isImageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self

        DataService.ds.REF_POSTS.observe(.value, with: { (snapshots) in
            self.posts = []
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
            isImageSelected = true
        } else {
            print("Image not found")
        }

        imagePicker.dismiss(animated: true, completion: nil)
    }

    func postToFirebase(imageURL: String) {
        if let captionText = captionTextField.text {
            let postDic: Dictionary<String, AnyObject> = [
                "imageURL": imageURL as AnyObject,
                "caption": captionText as AnyObject,
                "likes": 0 as AnyObject
            ]
            DataService.ds.REF_POSTS.childByAutoId().setValue(postDic)

            captionTextField.text = ""
            isImageSelected = false
            cameraButton.setBackgroundImage(UIImage(), for: .normal)

            feedTableView.reloadData()
        }
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
    @IBAction func PostButtonTapped(_ sender: UIButton) {

        guard let caption = captionTextField.text, caption != "" else {
            //TODO alert text field empty
            return
        }
        guard let img = cameraButton.currentBackgroundImage, isImageSelected else {
            //TODO alert
            return
        }
        if let imageData = UIImageJPEGRepresentation(img, 0.2) {

            let imageID = NSUUID().uuidString
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"

            DataService.ds.REF_POSTS_IMAGES.child(imageID).put(imageData, metadata: metaData, completion: { (metaData, error) in
                if error != nil {
                    //TODO alert
                    print("Unable to download image to FB storage")
                } else {
                    print("Successfully uploaded image to FB storage")
                    if let meta = metaData {
                        if let downloadURL = meta.downloadURL()?.absoluteString {
                            self.postToFirebase(imageURL: downloadURL)
                        }
                    }
                }
            })
        }
    }
}




























