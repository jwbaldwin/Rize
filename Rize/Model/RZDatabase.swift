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
    fileprivate var _activeChallenges : [RZChallenge]?  // active challenges
    fileprivate var _submissions : [RZSubmission]?      // user submissions
    fileprivate var _activeSubmissions : [RZSubmission]?
    fileprivate var _expiredSubmissions : [RZSubmission]?
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
            let snap = snapshot
            self._challenges = []
            self._activeChallenges = []
            
            // get the current date
            let date = Date().timeIntervalSince1970
            
            for child in snap.children {
                // create the challenge object
                let item = (child as! FIRDataSnapshot).value as! [ String : AnyObject ]
                let challenge = RZChallenge()
                challenge.id = (child as AnyObject).key
                challenge.title = item["title"] as? String
                challenge.sponsor = item["sponsor"] as? String
                challenge.iconUrl = item["icon"] as? String
                challenge.bannerUrl = item["banner"] as? String
                challenge.videoUrl = item["video"] as? String
                challenge.videoThumbnailUrl = item["video_thumbnail"] as? String
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
                
                // add the challenge to the active list, if necessary
                guard let _ = challenge.endDate
                    else { continue }
                
                challenge.active = Int(date) < challenge.endDate!
                if (challenge.active!) {
                    // this challenge is not expired
                    self._activeChallenges!.append(challenge)
                }
            }
            
            let myGroup = DispatchGroup()
            
            // update likes
            myGroup.enter()
            self.updateLikes() {
                myGroup.leave()
            }
            
            // update submissions
            myGroup.enter()
            self.updateSubmissions() {
                myGroup.leave()
            }
            
            myGroup.notify(queue: DispatchQueue.main) {
                self.delegate?.databaseDidFinishLoading(self)
            }
        })
    }
    
    func updateSubmissions(_ complete: (() -> Void)?) {
        self.firebaseRef?.child("users/\(FIRAuth.auth()!.currentUser!.uid)/submissions").observeSingleEvent(of: .value, with: { (snapshot) in
            self._submissions = []
            self._expiredSubmissions = []
            self._activeSubmissions = []
            
            let date = Date().timeIntervalSince1970
            
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

                guard let challenge = self.getChallenge(submission.challenge_id!)
                    else { continue }
                
                // set the submission active flag
                submission.active = (Int(date) < challenge.endDate!)
                
                if (submission.active!) {
                    self._activeSubmissions?.append(submission)
                } else {
                    self._expiredSubmissions?.append(submission)
                }
                
            }
            
            self.updateAllSubmissionStats() {
                complete?()
            }
        })
    }
    
    func updateLikes(_ complete: (() -> Void)?) {
        // get likes ref
        let userLikesRef = self.firebaseRef?.child("users/\(FIRAuth.auth()!.currentUser!.uid)/likes")
        
        // load user likes
        userLikesRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            print("Retrieved likes")
            if (snapshot.hasChildren()) {
                self._likes = snapshot.value as! [String]
                self.delegate?.databaseDidFinishLoading(self)
            }
            complete?()
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
    func getChallenges(onlyActive: Bool) -> [RZChallenge]? {
    
        // return only currently active challenges
        if (onlyActive) {
            return _activeChallenges
        }
        
        // return all challenges
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
    
    enum RZSubmissionFilter {
        case all, active, expired
    }
    func getSubmissions(filter: RZSubmissionFilter) -> [RZSubmission]?
    {
        switch filter {
            case .all:
                return self._submissions
            case .active:
                return self._activeSubmissions
            case .expired:
                return self._expiredSubmissions
        }
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
    
                    // need to add shares
                    
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
