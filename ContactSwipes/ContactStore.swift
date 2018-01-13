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
    
    var contacts: [CNContact] = []
    
    var delegate: ContactStoreDelegate?
    
    private var cnContactStore = CNContactStore()
    private var accessStatus: CNAuthorizationStatus? = nil
    
    func checkForContactAccess() {
        let newAccessStatus = CNContactStore.authorizationStatus(for: .contacts)
        delegate?.contactAccessStatusDidUpdate(newAccessStatus)
    }
    
    func loadContacts(_ completion: () -> ()) {
        contacts.removeAll()
        
        let request = CNContactFetchRequest(keysToFetch:
            [CNContactGivenNameKey as CNKeyDescriptor,
             CNContactFamilyNameKey as CNKeyDescriptor,
             CNContactImageDataAvailableKey as CNKeyDescriptor,
             CNContactThumbnailImageDataKey as CNKeyDescriptor,
             CNContactPhoneNumbersKey as CNKeyDescriptor,
             CNContactEmailAddressesKey as CNKeyDescriptor])
        try? cnContactStore.enumerateContacts(with: request) { (contact, successful) in
            self.contacts.append(contact)
        }
        
        contacts.shuffle()
        completion()
    }
    
    func delete(_ contact: CNContact) {
        print("Deleting Contact...")
        let mutableContact = contact.mutableCopy() as! CNMutableContact
        let request = CNSaveRequest()
        request.delete(mutableContact)
        try? cnContactStore.execute(request)
    }
}
