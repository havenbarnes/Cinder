//
//  StatsViewController.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 7/23/18.
//  Copyright © 2018 Haven Barnes. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {

    @IBOutlet weak var progressFractionLabel: UILabel!
    @IBOutlet weak var deletedLabel: UILabel!
    @IBOutlet weak var deletedLabelPlurality: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func resetProgressPressed(_ sender: Any) {
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
