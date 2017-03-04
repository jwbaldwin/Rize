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
    var pointsRequired : Int?
    var maxSubmissions : Int?
    var submissions : Int?
    var likesLimit : Int?
    var viewsLimit : Int?
    var sharesLimit: Int?
    var rewardTitle: String?
    var rewardLink: String?
    var rewardMessage: String?
    
    func isActive() -> Bool {
        let date = Date().timeIntervalSince1970
        guard let _ = endDate
            else { return false }
        
        return (Int(date) < endDate!)
    }
}
