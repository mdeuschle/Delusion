//
//  RoundedButton.swift
//  Delusion
//
//  Created by Matt Deuschle on 1/8/17.
//  Copyright © 2017 Matt Deuschle. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        if let img = imageView {
            img.contentMode = .scaleAspectFit
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 3
    }

}
