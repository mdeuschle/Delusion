//
//  PostCell.swift
//  Delusion
//
//  Created by Matt Deuschle on 1/10/17.
//  Copyright © 2017 Matt Deuschle. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLabel: UILabel!

    var post: Post!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configCell(post: Post) {
        self.post = post
        self.caption.text = post.caption
        self.likesLabel.text = String(post.likes)
    }

}
