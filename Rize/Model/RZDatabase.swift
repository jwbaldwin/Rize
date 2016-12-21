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
                submission.facebook = ((item["facebook"] as? String) == "true")
                submission.fb_id = item["fb_id"] as? String
                submission.approved = ((item["approved"] as? String) == "true")
                submission.redeemed = ((item["redeemed"] as? String) == "true")
                submission.views = item["views"] as? Int
                submission.likes = item["likes"] as? Int
                submission.shares = item["shares"] as? Int
                submission.points = item["points"] as? Int
                submission.friends = item["friends"] as? Int
                self._submissions?.append(submission)
            }
        })
        
        // load challenge data
        self.firebaseRef?.child("challenges").observe(.value, with: { (snapshot) in
            let snap = snapshot
            self._challenges = []
            for child in snap.children {
                // create the challenge object
                let item = (child as! FIRDataSnapshot).value as! [ String : AnyObject ]
                let challenge = RZChallenge(id: (child as AnyObject).key, title: item["title"] as! String, sponsor: item["sponsor"] as! String, imageUrl: item["image"] as! String, date: item["end_date"] as! Int)
                
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
    
    // MARK: - Submission
    func pushSubmission(_ challengeId: String, submission: [String : String])
    {
        firebaseRef!.child("users/\(FIRAuth.auth()!.currentUser!.uid)/submissions/\(challengeId)").setValue(submission)
    }
    
    func getSubmission(_ challengeId : String) -> RZSubmission?
    {
        print(self._submissions)
        if (self._submissions != nil) {
            for submission in self._submissions!
            {
                if submission.challenge_id == challengeId {
                    return submission
                }
            }
        }
        return nil
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
