//
//  ContactCell.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 8/9/18.
//  Copyright © 2018 Haven Barnes. All rights reserved.
//

import UIKit
import Contacts

protocol ContactCellDelegate: class {
    func didRestore(contact: CNContact)
    func didDelete(contact: CNContact)
}

class ContactCell: UITableViewCell {
    
    weak var delegate: ContactCellDelegate?
    
    @IBOutlet weak var initialsLabelBackground: UIView!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    private var contact: CNContact!
    private var contactIndex: Int!
    var contactData: ContactData! {
        didSet {
            contact = contactData.0
            contactIndex = contactData.1
            updateUI()
        }
    }
    
    private func updateUI() {
        initialsLabelBackground.layer.cornerRadius = contactImageView.frame.width / 2
        contactImageView.layer.cornerRadius = contactImageView.frame.width / 2
        contactImageView.clipsToBounds = true
        setupContact()
    }
    
    private func setupContact() {
        initialsLabelBackground.backgroundColor = ContactStore.colors[contactIndex % ContactStore.colors.count]
        initialsLabel.text = contact.initials()
        
        nameLabel.text = contact.givenName + " " + contact.familyName
        if nameLabel.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !contact.organizationName.isEmpty {
            nameLabel.text = contact.organizationName
        }
        
        if contact.imageDataAvailable && contact.thumbnailImageData != nil {
            let image = UIImage(data: contact.thumbnailImageData!)
            contactImageView.image = image
        } else {
            contactImageView.image = nil
        }
        
        if contact.phoneNumbers.count == 0 {
            phoneLabel.text = "No Phone"
            phoneLabel.alpha = 0.4
        } else {
            phoneLabel.text = contact.phoneNumbers.first!.value.stringValue
        }
        
        if contact.emailAddresses.count == 0 {
            emailLabel.text = "No Email"
            emailLabel.alpha = 0.4
        } else {
            emailLabel.text = contact.emailAddresses.first!.value as String
        }
    }
    
    @IBAction func restoreButtonPressed(_ sender: Any) {
        SoundManager.shared.play(sound: .slideLeft)
        delegate?.didRestore(contact: contact)
    }
    
    
    @IBAction func trashButtonPressed(_ sender: Any) {
        SoundManager.shared.play(sound: .shortTrash)
        delegate?.didDelete(contact: contact)
    }
}
