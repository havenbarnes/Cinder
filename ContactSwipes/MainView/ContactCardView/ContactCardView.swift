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
        setupContact()
        applyColor()
        
        layer.cornerRadius = 12
        contactImageView.layer.cornerRadius = contactImageView.frame.width / 2
        contactImageView.clipsToBounds = true
        initialLabelBackgroundView.layer.cornerRadius = initialLabelBackgroundView.frame.width / 2
    }
    
    private func setupContact() {
        
        initialsLabel.text = contact.initials()
        
        nameLabel.text = contact.givenName + " " + contact.familyName
        if nameLabel.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !contact.organizationName.isEmpty {
            nameLabel.text = contact.organizationName
        }
        
        if contact.imageDataAvailable {
            let image = UIImage(data: contact.thumbnailImageData!)
            contactImageView.image = image
        }
        
        if contact.phoneNumbers.count == 0 {
            phoneLabel.text = "No Phone"
            phoneLabel.alpha = 0.4
            phoneSectionLabel.alpha = 0.4
        } else {
            phoneLabel.text = contact.phoneNumbers.first!.value.stringValue
        }
        
        if contact.emailAddresses.count == 0 {
            emailLabel.text = "No Email"
            emailLabel.alpha = 0.4
            emailSectionLabel.alpha = 0.4
        } else {
            emailLabel.text = contact.emailAddresses.first!.value as String
        }
        
    }
    
    private func applyColor() {
        backgroundColor = ContactStore.colors[contactIndex % ContactStore.colors.count]
        initialLabelBackgroundView.backgroundColor = ContactStore.colors[contactIndex % ContactStore.colors.count].darker()
    }
    
}
