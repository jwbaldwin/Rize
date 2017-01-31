//
//  RZSubmissionTableViewCell.swift
//  Rize
//
//  Created by Matthew Russell on 12/29/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

class RZSubmissionTableViewCell: UITableViewCell {

    var progressView : UIProgressView? = nil
    var iconView : UIImageView? = nil
    var bannerView : UIImageView? = nil
    var blurView : UIVisualEffectView? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        progressView = UIProgressView()
        progressView?.progressTintColor = RZColors.primary
        addSubview(progressView!)
        
        iconView = UIImageView()
        iconView?.clipsToBounds = true
        iconView?.contentMode = .scaleAspectFit
        addSubview(iconView!)
        
        bannerView = UIImageView()
        bannerView?.clipsToBounds = true
        bannerView?.contentMode = .scaleAspectFill
        //bannerView?.layer.opacity = 0.25
        bannerView?.image = UIImage(named: "generic_profile")
        insertSubview(bannerView!, at: 0)
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        insertSubview(blurView!, at: 1)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconView?.frame = CGRect(x: 15, y: 15, width: self.frame.height - 30, height: self.frame.height - 30)
        let textLabelX = 15 + self.frame.height - 30 + 15
        textLabel?.frame = CGRect(x: textLabelX, y: self.frame.height / 2 - 20, width: self.frame.width - textLabelX - 40, height: 20)
        progressView?.frame = CGRect(x: textLabelX, y: self.frame.height / 2 + 20, width: textLabel!.frame.width, height: 5)
        bannerView?.frame = self.bounds
        blurView?.frame = self.bounds
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
