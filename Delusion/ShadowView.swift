//
//  ShadowView.swift
//  Delusion
//
//  Created by Matt Deuschle on 1/9/17.
//  Copyright © 2017 Matt Deuschle. All rights reserved.
//

import UIKit

class ShadowView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSize(width: 1.5, height: 1.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 5
    }
}
