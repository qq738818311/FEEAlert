//
//  TabBarViewController.swift
//  FEEAlert
//
//  Created by Fee on 2024/1/5.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var childForStatusBarStyle: UIViewController? {
        return selectedViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        return selectedViewController
    }

    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return selectedViewController
    }

    override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return selectedViewController
    }

    override var shouldAutorotate: Bool {
        return selectedViewController?.shouldAutorotate ?? false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return selectedViewController?.supportedInterfaceOrientations ?? .all
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return selectedViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}

