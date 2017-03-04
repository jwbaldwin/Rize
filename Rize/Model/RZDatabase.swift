//
//  RZDatabase.swift
//  Rize
//
//  Created by Matthew Russell on 8/14/16.
//  Copyright © 2016 Rize. All rights reserved.
//
import FirebaseDatabase
import Firebase
import CoreLocation

protocol RZDatabaseDelegate: class {
    func databaseDidUpdate(_ database: RZDatabase)
}

class RZDatabase: NSObject {

    fileprivate static var instance : RZDatabase?       // shared instance
    
    fileprivate var firebaseRef : FIRDatabaseReference? // Firebase database reference
    fileprivate var _likes : [String]?                  // list of this user's likes
    fileprivate var _challenges : [RZChallenge]?        // challenges
    fileprivate var _submissions : [RZSubmission]?      // user submissions
    var delegate : RZDatabaseDelegate?

    static func sharedInstance() -> RZDatabase {
        // check if the instance needs to be created
        if (instance == nil)
        {
            instance = RZDatabase()
        }
        
        return instance!
    }
    
    fileprivate override init() {
        // setup the shared instance
        // grab the database reference
        firebaseRef = FIRDatabase.database().reference()
    }
    
    func observe() {
        // begin observation of Firebase data
        
        // observe challenge data
        self.firebaseRef?.child("challenges").observe(.value, with: { (snapshot) in
            self.updateChallenges(fromSnapshot: snapshot)
            self.delegate?.databaseDidUpdate(self)
        })
        
        // observe the submission data
        self.firebaseRef?.child("users/\(FIRAuth.auth()!.currentUser!.uid)/submissions").observe(.value, with: { (snapshot) in
            self.updateSubmissions(fromSnapshot: snapshot) {
                self.delegate?.databaseDidUpdate(self)
            }
        })
        
        // observe the likes data
        self.firebaseRef?.child("users/\(FIRAuth.auth()!.currentUser!.uid)/likes").observe(.value, with: { (snapshot) in
            if (snapshot.hasChildren()) {
                self._likes = snapshot.value as! [String]
                self.delegate?.databaseDidUpdate(self)
            }
        })
    }
    
    func updateChallenges(fromSnapshot snapshot : FIRDataSnapshot) {
        self._challenges = []

        for child in snapshot.children {
            // create the challenge object
            let item = (child as! FIRDataSnapshot).value as! [ String : AnyObject ]
            let challenge = RZChallenge()
            
            // populate the challenge object
            challenge.id = (child as AnyObject).key
            challenge.title = item["title"] as? String
            challenge.sponsor = item["sponsor"] as? String
            challenge.iconUrl = item["icon"] as? String
            challenge.bannerUrl = item["banner"] as? String
            challenge.videoUrl = item["video"] as? String
            challenge.videoThumbnailUrl = item["video_thumbnail"] as? String
            challenge.endDate = item["end_date"] as? Int
            challenge.pointsRequired = item["points_required"] as? Int
            challenge.maxSubmissions = item["max_submissions"] as? Int
            challenge.submissions = item["submissions"] as? Int
            
            if let reward = item["reward"] as? [String : String] {
                challenge.rewardTitle = reward["title"]
                challenge.rewardMessage = reward["message"]
                challenge.rewardLink = reward["link"]
            }
            
            // make sure the limits exist and then update
            if let limits = item["limits"] as? [String : Int] {
                challenge.likesLimit = limits["likes"]
                challenge.sharesLimit = limits["shares"]
                challenge.viewsLimit = limits["views"]
            }
            
            // make sure the geofence data is there
            if (item["geofence"] != nil) {
                guard let geofenceData = item["geofence"] as? [String : AnyObject]
                    else { break }
                guard let center = geofenceData["center"] as? [String : Double]
                    else { break }
                guard let radius = geofenceData["radius"] as? Double
                    else { break }
                
                challenge.geofence = RZGeofence(lat: center["lat"]!, lon: center["lon"]!, radius: radius)
            }
            
            // add the challenge to the list
            self._challenges!.append(challenge)
        }
    }
    
