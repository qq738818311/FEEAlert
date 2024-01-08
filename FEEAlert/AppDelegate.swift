//
//  AppDelegate.swift
//  FEEAlert
//
//  Created by Fee on 2024/1/5.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        
        var vcArray: [NavigationViewController] = []
        for i in 0...1 {
            let vc = i == 0 ? AlertViewController() : ActionSheetViewController()
            let nav = NavigationViewController(rootViewController: vc)
            nav.navigationBar.isTranslucent = false
            vc.title = i == 0 ? "Alert" : "ActionSheet"

            if #available(iOS 13.0, *) {
                vc.tabBarItem.image = UIImage(systemName: i == 0 ? "square.and.arrow.up.fill" : "square.and.arrow.down.fill")
            } else {
                // Fallback on earlier versions
            }
            vcArray.append(nav)
        }
        
        let tabVc = TabBarViewController()
        tabVc.viewControllers = vcArray
        window?.rootViewController = tabVc
        return true
    }

}

