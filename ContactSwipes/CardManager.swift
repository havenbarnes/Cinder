//
//  DragManager.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 1/13/18.
//  Copyright © 2018 Haven Barnes. All rights reserved.
//

import UIKit

protocol CardManagerDelegate {
    func dragStarted()
    func dragDidCompletePastBoundary(card: ContactCardView, isRight: Bool)
    func draggedCardShouldReturn(card: ContactCardView)
    func allCardsDragged()
}

class CardManager {
    
    var delegate: CardManagerDelegate?
    
    private var view: UIView
    private var cards: [ContactCardView]
    
    init(view: UIView, cards: [ContactCardView]) {
        self.view = view
        self.cards = cards
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(markerDragged(_:)))
        top?.isUserInteractionEnabled = true
        top?.addGestureRecognizer(panGesture)
    }
    
    var top: ContactCardView? {
        return cards.first
    }
    
    func addCard(_ card: ContactCardView) {
        cards.append(card)
    }

    func update() {
        // Delete Top Card
        _ = cards.removeFirst()
        
        // Get New Top Card
        guard let top = top else {
            delegate?.allCardsDragged()
            return
        }
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(markerDragged(_:)))
        top.isUserInteractionEnabled = true
        top.addGestureRecognizer(panGesture)
    }
    
    @objc func markerDragged(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            delegate?.dragStarted()
        }
        
        let cardView = sender.view! as! ContactCardView
        view.bringSubviewToFront(cardView)
        
        // Transition X
        let translation = sender.translation(in: self.view)
        cardView.center.x = cardView.center.x + translation.x
        
        // Rotate relative to translation
        let distanceSwiped = UIScreen.main.bounds.width / 2.0 - cardView.center.x
        let percentSwipedX = (distanceSwiped / UIScreen.main.bounds.width) * 0.5
        let rotationAngle = -(CGFloat.pi / 2) * percentSwipedX
        cardView.transform = CGAffineTransform(rotationAngle: rotationAngle + 0.05)
        
        // Opacity transition
        cardView.alpha = 1 - abs(percentSwipedX)
        
        // Reset translation for easier calculation
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        // Check For Drag Completion
        guard sender.state == .ended else { return }
        if cardView.frame.minX <= -60 {
            delegate?.dragDidCompletePastBoundary(card: top!, isRight: false)
        } else if cardView.frame.maxX >= view.frame.width + 60 {
            delegate?.dragDidCompletePastBoundary(card: top!, isRight: true)
        } else {
            delegate?.draggedCardShouldReturn(card: top!)
        }
    }
    
}
