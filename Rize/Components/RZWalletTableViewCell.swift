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
    func animateInRedeem(_ : UITableViewCell)
    func animateInShare(_ : UITableViewCell)
    func getCodeForCell(_ : UITableViewCell)
}

//----- Cell to Pass info to Parent -----//
class RZWalletTableViewCell: UITableViewCell {
    var delegate: CellInfoDelegate?
    
    @IBOutlet weak var rewardName: UILabel!
    @IBOutlet weak var expDate: UILabel!
    @IBOutlet weak var companyLocation: UILabel!
    @IBOutlet weak var companyLogo: UIImageView!

    @IBAction func shareReward(_ sender: Any) {
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

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Public function to set the image via URL
    func setImageFromURL(_ url: String) {
        // Load the image
        ImageLoader.setImageViewImage(url, view: companyLogo!, round: false) {
        }
    }

}
