//
//  ContactCardView.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 12/31/17.
//  Copyright © 2017 Haven Barnes. All rights reserved.
//

import UIKit
import Contacts

class ContactCardView: UIView {
    
    let colors = [UIColor("F03434"),
                  UIColor("663399"),
                  UIColor("22A7F0"),
                  UIColor("26C281"),
                  UIColor("F9690E"),
                  UIColor("26C281"),
                  UIColor("36D7B7"),
                  UIColor("96281B")]
    
    var contactIndex: Int!
    var contact: CNContact!
    
    @IBOutlet weak var initialLabelBackgroundView: UIView!
    
    @IBOutlet weak var contactImageView: UIImageView!
    
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var phoneSectionLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var emailSectionLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func layoutSubviews() {
        //initialsLabel.text = contact.initials()
        layer.cornerRadius = 12
        initialLabelBackgroundView.layer.cornerRadius = initialLabelBackgroundView.frame.width / 2
    }
    
    func applyColor() {
        backgroundColor = colors[contactIndex]
        initialLabelBackgroundView.backgroundColor = colors[contactIndex].darker()
    }
    
}
