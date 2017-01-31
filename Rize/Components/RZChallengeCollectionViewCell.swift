//
//  RZChallengeCollectionViewCell.swift
//  Rize
//
//  Created by Matthew Russell on 5/31/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

class RZChallengeCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView?
    var imageUrl: String?
    var likeImageView: UIImageView?
    var titleLabel: UILabel?
    var sponsorLabel: UILabel?
    var activityIndicator: UIActivityIndicatorView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // set the background
        self.backgroundColor = RZColors.cardBackground
        self.layer.cornerRadius = 5.0
        //self.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        //self.layer.borderWidth = 1.0
        self.clipsToBounds = true
        
        // create the imageView
        var imageViewRect = frame
        imageViewRect.origin.x = 0.0;
        imageViewRect.origin.y = 30.0;
        imageViewRect.size.width  = self.frame.size.width;
        imageViewRect.size.height = self.frame.size.height - 50.0;
        self.imageView = UIImageView(frame: imageViewRect)
        addSubview(imageView!)
        
        // Create the favorite imageView
        var likeImageRect = frame
        likeImageRect.size.width  = 20;
        likeImageRect.size.height = 20;
        likeImageRect.origin.x = frame.width - likeImageRect.size.width - 5;
        likeImageRect.origin.y = 5;
        self.likeImageView = UIImageView(frame: likeImageRect)
        self.likeImageView?.contentMode = .scaleAspectFit
        addSubview(likeImageView!)
        
        // create the title label
        self.titleLabel = UILabel(frame: CGRect(x: 8, y: 5, width: self.frame.width - 10, height: 20))
        self.titleLabel?.font = UIFont(name: "Avenir Light", size: 16.0)
        self.titleLabel?.text = "ROT HIGH FIVE"
        self.titleLabel?.textColor = UIColor(white: 0.3, alpha: 1.0)
        addSubview(titleLabel!)
        
        // create the sponsor label
        self.sponsorLabel = UILabel(frame: CGRect(x: 8, y: self.frame.height - 20, width: self.frame.width - 16, height: 20))
        self.sponsorLabel?.font = UIFont(name: "Avenir Light", size: 12.0)
        self.sponsorLabel?.text = "SODEXO"
        self.sponsorLabel?.textColor = UIColor(white: 0.3, alpha: 1.0)
        self.sponsorLabel?.textAlignment = .right
        addSubview(sponsorLabel!)
        
        // set up the image view
        self.imageView?.contentMode = .scaleAspectFill
        self.imageView?.clipsToBounds = true
        self.imageView?.backgroundColor = UIColor(white: 0.4, alpha: 1.0)
    }
    
    // Public function to set the image via URL
    func setImageFromURL(_ url: String) {
        // Load the image
        ImageLoader.setImageViewImage(url, view:imageView!, round: false) {
        }
    }
    
    func setLiked(_ liked: Bool)
    {
        if (liked) {
            self.likeImageView?.image = UIImage(named: "liked")
        } else {
            self.likeImageView?.image = nil
        }
    }
        
    
}
