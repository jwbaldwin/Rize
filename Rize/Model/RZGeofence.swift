//
//  RZGeofence.swift
//  Rize
//
//  Created by Matthew Russell on 12/22/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit
import CoreLocation

class RZGeofence: NSObject {
    var center : CLLocation?
    var radius : Double?
    
    init(lat: Double, lon: Double, radius: Double) {
        super.init()
        self.center = CLLocation(latitude: lat, longitude: lon)
        self.radius = radius
    }
}
