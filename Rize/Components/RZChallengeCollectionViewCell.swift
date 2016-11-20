//
//  RZChallengeCollectionViewCell.swift
//  Rize
//
//  Created by Matthew Russell on 5/31/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

class RZChallengeCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var imageUrl: String!
    var likeImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        // Create the imageView
        var imageViewRect = frame
        imageViewRect.origin.x = 0.0;
        imageViewRect.origin.y = 0.0;
        imageViewRect.size.width  = self.frame.size.width;
        imageViewRect.size.height = self.frame.size.height;
        self.imageView = UIImageView(frame: imageViewRect)
        addSubview(imageView)
        
        // Create the favorite imageView
        var likeImageRect = frame
        likeImageRect.size.width  = 25;
        likeImageRect.size.height = 25;
        likeImageRect.origin.x = frame.width - likeImageRect.size.width - 5;
        likeImageRect.origin.y = 5;
        self.likeImageView = UIImageView(frame: likeImageRect)
        addSubview(likeImageView)
        
        // set up the image view as a circle
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.layer.cornerRadius = self.imageView.frame.width / 2
        self.imageView.clipsToBounds = true
    }
    
    // Public function to set the image via URL
    func setImageFromURL(_ url: String) {
        // Load the image
        ImageLoader.setImageViewImage(url, view:imageView)
    }
    
    func setLiked(_ liked: Bool)
    {
        if (liked) {
            self.likeImageView.image = UIImage(named: "heart-liked")
        } else {
            self.likeImageView.image = nil
        }
    }
    
    // MARK: Load Image Helper
    
    
}
