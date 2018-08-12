//
//  AdManager.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 8/11/18.
//  Copyright © 2018 Haven Barnes. All rights reserved.
//

import Foundation
import GoogleMobileAds

class AdManager: NSObject, GADUnifiedNativeAdLoaderDelegate {
    static let shared = AdManager()
    
    // Test
    let adUnitID = "ca-app-pub-3940256099942544/8407707713"
    // Prod
    //let adUnitID = "ca-app-pub-6103293012504966/3824734522"
    
    private let numAdsToLoad = 5
    private var adLoader: GADAdLoader!
    var ads = [GADUnifiedNativeAd]()
    
    func load() {
        let options = GADMultipleAdsAdLoaderOptions()
        options.numberOfAds = numAdsToLoad
        adLoader = GADAdLoader(adUnitID: adUnitID,
                               rootViewController: nil,
                               adTypes: [.unifiedNative],
                               options: [options])
        adLoader.delegate = self
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        adLoader.load(request)
    }
    
    // MARK: - GADAdLoaderDelegate
    
    func adLoader(_ adLoader: GADAdLoader,
                  didFailToReceiveAdWithError error: GADRequestError) {
        print("AdManager | \(adLoader) failed with error: \(error.localizedDescription)")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        print("AdManager | Received native ad: \(nativeAd)")
        
        // Add the native ad to the list of native ads.
        ads.append(nativeAd)
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        print("AdManager | \(adLoader) finished loading")
    }
}
