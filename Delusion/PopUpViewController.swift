//
//  PopUpViewController.swift
//  Delusion
//
//  Created by Matt Deuschle on 1/21/17.
//  Copyright © 2017 Matt Deuschle. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    @IBOutlet var loginErrorLabel: UILabel!
    @IBOutlet var errorPopUpButton: UIButton!

    var errorString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let errorStr = errorString {
            loginErrorLabel.text = errorStr
        }
    }

}
