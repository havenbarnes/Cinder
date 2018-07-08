//
//  ViewController.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 12/31/17.
//  Copyright © 2017 Haven Barnes. All rights reserved.
//

import UIKit
import Contacts

class MainViewController: UIViewController, ContactStoreDelegate, CardManagerDelegate {
    
    private var shouldLoadStack = true
    private let animationTime = 0.4
    private var cardManager: CardManager!
    private var contactStore: ContactStore!
    
    @IBOutlet weak var cardStackContainerView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var keepButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactStore = ContactStore.shared
        contactStore.delegate = self

        setNeedsStatusBarAppearanceUpdate()
        initUI()
    }
    
    func initUI() {
        keepButton.layer.cornerRadius = keepButton.frame.width / 2
        deleteButton.layer.cornerRadius = deleteButton.frame.width / 2
        redoButton.layer.cornerRadius = redoButton.frame.width / 2
        trashButton.layer.cornerRadius = trashButton.frame.width / 2
        redoButton.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if contactStore.trashEmpty {
            trashButton.backgroundColor = UIColor.gray.withAlphaComponent(0.15)
        }
        
        guard shouldLoadStack else { return }
        shouldLoadStack = false
        
        contactStore.loadCardStackData()
        progressIndicator.stopAnimating()
        
        guard contactStore.cardStack.count > 0 else {
            let title = "No Contacts to Clean"
            let message = "Your device has no contacts to clean out!"
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        addCardsToStack(for: contactStore.cardStack)
        progressIndicator.stopAnimating()
        redoButton.isHidden = false
    }
    
    func addCardsToStack(for contacts: [CNContact]) {
        cardStackContainerView.isUserInteractionEnabled = true

        var cards: [ContactCardView] = []
        for i in 0..<contacts.count {
            let contact = contacts[i]
            if let card = generateCard(contact, index: i) {
                cards.insert(card, at: 0)
            }
        }
        
        cardManager = CardManager(view: view, cards: cards)
        cardManager.delegate = self
    }
    
    func generateCard(_ contact: CNContact, index: Int, initialLoad: Bool = true) -> ContactCardView? {
        if let card = Bundle.main.loadNibNamed("ContactCardView", owner: nil, options: nil)?
            .first as! ContactCardView? {
            card.contact = contact
            card.contactIndex = index
            cardStackContainerView.insertSubview(card, at: initialLoad ? contactStore.cardStack.count - 1 : 0)
            card.translatesAutoresizingMaskIntoConstraints = false
            
            let attributes: [NSLayoutAttribute] = [.left, .right, .centerY]
            for attribute in attributes {
                cardStackContainerView.addConstraint(NSLayoutConstraint(item: cardStackContainerView,
                    attribute: attribute, relatedBy: .equal, toItem: card, attribute: attribute,
                    multiplier: 1, constant: 0))
            }
            
            if (initialLoad) {
                card.center.y = view.frame.height + card.frame.height
                UIView.animate(withDuration: self.animationTime, delay: 0.1 * Double(index),
                               options: .curveEaseOut, animations: {
                                self.view.layoutIfNeeded()
                }, completion: nil)
            }
            
            return card
        } else {
            print("ERROR: Couldn't find ContactCardView nib")
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
        trashButton.isEnabled = true
    }
    
    func disableButtons() {
        keepButton.isEnabled = false
        deleteButton.isEnabled = false
        trashButton.isEnabled = false
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
        
        contactStore.keep(card.contact)
        cardManager.update()
    }
    
    func trash(_ card: ContactCardView) {
        self.disableButtons()
        UIView.animate(withDuration: self.animationTime, animations: {
            self.trashButton.backgroundColor = UIColor.red
            card.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 5)
            card.center.x = -card.frame.width / 2
            card.alpha = 0
        }) { (complete) in
            card.removeFromSuperview()
            self.enableButtons()
        }
        
        contactStore.trash(card.contact)
        cardManager.update()
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
        isRight ? keep(card) : trash(card)
    }
    
    func allCardsDragged() {
        cardStackContainerView.isUserInteractionEnabled = false
    }
    
    // MARK: - Button Actions

    @IBAction func deleteButtonPressed(_ sender: Any) {
        guard let topCard = cardManager.top else {
            return
        }
        trash(topCard)
    }
    
    @IBAction func keepButtonPressed(_ sender: Any) {
        guard let topCard = cardManager.top else {
            return
        }
        keep(topCard)
    }
    
    @IBAction func redoButtonPressed(_ sender: Any) {
        shouldLoadStack = true
        viewDidAppear(false)
    }
}

