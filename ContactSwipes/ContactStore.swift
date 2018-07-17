//
//  ContactStore.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 1/7/18.
//  Copyright © 2018 Haven Barnes. All rights reserved.
//

import UIKit
import Contacts

protocol ContactStoreDelegate {
    func contactAccessStatusDidUpdate(_ accessStatus: CNAuthorizationStatus)
}

class ContactStore {
    
    static let shared = ContactStore()
    
    static let colors = [UIColor("F03434"),
                  UIColor("663399"),
                  UIColor("22A7F0"),
                  UIColor("26C281"),
                  UIColor("F9690E"),
                  UIColor("36D7B7"),
                  UIColor("96281B")]
    
    
    var delegate: ContactStoreDelegate?
    
    var cardStack: [CNContact] = []
    // TODO: Persist trashed
    private var trashed: [String : CNContact] = [:]
    private var contacts: [String : CNContact] = [:]
    private var cnContactStore = CNContactStore()
    private var accessStatus: CNAuthorizationStatus? = nil
    
    private static let approvedContactsKey = "approvedContactsKey"
    private var approved: [String : CNContact] {
        get {
            guard let approved = UserDefaults.standard.dictionary(forKey: ContactStore.approvedContactsKey)
                as? [String : CNContact] else {
                    return [:]
            }
            return approved
        }
        set (newValue){
            UserDefaults.standard.set(newValue, forKey: ContactStore.approvedContactsKey)
        }
    }
    
    func checkForContactAccess() {
        let newAccessStatus = CNContactStore.authorizationStatus(for: .contacts)
        delegate?.contactAccessStatusDidUpdate(newAccessStatus)
    }
    
    func loadCardStackData() {
        loadContacts()
        var contactsArray = Array(contacts.values)
        contactsArray.shuffle()
        
        for _ in 1...5 {
            if let contact = contactsArray.first {
                cardStack.append(contact)
                _ = contacts.popFirst()
            }
        }
    }
    
    private func loadContacts() {
        contacts.removeAll()

        let request = CNContactFetchRequest(keysToFetch:
            [CNContactGivenNameKey as CNKeyDescriptor,
             CNContactFamilyNameKey as CNKeyDescriptor,
             CNContactImageDataAvailableKey as CNKeyDescriptor,
             CNContactThumbnailImageDataKey as CNKeyDescriptor,
             CNContactPhoneNumbersKey as CNKeyDescriptor,
             CNContactEmailAddressesKey as CNKeyDescriptor])
        do {
            try cnContactStore.enumerateContacts(with: request) { (contact, successful) in
                // Only add those not already trashed
                guard self.trashed[contact.identifier] == nil else { return }
                self.contacts[contact.identifier] = contact
            }
        } catch {
            checkForContactAccess()
        }
    }
    
    func keep(_ contact: CNContact, completion: (CNContact?) -> ()) {
        approved[contact.identifier] = contact
        contacts.removeValue(forKey: contact.identifier)
        let newContact = updateStack()
        completion(newContact)
        
    }
    
    func trash(_ contact: CNContact, completion: (CNContact?) -> ()) {
        trashed[contact.identifier] = contact
        contacts.removeValue(forKey: contact.identifier)
        let newContact = updateStack()
        completion(newContact)
    }
    
    var trashEmpty: Bool {
        return trashed.count == 0
    }
    
    func getTrash() -> [CNContact] {
        return Array(trashed.values)
    }
    
    func removeFromTrash(_ contact: CNContact) {
        trashed.removeValue(forKey: contact.identifier)
    }
    
    func delete(_ contact: CNContact) {
        trashed.removeValue(forKey: contact.identifier)
        print("Deleting Contact...")
        let mutableContact = contact.mutableCopy() as! CNMutableContact
        let request = CNSaveRequest()
        request.delete(mutableContact)
        try? cnContactStore.execute(request)
    }
    
    func emptyTrash() {
        for contact in trashed.values {
            delete(contact)
        }
        trashed.removeAll()
    }
    
    func updateStack() -> CNContact? {
        cardStack.removeFirst()
        if let newContact = contacts.popFirst()?.value {
            cardStack.append(newContact)
            return newContact
        }
        return nil
    }
    
    func reset() {
        approved.removeAll()
        
    }
}
