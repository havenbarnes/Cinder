//
//  ViewController.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 12/31/17.
//  Copyright © 2017 Haven Barnes. All rights reserved.
//

import UIKit
import Contacts

class ViewController: UIViewController, ContactStoreDelegate {
    
    private var contactStore: ContactStore!
    
    private var cards: [ContactCardView] = []
    
    @IBOutlet weak var cardStackContainerView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var keepButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    func initUI() {
        keepButton.layer.cornerRadius = keepButton.frame.width / 2
        deleteButton.layer.cornerRadius = deleteButton.frame.width / 2
    }
    
    func contactAccessStatusDidUpdate(_ accessStatus: CNAuthorizationStatus) {
        if accessStatus == .denied || accessStatus == .restricted {
            let title = "Contact Access Denied"
            let message = "You can go to Settings to give Contact Swipes access to your contacts"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                
                let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            })
            alert.addAction(settingsAction)
            present(alert, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contactStore = ContactStore.shared
        contactStore.delegate = self
        
        contactStore.loadContacts {
            guard contactStore.contacts.count > 0 else {
                let title = "No Contacts to Clean"
                let message = "Your device has no more contacts to clean out!"
                let alert = UIAlertController(title: title,
                                              message: message,
                                              preferredStyle: .alert)
                present(alert, animated: true)
                return
            }
            
            for i in 0..<contactStore.contacts.count {
                let contact = contactStore.contacts[i]
                addCard(contact, index: i)
            }
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(markerDragged(_:)))
            cards.last?.isUserInteractionEnabled = true
            cards.last?.addGestureRecognizer(panGesture)
        }
    }
    
    func addCard(_ contact: CNContact, index: Int) {
        if let card = Bundle.main.loadNibNamed("ContactCardView", owner: nil, options: nil)?
            .first as! ContactCardView! {
            card.contact = contact
            card.contactIndex = index
            cardStackContainerView.addSubview(card)
            card.translatesAutoresizingMaskIntoConstraints = false
            
            let attributes: [NSLayoutAttribute] = [.left, .right, .centerY]
            for attribute in attributes {
                cardStackContainerView.addConstraint(NSLayoutConstraint(item: cardStackContainerView, attribute: attribute, relatedBy: .equal, toItem: card, attribute: attribute
                    , multiplier: 1, constant: 0))
            }
            
            cards.append(card)
        }
    }
    
    @objc func markerDragged(_ sender: UIPanGestureRecognizer) {
        view.bringSubview(toFront: sender.view!)
        let translation = sender.translation(in: self.view)
        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func keepButtonPressed(_ sender: Any) {
        
    }
    
}

