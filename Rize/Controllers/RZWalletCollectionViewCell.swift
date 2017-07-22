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
    @IBOutlet weak var iconUrl: UIImageView!
    @IBOutlet weak var showReward: UIButton!
    @IBOutlet weak var tier: UILabel!
    @IBOutlet weak var backgroundUrl: UIImageView!
    
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
    
    //Public function to set the image via URL
    func setImageFromURL(_ url: String) {
        // Load the image
        ImageLoader.setImageViewImage(url, view: iconUrl!, round: true) {
        }
        iconUrl.layer.borderWidth = 3
        iconUrl.layer.borderColor = UIColor.white.cgColor
        iconUrl.layer.cornerRadius = 30
    }
    
    func setBackgroundImageFromURL(_ url: String) {
        // Load the image
        ImageLoader.setImageViewImage(url, view: backgroundUrl!, round: false) {
        }
        
        backgroundUrl.layer.cornerRadius = 5
        backgroundUrl.clipsToBounds = true
    }
    
}
