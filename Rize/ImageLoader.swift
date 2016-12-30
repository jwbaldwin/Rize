//
//  ImageLoader.swift
//  Rize
//
//  Created by Matthew Russell on 6/2/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import Foundation
import UIKit

class ImageLoader {
    static func createRoundImage(_ input : UIImage) -> UIImage {
        UIGraphicsBeginImageContext(input.size)
        UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: 0, y: 0), size: input.size), cornerRadius: input.size.width/2).addClip()
        input.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: input.size))
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output!
    }
    
    static func setImageViewImage(_ url: String, view: UIImageView, round : Bool, complete: (() -> Void)? = {}) {
        downloadImageFromURL(url, complete: {(image: UIImage) -> Void in
            if round {
                view.image = createRoundImage(image)
            } else {
                view.image = image
            }
            view.setNeedsDisplay()
            complete?()
        })
    }
    
    static func downloadImageFromURL(_ url: String, complete: ((_ image: UIImage) -> Void)?) {
        // Create URL from string
        let url = URL(string: url)!
        
        // Download task
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
            (responseData, responseUrl, error) -> Void in
            let data = responseData!
            if (responseData != nil) {
                DispatchQueue.main.async(execute: { () -> Void in
                    complete?(UIImage(data: data)!)
                })
            }
        }) 
        task.resume()
    }
}
