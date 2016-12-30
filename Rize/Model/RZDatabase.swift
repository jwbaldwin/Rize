//
//  RZDatabase.swift
//  Rize
//
//  Created by Matthew Russell on 8/14/16.
//  Copyright © 2016 Rize. All rights reserved.
//
import FirebaseDatabase
import Firebase

protocol RZDatabaseDelegate: class {
    func databaseDidFinishLoading(_ database: RZDatabase)
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
    
    func refresh() {
        // get submissions
        self.firebaseRef?.child("users/\(FIRAuth.auth()!.currentUser!.uid)/submissions").observe(.value, with: { (snapshot) in
            self._submissions = []
            for child in snapshot.children {
                // create the challenge object
                let item = (child as! FIRDataSnapshot).value as! [ String : AnyObject ]
                let submission = RZSubmission()
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
                self._submissions?.append(submission)
            }
            self.updateAllSubmissionStats(nil)
        })
        
        // load challenge data
        self.firebaseRef?.child("challenges").observe(.value, with: { (snapshot) in
            let snap = snapshot
            self._challenges = []
            for child in snap.children {
                // create the challenge object
                let item = (child as! FIRDataSnapshot).value as! [ String : AnyObject ]
                let challenge = RZChallenge()
                challenge.id = (child as AnyObject).key
                challenge.title = item["title"] as? String
                challenge.sponsor = item["sponsor"] as? String
                challenge.iconUrl = item["icon"] as? String
                challenge.bannerUrl = item["banner"] as? String
                challenge.endDate = item["end_date"] as? Int
                challenge.reward = item["reward"] as? String
                challenge.pointsRequired = item["points_required"] as? Int
                challenge.maxSubmissions = item["max_submissions"] as? Int
                challenge.submissions = item["submissions"] as? Int
                
                if let limits = item["limits"] as? [String : Int] {
                    challenge.likesLimit = limits["likes"]
                    challenge.sharesLimit = limits["shares"]
                    challenge.viewsLimit = limits["views"]
                }
                
                if (item["geofence"] != nil) {
                    let geofenceData = item["geofence"] as! [String : AnyObject]
                    let center = geofenceData["center"] as! [String : Double]
                    challenge.geofence = RZGeofence(lat: center["lat"]!, lon: center["lon"]!, radius: geofenceData["radius"] as! Double)
                }
                
                // add the challenge to the list
                self._challenges!.append(challenge)
            }
            self.delegate?.databaseDidFinishLoading(self)
        })
        
        // get likes
        let userLikesRef = self.firebaseRef?.child("users/\(FIRAuth.auth()!.currentUser!.uid)/likes")
        print("users/\(FIRAuth.auth()!.currentUser!.uid)/likes")
        // load user likes
        userLikesRef?.observe(.value, with: { (snapshot) in
            print("Retrieved likes")
            if (snapshot.hasChildren()) {
                self._likes = snapshot.value as! [String]
                self.delegate?.databaseDidFinishLoading(self)
            }
            self.delegate?.databaseDidFinishLoading(self)
        })
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
    func challenges() -> [RZChallenge]? {
        return _challenges
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
    
    func submissions() -> [RZSubmission]?
    {
        return self._submissions
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
        var myGroup = DispatchGroup()
        if (self._submissions != nil) {
            for submission in self._submissions!
            {
                myGroup.enter()
                RZFBGraphRequestHelper.getFBGraphData(endpoint: "\(submission.fb_id!)?fields=likes.limit(0).summary(true),sharedposts") { (result) in
                    if let likes = result["likes"] as? [String : AnyObject?] {
                        if let summary = likes["summary"] as? [String : AnyObject?] {
                            let likeCount = summary["total_count"] as! Int
                            submission.likes = likeCount
                        }
                    }
                    submission.updatePoints()
                    myGroup.leave()
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
    
    
}