    func updateSubmissions(fromSnapshot snapshot : FIRDataSnapshot, complete : (() -> Void)?) {
        // setup submission info
        self._submissions = []
        
        // loop through each submission
        for child in snapshot.children {
            // create the challenge object
            let item = (child as! FIRDataSnapshot).value as! [ String : AnyObject ]
            let submission = RZSubmission()
            
            // populate the submission object
            submission.challenge_id = item["challenge_id"] as? String
            submission.id = (child as! FIRDataSnapshot).key as? String
            submission.facebook = item["facebook"] as? Bool
            submission.fb_id = item["fb_id"] as? String
            submission.approved = item["approved"] as? Bool
            submission.redeemed = item["redeemed"] as? Bool
            submission.likes = item["likes"] as? Int
            submission.shares = item["shares"] as? Int
            submission.points = item["points"] as? Int
            submission.friends = item["friends"] as? Int
            submission.complete = item["complete"] as? Bool
            
            // add the submission to the list
            self._submissions?.append(submission)
        }
        
        self.updateAllSubmissionStats() {
            complete?()
        }
    }
    
    func pushLikes() {
        // sync likes
        firebaseRef!.child("users/\(FIRAuth.auth()!.currentUser!.uid)/likes").setValue(self._likes)
    }
    
    // MARK: - Likes
    
    func likes() -> [String]? {
        return _likes
    }
    
    func putLike(_ challengeId: String) {
        if (self._likes == nil) {
            self._likes = []
        }
        
        if (!self._likes!.contains(challengeId)) {
            self._likes?.append(challengeId)
        }
        print("\(self._likes)")
    }
    
    func removeLike(_ challengeId: String) {
        if (self._likes != nil && self._likes!.contains(challengeId)) {
            self._likes?.remove(at: self._likes!.index(of: challengeId)!)
        }
    }
    
    func isLiked(_ challengeId: String) -> Bool {
        if (self._likes != nil && self._likes!.contains(challengeId)) {
            return true
        }
        return false
    }
    
    // MARK: - Challenges
    func getChallenges(onlyActive: Bool, forLocation location: CLLocation?) -> [RZChallenge]? {
        var filteredChallenges : [RZChallenge] = []
        
        // return only currently active challenges
        guard let _ = _challenges
            else { return nil }
        
        for challenge in _challenges! {
            var shouldInclude = true
        
            // should we check for active challenges?
            if onlyActive {
                // test if each challenge is active
                
                guard let endDate = challenge.endDate
                    else { break }
                
                if Int(Date().timeIntervalSince1970) > endDate {
                    // this challenge is inactive, don't include it
                    shouldInclude = false
                }
            }
            
            // should we check for geofences?
            if challenge.geofence != nil {
                // the challenge should be geofenced (restricted)
                
                if location != nil {
                    // boom. we've got a location to check
                    guard let _ = challenge.geofence
                        else { break }
                    
                    // compare to challenge geofence
                    let dist = challenge.geofence!.center!.distance(from: location!)
                    if dist > challenge.geofence!.radius! {
                        // aaah. outside the geofence
                        shouldInclude = false
                    }
                } else {
                    // challenge should be restricted, but we have no location to check
                    // exclude this challenge, just to be safe
                    shouldInclude = false
                }
            }
            
            if shouldInclude {
                filteredChallenges.append(challenge)
            }
        }
        
        // return challenges
        return filteredChallenges
    }
    
    func getChallenge(_ id : String) -> RZChallenge?
    {
        if (self._challenges != nil) {
            for challenge in self._challenges!
            {
                if challenge.id == id {
                    return challenge
                }
            }
        }
        return nil
    }
    
    // MARK: - Submission
    func pushSubmission(_ submissionId: String, submission: [String : AnyObject])
    {
        firebaseRef!.child("users/\(FIRAuth.auth()!.currentUser!.uid)/submissions/\(submissionId)").setValue(submission)
    }
    
