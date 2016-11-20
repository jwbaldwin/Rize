//
//  RZChallengeDetailViewController.swift
//  Rize
//
//  Created by Matthew Russell on 6/2/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class RZChallengeDetailViewController: UIViewController, UIScrollViewDelegate, RZCameraViewControllerDelegate {
    var challenge : RZChallenge!
    @IBOutlet var headerView : RZChallengeHeaderView!
    @IBOutlet var headerHeightConstraint : NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Make sure we actually have a challenge to display
        if (self.challenge != nil) {
            // Update the title
            self.title = self.challenge.title.uppercased()
            self.headerView.challenge = self.challenge
            self.headerView.navBarHeight = 0
        }
        let favButton = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: self, action: #selector(toggleFavorite))
        if (RZDatabase.sharedInstance().isLiked(self.challenge.id)) {
            favButton.image = UIImage(named: "heart-liked")
        }
        self.navigationItem.setRightBarButtonItems([favButton], animated: true)
        
        // setup the header view
        self.headerView.maxHeight = self.view.frame.height * 0.3;
        self.headerView.minHeight = self.view.frame.height * 0.2;
        self.headerHeightConstraint.constant = self.headerView.maxHeight + self.headerView.navBarHeight;
    }
    
    func toggleFavorite()
    {
        if (!RZDatabase.sharedInstance().isLiked(self.challenge.id)) {
            RZDatabase.sharedInstance().putLike(self.challenge.id)
        } else {
            RZDatabase.sharedInstance().removeLike(self.challenge.id)
        }
        RZDatabase.sharedInstance().pushLikes()
        let favButton = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: self, action: #selector(toggleFavorite))
        if (RZDatabase.sharedInstance().isLiked(self.challenge.id)) {
            favButton.image = UIImage(named: "heart-liked")
        } else {
            favButton.image = UIImage(named: "heart")
        }
        self.navigationItem.rightBarButtonItems![0] = favButton;
        
        RZDatabase.sharedInstance().refresh()
    }
    
    @IBAction func openCamera()
    {
        let cameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "cameraViewController") as! RZCameraViewController
        cameraViewController.delegate = self
        cameraViewController.challenge = self.challenge
        self.showDetailViewController(cameraViewController, sender: nil)
    }
    
    func cameraViewDidFinish(_ sender: RZCameraViewController) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
