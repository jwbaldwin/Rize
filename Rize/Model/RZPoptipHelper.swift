//
//  RZPoptipHelper.swift
//  Rize
//
//  Created by Matthew Russell on 7/31/17.
//  Copyright © 2017 Rize. All rights reserved.
//

import UIKit
import AMPopTip

class RZPoptipHelper: NSObject {

    fileprivate static var instance : RZPoptipHelper?
    
    /* +1 for shared static helpers *fist pump* */
    static func shared() -> RZPoptipHelper {
        if (instance == nil)
        {
            instance = RZPoptipHelper()
        }
        return instance!
    }
    
    fileprivate override init() {
        
    }
    
    func makePoptip() -> AMPopTip
    {
        let popTip = AMPopTip()
        popTip.edgeMargin = 5.0;
        popTip.edgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        popTip.offset = 10.0;
        popTip.popoverColor = RZColors.primary
        popTip.shouldDismissOnTap = true
        popTip.font = UIFont.systemFont(ofSize: 16.0)
        return popTip
    }
    
    func showPopTip(text: String, direction: AMPopTipDirection, in view: UIView, fromFrame frame: CGRect, completion: @escaping (() -> Void)) {
        let popTip = makePoptip()
        popTip.dismissHandler = completion
        popTip.showText(text, direction: direction, maxWidth: 250.0, in: view, fromFrame: frame)
    }
    
        // MARK: - tutorial settings
    enum RizeScreen {
        case Browse
        case ChallengeDetail
        case Camera
        case Me
        case Settings
        case Login
        case SubmissionDetail
        case Wallet
    }
    /* check if we should show the poptips for this screen */
    func shouldShowTips(forScreen screen : RizeScreen) -> Bool {
        /* a false value in the defaults means that the tutorial has not been shown yet */
        let defaults = UserDefaults.standard
        switch screen {
        case .Browse:
            return !defaults.bool(forKey: "tutorial-browse")
        case .ChallengeDetail:
            return !defaults.bool(forKey: "tutorial-challenge")
        case .Camera:
            return !defaults.bool(forKey: "tutorial-camera")
        case .Me:
            return !defaults.bool(forKey: "tutorial-me")
        case .Settings:
            return !defaults.bool(forKey: "tutorial-settings")
        case .Login:
            return !defaults.bool(forKey: "tutorial-login")
        case .SubmissionDetail:
            return !defaults.bool(forKey: "tutorial-submission")
        case .Wallet:
            return !defaults.bool(forKey: "tutorial-wallet")
        }
        /* no need for a default, all cases handled */
    }
    
    /* let us set whether we have shown the tutorial for a particular screen yet */
    func setDidShowTips(_ didShow : Bool, forScreen screen : RizeScreen) {
        let defaults = UserDefaults.standard
        switch screen {
        case .Browse:
            defaults.set(didShow, forKey: "tutorial-browse")
        case .ChallengeDetail:
            defaults.set(didShow, forKey: "tutorial-challenge")
        case .Camera:
            defaults.set(didShow, forKey: "tutorial-camera")
        case .Me:
            defaults.set(didShow, forKey: "tutorial-me")
        case .Settings:
            defaults.set(didShow, forKey: "tutorial-settings")
        case .Login:
            defaults.set(didShow, forKey: "tutorial-login")
        case .SubmissionDetail:
            defaults.set(didShow, forKey: "tutorial-submission")
        case .Wallet:
            defaults.set(didShow, forKey: "tutorial-wallet")
        }
    }
}
