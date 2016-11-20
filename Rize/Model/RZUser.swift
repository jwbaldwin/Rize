//
//  RZUser.swift
//  Rize
//
//  Created by Matthew Russell on 7/2/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

class RZUser: NSObject {
    var name : String  // user's name
    var id : String    // user id
    var image : String // image url
    
    init(name: String, image: String) {
        self.name = name
        self.id = ""
        self.image = image
    }

}
