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
            if let data = contact.thumbnailImageData {
                let image = UIImage(data: data)
                contactImageView.image = image
            }
        }
        
        if let phoneNumber = contact.phoneNumbers.first {
            phoneLabel.text = phoneNumber.value.stringValue
        } else {
            phoneLabel.text = "No Phone"
            phoneLabel.alpha = 0.4
            phoneSectionLabel.alpha = 0.4
        }

        if let emailAddress = contact.emailAddresses.first {
            emailLabel.text = emailAddress.value as String
        } else {
            emailLabel.text = "No Email"
            emailLabel.alpha = 0.4
            emailSectionLabel.alpha = 0.4
        }
    }
    
    private func applyColor() {
        backgroundColor = ContactStore.colors[contactIndex % ContactStore.colors.count]
        initialLabelBackgroundView.backgroundColor = ContactStore.colors[contactIndex % ContactStore.colors.count].darker()
    }
    
}
