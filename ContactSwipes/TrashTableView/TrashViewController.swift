//
//  TrashViewController.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 7/7/18.
//  Copyright © 2018 Haven Barnes. All rights reserved.
//

import UIKit
import Contacts
import GoogleMobileAds

typealias ContactData = (CNContact, Int)

class TrashViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ContactCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private var contacts: [CNContact] = []
    private var contactColorsArray: [CNContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contacts = ContactStore.shared.getTrash()
        contactColorsArray = ContactStore.shared.getTrash()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldShowAd(for: indexPath) {
            return generateAdRow(for: indexPath)
        }
        let contact = contacts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        cell.contactData = (contact, contactColorsArray.index(of: contact)!)
        cell.delegate = self
        return cell
    }
    
    func shouldShowAd(for indexPath: IndexPath) -> Bool {
        return (AdManager.shared.ads.count >= indexPath.row / 4) && (indexPath.row % 4 == 0) &&
            (indexPath.row > 0)
    }
    
    func generateAdRow(for indexPath: IndexPath) -> UITableViewCell {
        let nativeAd = AdManager.shared.ads[indexPath.row % 4]
        nativeAd.rootViewController = self
        
        let nativeAdCell = tableView.dequeueReusableCell(
            withIdentifier: "AdCell", for: indexPath)
        
        let adView : GADUnifiedNativeAdView = nativeAdCell.contentView.subviews[1] as! GADUnifiedNativeAdView
        
        // Associate the ad view with the ad object.
        // This is required to make the ad clickable.
        adView.nativeAd = nativeAd
        
        // Populate the ad view with the ad assets.
        (adView.headlineView as! UILabel).text = nativeAd.headline
        (adView.priceView as! UILabel).text = nativeAd.price
        if let starRating = nativeAd.starRating {
            (adView.starRatingView as! UILabel).text =
                starRating.description + "\u{2605}"
        } else {
            (adView.starRatingView as! UILabel).text = nil
        }
        (adView.bodyView as! UILabel).text = nativeAd.body
        (adView.advertiserView as! UILabel).text = nativeAd.advertiser
        // The SDK automatically turns off user interaction for assets that are part of the ad, but
        // it is still good to be explicit.
        (adView.callToActionView as! UIButton).isUserInteractionEnabled = false
        (adView.callToActionView as! UIButton).setTitle(
            nativeAd.callToAction, for: UIControlState.normal)
        
        return nativeAdCell
    }
    
    func didRestore(contact: CNContact) {
        guard contacts.contains(contact) else { return }
        let index = contacts.index(of: contact)!
        contacts.remove(at: index)
        let indexPath = IndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        ContactStore.shared.removeFromTrash(contact)
        dismissIfNeeded()
    }
    
    func didDelete(contact: CNContact) {
        guard contacts.contains(contact) else { return }
        let index = contacts.index(of: contact)!
        contacts.remove(at: index)
        let indexPath = IndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        ContactStore.shared.delete(contact)
        dismissIfNeeded()
    }
    
    func dismissIfNeeded() {
        if (contacts.count == 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func deleteAllButtonPressed(_ sender: Any) {
        let title = "Empty Trash?"
        let message = "Are you sure you want to delete all contacts in trash? This cannot be undone."
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
            action in
            SoundManager.shared.play(sound: .longTrash)
            ContactStore.shared.emptyTrash()
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
