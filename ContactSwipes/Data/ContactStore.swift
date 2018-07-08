//
//  ContactStore.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 1/7/18.
//  Copyright © 2018 Haven Barnes. All rights reserved.
//

import Foundation
import Contacts

protocol ContactStoreDelegate {
    func contactAccessStatusDidUpdate(_ accessStatus: CNAuthorizationStatus)
}

class ContactStore {
    
    static let shared = ContactStore()
    
    var delegate: ContactStoreDelegate?
    
    var cardStack: [CNContact] = []
    private var contacts: [String : CNContact] = [:]
    // TODO: Persist trashed
    private var trashed: [String : CNContact] = [:]
    
    private var cnContactStore = CNContactStore()
    private var accessStatus: CNAuthorizationStatus? = nil
    
    func checkForContactAccess() {
        let newAccessStatus = CNContactStore.authorizationStatus(for: .contacts)
        delegate?.contactAccessStatusDidUpdate(newAccessStatus)
    }
    
    func loadCardStackData() {
        loadContacts()
        
        for _ in 1...5 {
            if let contact = contacts.values.first {
                cardStack.append(contact)
                _ = contacts.popFirst()
            }
        }
        
        cardStack.shuffle()
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
        try? cnContactStore.enumerateContacts(with: request) { (contact, successful) in
            // Only add those not already trashed
            guard self.trashed[contact.identifier] == nil else { return }
            self.contacts[contact.identifier] = contact
        }
    }
    
    func keep(_ contact: CNContact) {
        contacts.removeValue(forKey: contact.identifier)
        updateStack()
    }
    
    var trashEmpty: Bool {
        return trashed.count == 0
    }
    
    func trash(_ contact: CNContact) {
        trashed[contact.identifier] = contact
        contacts.removeValue(forKey: contact.identifier)
        updateStack()
    }
    
    func updateStack() {
        print("Card Stack Before: \(cardStack.map { $0.identifier })")
        cardStack.removeFirst()
        if let newContact = contacts.popFirst()?.value {
            cardStack.append(newContact)
        }
        print("Card Stack After: \(cardStack.map { $0.identifier })")
    }
    
    func delete(_ contact: CNContact) {
        print("Deleting Contact...")
        let mutableContact = contact.mutableCopy() as! CNMutableContact
        let request = CNSaveRequest()
        request.delete(mutableContact)
        try? cnContactStore.execute(request)
    }
}
