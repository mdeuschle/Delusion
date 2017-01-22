//
//  PopUpViewController.swift
//  Delusion
//
//  Created by Matt Deuschle on 1/21/17.
//  Copyright © 2017 Matt Deuschle. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: class {
    func update(popUpText: String)
}

class PopUpViewController: UIViewController {

    @IBOutlet var popUpText: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func updatePopUpText(popUpString: String) {
        popUpText.text = popUpString
    }

}
