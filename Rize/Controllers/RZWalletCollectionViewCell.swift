//
//  RZWalletCollectionViewCell.swift
//  Rize
//
//  Created by James Baldwin on 4/3/17.
//  Copyright © 2017 Rize. All rights reserved.
//

import UIKit

class RZWalletCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var rewardName: UILabel!
    @IBOutlet weak var expDate: UILabel!
    @IBOutlet weak var companyLoc: UILabel!
    @IBOutlet weak var redeemBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var redeemCode: UILabel!
    @IBOutlet weak var arrows: UIImageView!
    @IBAction func showCode(_ sender: Any) {
        animateCode()
    }
    
    func animateCode(){
        if redeemCode.alpha == 0.0
        {
            UIView.animate(withDuration: 1.0, animations: {
                self.redeemCode.alpha = 1.0
                self.arrows.alpha = 1.0
            })
        }
        else
        {
            UIView.animate(withDuration: 1.0, animations: {
                self.redeemCode.alpha = 0.0
                self.arrows.alpha = 0.0
            })
        }
    }
    // Public function to set the image via URL
    func setImageFromURL(_ url: String) {
        // Load the image
        ImageLoader.setImageViewImage(url, view: companyLogo!, round: false) {
        }
    }
}
