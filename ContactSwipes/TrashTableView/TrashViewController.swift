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
    
    let interstitial = GADInterstitial(adUnitID: AdConfig.interstitialAdId)
    
    private var contacts: [CNContact] = []
    private var contactColorsArray: [CNContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitial.load(GADRequest())
        interstitial.delegate = self

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
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

            let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            bannerView.adUnitID = AdConfig.bannerAdId
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
        cell.contactData = (contact, contactColorsArray.firstIndex(of: contact) ?? 0)
        cell.delegate = self
        return cell
    }
    
    func shouldShowAd(for indexPath: IndexPath) -> Bool {
        return ((indexPath.row + 1) % 5 == 0) && (indexPath.row > 0)
    }
    
    func didRestore(contact: CNContact) {
        guard contacts.contains(contact) else { return }
        if let index = contacts.firstIndex(of: contact) {
            contacts.remove(at: index)
            ContactStore.shared.removeFromTrash(contact)
        }
        dismissIfNeeded()
        tableView.reloadData()
    }
    
    func didDelete(contact: CNContact) {
        guard contacts.contains(contact) else { return }
        if let index = contacts.firstIndex(of: contact) {
            contacts.remove(at: index)
            ContactStore.shared.delete(contact)
        }
        dismissIfNeeded()
        tableView.reloadData()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.dismiss(animated: true, completion: nil)
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
            if self.interstitial.isReady {
                self.interstitial.present(fromRootViewController: self)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
