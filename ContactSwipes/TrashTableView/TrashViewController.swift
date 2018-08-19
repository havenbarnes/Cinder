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

class TrashViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ContactCellDelegate, GADInterstitialDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let interstitial = GADInterstitial(adUnitID: "ca-app-pub-6103293012504966/9853415237")
    
    private var contacts: [CNContact] = []
    private var contactColorsArray: [CNContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitial.load(GADRequest())
        interstitial.delegate = self
        
        loadTable {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
            }, completion: nil)
        }
    }
    
    func loadTable(completion: @escaping ()->()) {
        DispatchQueue.global(qos: .background).async {
            self.contacts = ContactStore.shared.getTrash()
            self.contactColorsArray = ContactStore.shared.getTrash()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count + contacts.count / 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldShowAd(for: indexPath) {
            let adCell = tableView.dequeueReusableCell(withIdentifier: "AdCell")!
            let bannerContainer = adCell.contentView.subviews.first!
            if let currentBanner = bannerContainer.subviews.first {
                currentBanner.removeFromSuperview()
            }
            let bannerId = "ca-app-pub-6103293012504966/3824734522" // Prod
            //let bannerId = "ca-app-pub-3940256099942544/2934735716" // Test
            let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            bannerView.adUnitID = bannerId
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerContainer.addSubview(bannerView)
            bannerView.alpha = 0
            UIView.animate(withDuration: 1, animations: {
                bannerView.alpha = 1
            })
            return adCell
        }
        let contact = contacts[indexPath.row - indexPath.row / 5]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        cell.contactData = (contact, contactColorsArray.index(of: contact)!)
        cell.delegate = self
        return cell
    }
    
    func shouldShowAd(for indexPath: IndexPath) -> Bool {
        return ((indexPath.row + 1) % 5 == 0) && (indexPath.row > 0)
    }
    
    func generateNativeAdRow(for indexPath: IndexPath) -> UITableViewCell {
        let nativeAd = AdManager.shared.ads[(indexPath.row / 5) % 5]
        nativeAd.rootViewController = self
        
        let nativeAdCell = tableView.dequeueReusableCell(
            withIdentifier: "AdCell", for: indexPath)
        
        let adView : GADUnifiedNativeAdView = nativeAdCell.contentView.subviews[1] as! GADUnifiedNativeAdView
        
        // Associate the ad view with the ad object.
        // This is required to make the ad clickable.
        adView.nativeAd = nativeAd
        
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
        (adView.callToActionView as! UIButton).isUserInteractionEnabled = false
        (adView.callToActionView as! UIButton).setTitle(nativeAd.callToAction, for: UIControlState.normal)
        return nativeAdCell
    }
    
    func didRestore(contact: CNContact) {
        guard contacts.contains(contact) else { return }
        let index = contacts.index(of: contact)!
        contacts.remove(at: index)
        tableView.reloadData()
        ContactStore.shared.removeFromTrash(contact)
        dismissIfNeeded()
    }
    
    func didDelete(contact: CNContact) {
        guard contacts.contains(contact) else { return }
        let index = contacts.index(of: contact)!
        contacts.remove(at: index)
        tableView.reloadData()
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
    
    // MARK: - Interstitial Delegate
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        self.dismiss(animated: true, completion: nil)
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
            if self.interstitial.isReady {
                self.interstitial.present(fromRootViewController: self)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
