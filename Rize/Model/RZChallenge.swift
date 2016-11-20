//
//  RIZEChallenge.swift
//  Rize
//
//  Created by Matthew Russell on 5/26/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

class RZChallenge: NSObject {
    var id : String
    var title : String
    var sponsor : String
    var imageUrl : String
    var endDate : Int
    var liked : Bool = false
    
    init(id: String, title: String, sponsor: String, imageUrl: String, date: Int)
    {
        self.id = id
        self.sponsor = sponsor
        self.title = title
        self.imageUrl = imageUrl
        self.endDate = date
    }
}
