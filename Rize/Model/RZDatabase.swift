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
    fileprivate var _location : String?                 // this user's location
    fileprivate var _challenges : [RZChallenge]?        // challenges
    var delegate : RZDatabaseDelegate?
    
    // track load status
    fileprivate var _likesLoaded = false
    fileprivate var _challengesLoaded = false

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
    
    fileprivate func _checkIfDataLoaded() {
        if (self._likesLoaded && self._challengesLoaded)
        {
            self.delegate?.databaseDidFinishLoading(self)
        }
    }
    
    func refresh() {
        // reset loaded flags
        self._challengesLoaded = false
        self._likesLoaded = false
        
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
                self._challengesLoaded = true
                self._checkIfDataLoaded()
            }
        })
        
        if (FIRAuth.auth()!.currentUser != nil)
        {
            // load user likes
            self.firebaseRef?.child("users/\(FIRAuth.auth()!.currentUser!.uid)/likes").observeSingleEvent(of: .value, with: { (snapshot) in
                if (snapshot.hasChildren()) {
                    self._likes = snapshot.value as! [String]
                }
                self._likesLoaded = true
                self._checkIfDataLoaded()
            })
        }
    }
    
    func pushLikes() {
        // sync likes
        firebaseRef!.child("users/\(FIRAuth.auth()!.currentUser!.uid)/likes").setValue(self._likes)
    }
    
    func pushLocation() {
        // sync location
        firebaseRef!.child("users/\(FIRAuth.auth()!.currentUser!.uid)/location").setValue(self._location)
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
    
    // MARK: - Location
    func location() -> String? {
        return _location
    }
    
    func putLocation(_ loc: String?) {
        _location = loc
    }
    
    // MARK: - Challenges
    func challenges() -> [RZChallenge]? {
        return _challenges
    }
    
}
