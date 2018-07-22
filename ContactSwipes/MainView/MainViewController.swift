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
    
    private let animationTime = 0.3
    private var animating = false
    private var shouldLoadStack = true
    private var cardManager: CardManager!
    private var contactStore: ContactStore!
    
    @IBOutlet weak var cardStackContainerView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var keepButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var trashButtonLeading: NSLayoutConstraint!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var allDoneLabel: UILabel!
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
        let path = UIBezierPath(roundedRect: trashButton.bounds,
                                byRoundingCorners:[.topRight, .bottomRight],
                                cornerRadii: CGSize(width: trashButton.frame.height / 2,
                                                    height:  trashButton.frame.height / 2))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        trashButton.layer.mask = maskLayer
        trashButtonLeading.constant = -trashButton.frame.width // Start off screen
        redoButton.alpha = 0
        allDoneLabel.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if contactStore.trashEmpty {
            dismissTrashButtonIfNeeded()
        } else {
            presentTrashButtonIfNeeded()
        }
        
        guard shouldLoadStack else { return }
        shouldLoadStack = false
        
        contactStore.loadCardStackData()
        progressIndicator.stopAnimating()
        
        guard contactStore.cardStack.count > 0 else {
            let title = "No Contacts to Clean"
            let message = "Your device has no more contacts to clean out!"
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
            allCardsDragged()
            return
        }
        
        SoundManager.shared.play(sound: .shuffle)
        
        loadCardStack(for: contactStore.cardStack)
        progressIndicator.stopAnimating()
    }
    
    func addCardToStack(contactData: ContactData) {
        if let newCard = self.generateCard(contactData.0, index: contactData.1, initialLoad: false) {
            self.cardManager.addCard(newCard)
        }
    }
    
    func loadCardStack(for contacts: [CNContact]) {
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
                UIView.animate(withDuration: self.animationTime, delay: 0.1 * Double(index + 1),
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
    
    func dismissTrashButtonIfNeeded() {
        guard trashButtonLeading.constant == 0 else { return }
        trashButtonLeading.constant = -trashButton.frame.width
        UIView.animate(withDuration: animationTime / 2, delay: animationTime / 2, options: .curveEaseIn, animations: {
            self.view.layoutSubviews()
        }, completion: nil)
    }
    
    func presentTrashButtonIfNeeded() {
        guard trashButtonLeading.constant < 0 else { return }
        trashButtonLeading.constant = 0
        UIView.animate(withDuration: animationTime / 2, delay: animationTime, options: .curveEaseOut, animations: {
            self.view.layoutSubviews()
        }, completion: nil)
    }

    func keep(_ card: ContactCardView) {
        SoundManager.shared.play(sound: .slideRight)
        animating = true
        UIView.animate(withDuration: animationTime, animations: {
            card.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 5)
            card.center.x = self.view.frame.width + card.frame.width / 2
            card.alpha = 0
        }) { (complete) in
            card.removeFromSuperview()
            self.animating = false
            
            self.contactStore.keep(card.contact) { newContact in
                guard let newContact = newContact else { return }
                self.addCardToStack(contactData: (newContact, card.contactIndex + 1))
            }
            self.cardManager.update()
        }
    }
    
    func trash(_ card: ContactCardView) {
        SoundManager.shared.play(sound: .slideLeft)
        presentTrashButtonIfNeeded()
        animating = true
        
        UIView.animate(withDuration: self.animationTime, animations: {
            card.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 5)
            card.center.x = -card.frame.width / 2
            card.alpha = 0
        }) { (complete) in
            card.removeFromSuperview()
            self.animating = false
            self.contactStore.trash(card.contact) { newContact in
                guard let newContact = newContact else { return }
                self.addCardToStack(contactData: (newContact, card.contactIndex + 1))
            }
           self.cardManager.update()
        }
    }
    
    
    
    // MARK: - CardManagerDelegate
    
    func dragStarted() {
        animating = true
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
            self.animating = false
        }
    }
    
    func dragDidCompletePastBoundary(card: ContactCardView, isRight: Bool) {
        isRight ? keep(card) : trash(card)
    }
    
    func allCardsDragged() {
        cardStackContainerView.isUserInteractionEnabled = false
        UIView.animate(withDuration: animationTime) {
            self.redoButton.alpha = 1
            self.allDoneLabel.alpha = 1
        }
    }
    
    // MARK: - Button Actions
    @IBAction func trashButtonPressed(_ sender: Any) {
        guard !animating else { return }
        present("TrashViewController")
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        guard !animating else { return }
        guard let topCard = cardManager.top else {
            return
        }
        trash(topCard)
    }
    
    @IBAction func keepButtonPressed(_ sender: Any) {
        guard !animating else { return }
        guard let topCard = cardManager.top else {
            return
        }
        keep(topCard)
    }
    
    @IBAction func redoButtonPressed(_ sender: Any) {
        guard !animating else { return }
        shouldLoadStack = true
        contactStore.reset()
        viewDidAppear(false)
    }
}

