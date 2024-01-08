//
//  NibView.swift
//  FEEAlert
//
//  Created by Fee on 2024/1/5.
//

import UIKit

class NibView: UIView {
    
    class func instance() -> NibView {
        return Bundle.main.loadNibNamed("NibView", owner: nil)!.last as! NibView
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
