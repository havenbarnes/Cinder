//
//  TrashViewController.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 7/7/18.
//  Copyright © 2018 Haven Barnes. All rights reserved.
//

import UIKit

class TrashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func deleteAllButtonPressed(_ sender: Any) {
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

}
