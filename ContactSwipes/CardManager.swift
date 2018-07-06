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
        return cards.last
    }

    func update() {
        // Delete Top Card
        _ = cards.popLast()
        
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
        view.bringSubview(toFront: sender.view!)
        
        // Transition X
        let translation = sender.translation(in: self.view)
        sender.view!.center.x = sender.view!.center.x + translation.x * 1.2
        
        // Rotate relative to translation
        let distanceSwiped = UIScreen.main.bounds.width / 2.0 - sender.view!.center.x
        let percentSwipedX = (distanceSwiped / UIScreen.main.bounds.width) * 0.5
        let rotationAngle = -(CGFloat.pi / 2) * percentSwipedX
        sender.view!.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
        // Opacity transition
        sender.view!.alpha = 1 - abs(percentSwipedX * 1.3)
        
        // Reset translation for easier calculation
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        // Check For Drag Completion
        guard sender.state == .ended else { return }
        if sender.view!.frame.minX <= -100 {
            delegate?.dragDidCompletePastBoundary(card: top!, isRight: false)
        } else if sender.view!.frame.maxX >= view.frame.width + 100 {
            delegate?.dragDidCompletePastBoundary(card: top!, isRight: true)
        } else {
            delegate?.draggedCardShouldReturn(card: top!)
        }
    }
    
}
