//
//  RZSubmission.swift
//  Rize
//
//  Created by Matthew Russell on 12/21/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

class RZSubmission: NSObject {
    var challenge_id : String?
    var id : String?
    var fb_id : String?
    var approved : Bool?
    var likes : Int?
    var shares : Int?
    var redeemed : Bool?
    var complete : Bool?
    var points : Int?
    var facebook : Bool?
    var friends : Int?
    
    let POINTS_LIKE : Double = 0.5
    let POINTS_SHARE : Double = 5
    let POINTS_FB : Double = 30
    
    func dictionaryValue() -> [String : AnyObject?] {
        var result = [String : AnyObject?]()
        result["id"] = id as AnyObject
        result["fb_id"] = fb_id as AnyObject
        result["approved"] = approved as AnyObject
        result["redeemed"] = redeemed as AnyObject
        result["facebook"] = facebook as AnyObject
        result["challenge_id"] = challenge_id as AnyObject
        result["likes"] = likes as AnyObject
        result["shares"] = shares as AnyObject
        result["points"] = points as AnyObject
        result["complete"] = complete as AnyObject
        result["friends"] = friends as AnyObject
        return result
    }
    
    func pointsFromLikes() -> Int {
        if challenge_id != nil && likes != nil {
            let challenge = RZDatabase.sharedInstance().getChallenge(challenge_id!)!
            if (likes! <= challenge.likesLimit!) {
                return Int(floor(Double(likes!) * POINTS_LIKE))
            }
            return Int(floor(Double(challenge.likesLimit!) * POINTS_LIKE))
        }
        return 0
    }
    
    func pointsFromShares() -> Int {
        if challenge_id != nil && shares != nil {
            let challenge = RZDatabase.sharedInstance().getChallenge(challenge_id!)!
            if (shares! <= challenge.sharesLimit!) {
                return Int(floor(Double(shares!) * POINTS_SHARE))
            }
            return Int(floor(Double(challenge.sharesLimit!) * POINTS_SHARE))
        }
        return 0
    }
    
    func updatePoints() {
        let challenge = RZDatabase.sharedInstance().getChallenge(challenge_id!)!
        
        points = 0
        if (facebook!) {
            points! += Int(POINTS_FB)
            points! += pointsFromLikes()
            points! += pointsFromShares()
        }
        
        if points! >= challenge.pointsRequired! {
            complete = true
        } else {
            complete = false
        }
    }
    
    func progress() -> Float {
        if challenge_id != nil && points != nil {
            let challenge = RZDatabase.sharedInstance().getChallenge(challenge_id!)!
            return Float(points!) / Float(challenge.pointsRequired!)
        }
        return 0.0
    }
    
    func sharesProgress() -> Float {
        if challenge_id != nil && shares != nil {
            let challenge = RZDatabase.sharedInstance().getChallenge(challenge_id!)!
            return Float(shares!) / Float(challenge.sharesLimit!)
        }
        return 0.0
    }
    
    func likesProgress() -> Float {
        if challenge_id != nil && likes != nil {
            let challenge = RZDatabase.sharedInstance().getChallenge(challenge_id!)!
            return Float(likes!) / Float(challenge.likesLimit!)
        }
        return 0.0
    }
    
    func isActive() -> Bool {
        let challenge = RZDatabase.sharedInstance().getChallenge(challenge_id!)!
        let date = Date().timeIntervalSince1970
        return (Int(date) < challenge.endDate!)
    }
}
