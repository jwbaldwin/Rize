//
//  RZChallengeHeaderView.swift
//  Rize
//
//  Created by Matthew Russell on 6/2/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

let INSET : CGFloat = 20.0

class RZChallengeHeaderView: UIView {
    var minHeight : CGFloat = 88.0
    var maxHeight : CGFloat = 184.0
    fileprivate var borderWidth : CGFloat = 20.0
    var navBarHeight : CGFloat = 84.0
    
    @IBOutlet var imageView : UIImageView!
    @IBOutlet var timeLabel : UILabel!
    fileprivate var _challenge : RZChallenge!
    
    var challenge : RZChallenge {
        set {
            _challenge = newValue
            
            // Update the view components for the new challenge
            if (self.imageView != nil)
            {
                // set up the image view as a circle
                self.imageView.contentMode = .scaleAspectFill
                self.imageView.clipsToBounds = true
                updateImage()
            }
            
            let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            var comps = (calendar as NSCalendar?)?.components(.day, from: Date(), to:             Date(timeIntervalSince1970: Double(_challenge.endDate)), options: NSCalendar.Options())
            let days = comps!.day
            comps = (calendar as NSCalendar?)?.components(.hour, from: Date(), to:             Date(timeIntervalSince1970: Double(_challenge.endDate)), options: NSCalendar.Options())
            let hours = comps!.hour! - days! * 24
            timeLabel.text = String(format: "%02d:%02d", days!, hours)
        }
        get { return _challenge }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        minHeight = self.frame.width / 5
        maxHeight = 1.5 * minHeight
        borderWidth = 10.0
    }
    
    
    func updateImage()
    {
        if (self._challenge != nil)
        {
            ImageLoader.setImageViewImage(self._challenge.imageUrl, view: self.imageView)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateImage()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        // make the image view a circle
        self.imageView.layer.cornerRadius = self.imageView.frame.width / 2
        
        /*
        // fancy scrolling code
        let height = self.frame.height - navBarHeight;
        
        if (self.imageView != nil)
        {
            var imageFrame = CGRectZero
            imageFrame.origin.x = borderWidth //(height - minHeight) / (maxHeight - minHeight) * borderWidth
            imageFrame.origin.y = borderWidth // (height - minHeight) / (maxHeight - minHeight) * borderWidth;
            imageFrame.size.width = (height - imageFrame.origin.y * 2)
            imageFrame.size.height = (height - imageFrame.origin.y * 2)
            imageFrame.origin.y += navBarHeight
            self.imageView.frame = imageFrame
        }
        */
        
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
