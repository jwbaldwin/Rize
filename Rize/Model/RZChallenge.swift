//
//  RIZEChallenge.swift
//  Rize
//
//  Created by Matthew Russell on 5/26/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

class RZChallenge: NSObject {
    var id : String?
    var title : String?
    var sponsor : String?
    var iconUrl : String?
    var bannerUrl : String?
    var videoUrl : String?
    var videoThumbnailUrl : String?
    var endDate : Int?
    var liked : Bool = false
    var geofence : RZGeofence?
    var maxSubmissions : Int?
    var submissions : Int?
    var tiers : [RZChallengeTier] = []
    var media : String = "video" // default to video challenge
    
    func isActive() -> Bool {
        let date = Date().timeIntervalSince1970
        guard let _ = endDate
            else { return false }
        
        return (Int(date) < endDate!)
    }
}
