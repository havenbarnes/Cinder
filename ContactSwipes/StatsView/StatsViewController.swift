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

        let stats = ContactStore.shared.getStats()
        progressFractionLabel.text = "\(stats["seenCount"] ?? 0)/\(stats["totalCount"] ?? 0)"
        deletedLabel.text = "\(stats["deletedCount"] ?? 0)"
        deletedLabelPlurality.text = stats["deletedCount"] == 1 ? "Contact" : "Contacts"
    }

    @IBAction func resetProgressPressed(_ sender: Any) {
        let title = "Reset All Progress?"
        let message = "Are you sure you want to reset all stats and start over?"
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: {
            action in
            ContactStore.shared.reset()
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
