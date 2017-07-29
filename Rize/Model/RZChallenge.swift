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
    var startDate : String?
    var endDate : String?
    var liked : Bool = false
    var geofence : RZGeofence?
    var maxSubmissions : Int?
    var submissions : Int?
    var tiers : [RZChallengeTier] = []
    var media : String = "video" // default to video challenge
    
    func isActive() -> Bool {
        let currentDate = Date()
        guard let _ = startDate
            else { return false }
        guard let _ = endDate
            else { return false }
        
        let startDateObj = getStartDateObject()
        let endDateObj = getEndDateObject()
        return (currentDate.compare(startDateObj!) == .orderedDescending && currentDate.compare(endDateObj!) == .orderedAscending)
    }
    
    func getStartDateObject() -> Date?
    {
        guard let _ = startDate
            else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: startDate!)
    }
    
    func getEndDateObject() -> Date?
    {
        guard let _ = endDate
            else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: endDate!)
    }
}
