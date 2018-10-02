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
    
    static let bannerAd = "ca-app-pub-6103293012504966/3824734522"
    static let interstitialAd = "ca-app-pub-6103293012504966/9853415237"

    private let numAdsToLoad = 5
    private var adLoader: GADAdLoader!
    var ads = [GADUnifiedNativeAd]()
    
    func load() {
        let options = GADMultipleAdsAdLoaderOptions()
        options.numberOfAds = numAdsToLoad
        adLoader = GADAdLoader(adUnitID: AdManager.bannerAd,
                               rootViewController: nil,
                               adTypes: [.unifiedNative],
                               options: [options])
        adLoader.delegate = self
        let request = GADRequest()
        request.testDevices = ["df6f08837354521ec6e9482771742dfc"]
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
