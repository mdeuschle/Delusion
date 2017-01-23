//
//  PopUpViewController.swift
//  Delusion
//
//  Created by Matt Deuschle on 1/21/17.
//  Copyright © 2017 Matt Deuschle. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController, UpdatePopUpTextDelegate {

    @IBOutlet var popUpText: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func updatePopUpText(popUpText: String) {
        print("POP UP TEXT: \(popUpText)")
    }

}
