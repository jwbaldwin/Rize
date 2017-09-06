//
//  UIImageViewURLExtension.swift
//  Rize
//
//  Created by Matthew Russell on 9/5/17.
//  Copyright © 2017 Rize. All rights reserved.
//

import Foundation

extension UIImageView {
    public func imageFromURL(urlString: String) {
        let session = URLSession(configuration: .default)
        print("\nImage =", urlString, "\n")
        session.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data!)
                self.image = image
            }
        }).resume()
    }
}
