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
    var likesRef: FIRDatabaseReference!

    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped))
        tap.numberOfTapsRequired = 1
        likesImage.addGestureRecognizer(tap)
        likesImage.isUserInteractionEnabled = true
    }

    func configCell(post: Post, img: UIImage? = nil) {
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
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
        likesRef.observe(.value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImage.image = #imageLiteral(resourceName: "empty-heart")
            } else {
                self.likesImage.image = #imageLiteral(resourceName: "filled-heart")
            }
        })
    }
    func likeTapped(sender: UITapGestureRecognizer) {
            likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImage.image = #imageLiteral(resourceName: "filled-heart")
                self.post.adjustLikes(isLiked: true)
                self.likesRef.setValue(true)
            } else {
                self.likesImage.image = #imageLiteral(resourceName: "empty-heart")
                self.post.adjustLikes(isLiked: false)
                self.likesRef.removeValue()
            }
        })

    }
}

























