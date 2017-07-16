//
//  RZWalletTableViewCell.swift
//  Rize
//
//  Created by James Baldwin on 5/29/17.
//  Copyright © 2017 Rize. All rights reserved.
//

import UIKit

//----- Protocol for the delegate -----//
protocol CellInfoDelegate {
    func animateInRedeem(_ : UICollectionViewCell)
    func animateInShare(_ : UICollectionViewCell)
    func getCodeForCell(_ : UICollectionViewCell)
}

//----- Cell to Pass info to Parent -----//
class RZWalletCollectionViewCell: UICollectionViewCell {
    var delegate: CellInfoDelegate?
    
    @IBOutlet weak var rewardName: UILabel!
    @IBOutlet weak var expDate: UILabel!
    @IBOutlet weak var companyLocation: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!

    
    @IBAction func shareBtn(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.animateInShare(self)
            delegate.getCodeForCell(self)
        }
    }

    @IBAction func showReward(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.animateInRedeem(self)
            delegate.getCodeForCell(self)
        }
        
    }
    
    // Public function to set the image via URL
//    func setImageFromURL(_ url: String) {
//        // Load the image
//        ImageLoader.setImageViewImage(url, view: companyLogo!, round: false) {
//        }
//    }
    
}
