//
//  ViewController.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 12/31/17.
//  Copyright © 2017 Haven Barnes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cardStackContainerView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var keepButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        if let card = Bundle.main.loadNibNamed("ContactCardView", owner: nil, options: nil)?
            .first as! ContactCardView! {
            cardStackContainerView.addSubview(card)
            card.translatesAutoresizingMaskIntoConstraints = false
            
            let attributes: [NSLayoutAttribute] = [.left, .right, .bottom]
            for attribute in attributes {
                cardStackContainerView.addConstraint(NSLayoutConstraint(item: cardStackContainerView, attribute: attribute, relatedBy: .equal, toItem: card, attribute: attribute
                    , multiplier: 1, constant: 0))
            }
            
        }
    
    }
    
    func initUI() {
        keepButton.layer.cornerRadius = keepButton.frame.width / 2
        deleteButton.layer.cornerRadius = deleteButton.frame.width / 2
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func keepButtonPressed(_ sender: Any) {
        
    }
    
}