    enum RZSubmissionFilter {
        case all, active, expired
    }
    func getSubmissions(filter: RZSubmissionFilter) -> [RZSubmission]?
    {
        var filteredSubmissions : [ RZSubmission ] = []
        
        guard let _ = _submissions
            else { return nil }
        
        for submission in _submissions! {
            var shouldInclude = true
            
            // check for the filters
            switch filter {
            case .all:
                break
            case .active:
                if !submission.isActive() {
                    shouldInclude = false
                }
            case .expired:
                if submission.isActive() {
                    shouldInclude = false
                }
            }
            
            // add the submission to the list if it passes the filters
            if shouldInclude {
                filteredSubmissions.append(submission)
            }
        }
        
        // return the submissions
        return filteredSubmissions
    }

    func getSubmission(_ submissionId : String) -> RZSubmission?
    {
        if (self._submissions != nil) {
            for submission in self._submissions!
            {
                if submission.id == submissionId {
                    return submission
                }
            }
        }
        return nil
    }
    
    func deleteSubmission(_ submissionId : String) {
        firebaseRef!.child("users/\(FIRAuth.auth()!.currentUser!.uid)/submissions/\(submissionId)").removeValue()
    }
    
    func syncSubmission(_ submissionId : String) {
        firebaseRef!.child("users/\(FIRAuth.auth()!.currentUser!.uid)/submissions/\(submissionId)").setValue(self.getSubmission(submissionId)?.dictionaryValue())
    }
    
    func syncAllSubmissions() {
        for submission in self._submissions! {
            self.syncSubmission(submission.id!)
        }
    }
    
    func updateAllSubmissionStats(_ complete: (() -> Void)?) {
        // update all statistic info for the submissions
        let myGroup = DispatchGroup()
        if (self._submissions != nil) {
            for submission in self._submissions!
            {
                // make sure this has actually been uploaded to facebook
                guard let _ = submission.fb_id
                    else { continue }
                
                myGroup.enter()
                RZFBGraphRequestHelper.getFBGraphData(endpoint: "\(submission.fb_id!)?fields=likes.limit(0).summary(true),sharedposts") { (result, error) in
                
                    // make sure that whatever happens, we update the points
                    // and exit this dispatch group
                    defer {
                        submission.updatePoints()
                        myGroup.leave()
                    }
                    
                    if let _ = error {
                        // an error occured
                        submission.facebook = false
                        return
                    }
                    
                    guard let likes = result?["likes"] as? [String : AnyObject?]
                        else { return }
                    
                    guard let summary = likes["summary"] as? [String : AnyObject?]
                        else { return }
                    
                    let likeCount = summary["total_count"] as! Int
                    submission.likes = likeCount
    
                    // does this work for videos?
                    /*
                    guard let shares = result?["shares"] as? [String : AnyObject?]
                        else { return }
                    let shareCount = shares["count"] as! Int
                    submission.shares = shareCount
                    */
                    
                }
            }
        }
        myGroup.notify(queue: DispatchQueue.main) {
            complete?()
        }
    }
    
    // MARK: - Utility
    func setDatabaseValue(value: String, forKey key: String)
    {
        firebaseRef!.child("users/\(FIRAuth.auth()!.currentUser!.uid)/\(key)").setValue(value)
    }
    
    func getDatabaseValueForKey(key : String, complete: ((_ value: String?) -> Void)?)
    {
        firebaseRef!.child("users/\(FIRAuth.auth()!.currentUser!.uid)/\(key)").observeSingleEvent(of: .value, with: { (snapshot) in
            complete?(snapshot.value as! String?)
        })
    }
    
    // MARK: - Legal
    func getPrivacyPolicy(complete: @escaping ((_ content: String?, _ date: String?) -> Void)) {
        firebaseRef!.child("legal/privacy-policy").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let privacy = snapshot.value as? [ String : AnyObject? ]
                else { return }
                    
            complete(privacy["content"] as? String, privacy["date"] as? String)
        })
    }
    
    
}
