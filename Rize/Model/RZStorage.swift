//
//  RZStorage.swift
//  Rize
//
//  Created by Matthew Russell on 9/7/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import FirebaseStorage
import Firebase

/*
protocol RZStorageDelegate: class {
}
*/

class RZStorage: NSObject {

    fileprivate static var instance : RZStorage?       // shared instance
    
    fileprivate var firebaseRef : FIRStorageReference? // Firebase storage reference
    //var delegate : RZStorageDelegate?

    static func sharedInstance() -> RZStorage {
        // check if the instance needs to be created
        if (instance == nil)
        {
            instance = RZStorage()
        }
        return instance!
    }
    
    fileprivate override init() {
        // setup the shared instance
        // grab the database reference
        firebaseRef = FIRStorage.storage().reference()
    }
    
    func uploadVideo(_ file: URL, forChallenge challenge: String) {
        // upload the video from the local URL
        // first navigate to the folder for this challenge
        let uploadPath = String(format: "%@/%@-%d.mp4", challenge, (FIRAuth.auth()?.currentUser?.uid)!, Date(timeIntervalSinceNow: 0).timeIntervalSince1970)
        let videoRef = firebaseRef?.child(uploadPath)
        
        let uploadTask = videoRef?.putFile(file, metadata: nil) { metadata, error in
            if (error != nil) {
                // error occured
                print(error)
            } else {
                let downloadURL = metadata!.downloadURL()
                print(downloadURL)
            }
        }
    }
    
}
