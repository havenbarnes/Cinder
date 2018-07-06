//
//  ViewController.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 12/31/17.
//  Copyright © 2017 Haven Barnes. All rights reserved.
//

import UIKit
import Contacts

class ViewController: UIViewController, ContactStoreDelegate, CardManagerDelegate {
    
    private let animationTime = 0.4
    private var cardManager: CardManager!
    private var contactStore: ContactStore!
    
    @IBOutlet weak var cardStackContainerView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var keepButton: UIButton!
    
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        initUI()
    }
    
    func initUI() {
        keepButton.layer.cornerRadius = keepButton.frame.width / 2
        deleteButton.layer.cornerRadius = deleteButton.frame.width / 2
        redoButton.layer.cornerRadius = redoButton.frame.width / 2
        redoButton.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contactStore = ContactStore.shared
        contactStore.delegate = self
        
        contactStore.loadContacts {
            guard contactStore.contacts.count > 0 else {
                let title = "No Contacts to Clean"
                let message = "Your device has no contacts to clean out!"
                let alert = UIAlertController(title: title,
                                              message: message,
                                              preferredStyle: .alert)
                present(alert, animated: true)
                return
            }
            
            setupCards(for: contactStore.contacts)
            progressIndicator.stopAnimating()
            redoButton.isHidden = false
        }
    }
    
    func setupCards(for contacts: [CNContact]) {
        cardStackContainerView.isUserInteractionEnabled = true

        var cards: [ContactCardView] = []
        for i in 0..<contacts.count {
            let contact = contacts[i]
            if let card = generateCard(contact, index: i) {
                cards.append(card)
            }
        }
        
        cardManager = CardManager(view: view, cards: cards)
        cardManager.delegate = self
    }
    
    func generateCard(_ contact: CNContact, index: Int) -> ContactCardView? {
        if let card = Bundle.main.loadNibNamed("ContactCardView", owner: nil, options: nil)?
            .first as! ContactCardView? {
            card.contact = contact
            card.contactIndex = index
            cardStackContainerView.addSubview(card)
            card.translatesAutoresizingMaskIntoConstraints = false
            
            let attributes: [NSLayoutAttribute] = [.left, .right, .centerY]
            for attribute in attributes {
                cardStackContainerView.addConstraint(NSLayoutConstraint(item: cardStackContainerView,
                    attribute: attribute, relatedBy: .equal, toItem: card, attribute: attribute,
                    multiplier: 1, constant: 0))
            }
            
            card.center.y = view.frame.height + card.frame.height
            UIView.animate(withDuration: self.animationTime, delay: 0.1 * Double(index),
                options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            return card
        } else {
            return nil
        }
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
    
    func enableButtons() {
        keepButton.isEnabled = true
        deleteButton.isEnabled = true
    }
    
    func disableButtons() {
        keepButton.isEnabled = false
        deleteButton.isEnabled = false
    }
    
    func keep(_ card: ContactCardView) {
        disableButtons()
        UIView.animate(withDuration: animationTime, animations: {
            card.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 5)
            card.center.x = self.view.frame.width + card.frame.width / 2
            card.alpha = 0
        }) { (complete) in
            card.removeFromSuperview()
            self.enableButtons()
        }
        
        cardManager.update()
    }
    
    func delete(_ card: ContactCardView) {
        self.disableButtons()
        UIView.animate(withDuration: self.animationTime, animations: {
            card.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 5)
            card.center.x = -card.frame.width / 2
            card.alpha = 0
        }) { (complete) in
            card.removeFromSuperview()
            self.enableButtons()
        }
        self.contactStore.delete(card.contact)
        self.cardManager.update()
    }
    
    func showDeleteConfirmation(for card: ContactCardView) {
        let title = "Delete Contact?"
        let message = "Are you sure you want to delete \(card.contact.givenName)'s contact?"
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
            action in
            self.showDeleteConfirmation(for: card)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
            self.draggedCardShouldReturn(card: card)
        }))
        present(alert, animated: true)
    }
    
    // MARK: - CardManagerDelegate
    
    func dragStarted() {
        disableButtons()
    }
    
    func draggedCardShouldReturn(card: ContactCardView) {
        UIView.animate(withDuration: animationTime, animations: {
            card.transform = CGAffineTransform(rotationAngle: 0)
            var frameUpdate = card.frame
            frameUpdate.origin.x = 0
            frameUpdate.origin.y = self.cardStackContainerView.frame.height / 2 - frameUpdate.height / 2
            card.frame = frameUpdate
            card.alpha = 1
        }) { (complete) in
            self.enableButtons()
        }
    }
    
    func dragDidCompletePastBoundary(card: ContactCardView, isRight: Bool) {
        isRight ? keep(card) : showDeleteConfirmation(for: card)
    }
    
    func allCardsDragged() {
        cardStackContainerView.isUserInteractionEnabled = false
    }
    
    // MARK: - Button Actions

    @IBAction func deleteButtonPressed(_ sender: Any) {
        guard let topCard = cardManager.top else {
            return
        }
        showDeleteConfirmation(for: topCard)
    }
    
    @IBAction func keepButtonPressed(_ sender: Any) {
        guard let topCard = cardManager.top else {
            return
        }
        keep(topCard)
    }
    
    @IBAction func redoButtonPressed(_ sender: Any) {
        viewDidAppear(false)
    }
}

