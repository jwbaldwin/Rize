//
//  RZChallengeTier.swift
//  Rize
//
//  Created by Matthew Russell on 4/2/17.
//  Copyright © 2017 Rize. All rights reserved.
//

import UIKit

class RZChallengeTier: NSObject {
    var title : String = ""
    var points : Int = 0
    
    init(title: String, points: Int)
    {
        super.init()
        self.title = title
        self.points = points
    }
}
