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
    static func setImageViewImage(_ url: String, view: UIImageView, complete: (() -> Void)? = {}) {
        downloadImageFromURL(url, complete: {(image: UIImage) -> Void in
            view.image = image
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
