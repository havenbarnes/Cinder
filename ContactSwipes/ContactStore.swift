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
    func contactStoreDidReset()
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
    private var contacts: [String : CNContact] = [:]
    private var cnContactStore = CNContactStore()
    private var accessStatus: CNAuthorizationStatus? = nil

    private static let deletedCountKey = "deletedCountKey"
    private var deletedCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: ContactStore.deletedCountKey)
        }
        set (newValue){
            UserDefaults.standard.set(newValue, forKey: ContactStore.deletedCountKey)
        }
    }
    private static let totalCountKey = "totalCountKey"
    private var totalCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: ContactStore.totalCountKey)
        }
        set (newValue){
            UserDefaults.standard.set(newValue, forKey: ContactStore.totalCountKey)
        }
    }
    
    private static let seenCountKey = "seenCountKey"
    private var seenCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: ContactStore.seenCountKey)
        }
        set (newValue){
            UserDefaults.standard.set(newValue, forKey: ContactStore.seenCountKey)
        }
    }
    
    private static let trashedContactsKey = "trashedContactsKey"
    private var trashed: [String] {
        get {
            guard let trashed = UserDefaults.standard.stringArray(forKey: ContactStore.trashedContactsKey)
                else {
                    return []
            }
            return trashed
        }
        set (newValue){
            UserDefaults.standard.set(newValue, forKey: ContactStore.trashedContactsKey)
        }
    }
    
    private static let approvedContactsKey = "approvedContactsKey"
    private var approved: [String] {
        get {
            guard let approved = UserDefaults.standard.stringArray(forKey: ContactStore.approvedContactsKey)
                else {
                    return []
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
    
    func getStats() -> [String: Int] {
        return [
            "seenCount": seenCount,
            "totalCount": totalCount,
            "deletedCount": deletedCount
        ]
    }
    
    func loadCardStackData() {
        loadContacts()
        var contactsArray = Array(contacts.values)
        contactsArray.shuffle()
        
        for _ in 1...5 {
            if let contact = contactsArray.first {
                contactsArray.removeFirst()
                contacts.removeValue(forKey: contact.identifier)
                cardStack.append(contact)
            }
        }
    }
    
    private func fetchContact(_ identifier: String, completion: @escaping (CNContact?) -> ()) {
        let keysToFetch: [CNKeyDescriptor] =
            [CNContactGivenNameKey as CNKeyDescriptor,
             CNContactFamilyNameKey as CNKeyDescriptor,
             CNContactImageDataAvailableKey as CNKeyDescriptor,
             CNContactThumbnailImageDataKey as CNKeyDescriptor,
             CNContactPhoneNumbersKey as CNKeyDescriptor,
             CNContactEmailAddressesKey as CNKeyDescriptor]
        do {
            let contact = try cnContactStore.unifiedContact(withIdentifier: identifier, keysToFetch: keysToFetch)
            completion(contact)
        } catch {
            completion(nil)
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
                guard !self.approved.contains(contact.identifier) else { return }
                guard !self.trashed.contains(contact.identifier) else { return }
                self.contacts[contact.identifier] = contact
            }
        } catch {
            checkForContactAccess()
        }
        totalCount = contacts.count + approved.count + trashed.count
    }
    
    func keep(_ contact: CNContact, completion: (CNContact?) -> ()) {
        seenCount = seenCount + 1
        approved.append(contact.identifier)
        contacts.removeValue(forKey: contact.identifier)
        let newContact = updateStack()
        completion(newContact)
        
    }
    
    func trash(_ contact: CNContact, completion: (CNContact?) -> ()) {
        seenCount = seenCount + 1
        trashed.append(contact.identifier)
        contacts.removeValue(forKey: contact.identifier)
        let newContact = updateStack()
        completion(newContact)
    }
    
    var trashEmpty: Bool {
        return trashed.count == 0
    }
    
    func getTrash() -> [CNContact] {
        var trash: [CNContact] = []
        trashed.forEach({ identifier in
            fetchContact(identifier, completion: { contact in
                if let contact = contact {
                    trash.append(contact)
                }
            })
        })
        return trash
    }
    
    func removeFromTrash(_ contact: CNContact) {
        trashed.remove(at: trashed.index(of: contact.identifier)!)
    }
    
    func delete(_ contact: CNContact) {
        trashed.remove(at: trashed.index(of: contact.identifier)!)
        let mutableContact = contact.mutableCopy() as! CNMutableContact
        let request = CNSaveRequest()
        request.delete(mutableContact)
        try? cnContactStore.execute(request)
        deletedCount = deletedCount + 1
    }
    
    func emptyTrash() {
        for identifier in trashed {
            fetchContact(identifier, completion: { contact in
                if let contact = contact {
                    self.delete(contact)
                }
            })
        }
        trashed.removeAll()
        seenCount = approved.count
    }
    
    func updateStack() -> CNContact? {
        cardStack.removeFirst()
        if let newContact = contacts.popFirst()?.value {
            cardStack.append(newContact)
            return newContact
        }
        return nil
    }
    
    func refillDeck() {
        approved.removeAll()
        seenCount = trashed.count
    }
    
    func reset() {
        seenCount = 0
        totalCount = 0
        deletedCount = 0
        approved = []
        trashed = []
        cardStack = []
        contacts = [:]
        delegate?.contactStoreDidReset()
    }
}
