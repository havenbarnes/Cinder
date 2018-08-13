//
//  AppDelegate.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 12/31/17.
//  Copyright © 2017 Haven Barnes. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-6103293012504966~4319558547")
        //AdManager.shared.load()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {
        ContactStore.shared.checkForContactAccess()
    }

    func applicationWillTerminate(_ application: UIApplication) {}
}
