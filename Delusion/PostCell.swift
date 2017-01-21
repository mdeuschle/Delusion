//
//  PostCell.swift
//  Delusion
//
//  Created by Matt Deuschle on 1/10/17.
//  Copyright © 2017 Matt Deuschle. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet var likesImage: CircleView!

    var post: Post!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configCell(post: Post, img: UIImage? = nil) {
        self.post = post
        self.caption.text = post.caption
        self.likesLabel.text = String(post.likes)
        if img != nil {
            self.postImage.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imageURL)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("unable to download image from storage")
                } else {
                    print("*Image downloaded from FB Storage")
                    if let imageData = data {
                        if let img = UIImage(data: imageData) {
                            self.postImage.image = img
                            FeedViewController.imageCache.setObject(img, forKey: post.imageURL as NSString)
                        }
                    }
                }
            })
        }
        let likesRef = DataService.ds.REF_USER_CURRENT.child("likes")
        likesRef.observe(.value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImage.image = #imageLiteral(resourceName: "empty-heart")
            } else {
                self.likesImage.image = #imageLiteral(resourceName: "filled-heart")
            }
        })

    }
}

























