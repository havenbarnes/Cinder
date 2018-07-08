//
//  TrashViewController.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 7/7/18.
//  Copyright © 2018 Haven Barnes. All rights reserved.
//

import UIKit
import Contacts

typealias ContactData = (CNContact, Int)

class TrashViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ContactCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private var contacts: [CNContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contacts = ContactStore.shared.getTrash()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = contacts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        cell.contactData = (contact, indexPath.row)
        return cell
    }
    
    func didRestore(contact: ContactData) {
        let indexPath = IndexPath(row: contact.1, section: 0)
        tableView.deleteRows(at: [indexPath], with: .top)
        ContactStore.shared.removeFromTrash(contact.0)
    }
    
    func didDelete(contact: ContactData) {
        let indexPath = IndexPath(row: contact.1, section: 0)
        tableView.deleteRows(at: [indexPath], with: .top)
        ContactStore.shared.delete(contact.0)
    }
    
    @IBAction func deleteAllButtonPressed(_ sender: Any) {
        let title = "Delete Contact?"
        let message = "Are you sure you want to delete all trashed contacts? This cannot be undone."
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
            action in
            ContactStore.shared.emptyTrash()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

protocol ContactCellDelegate {
    func didRestore(contact: ContactData)
    func didDelete(contact: ContactData)
}

class ContactCell: UITableViewCell {
    
    var delegate: ContactCellDelegate?
    
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
        
        if contact.imageDataAvailable {
            let image = UIImage(data: contact.thumbnailImageData!)
            contactImageView.image = image
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
}
