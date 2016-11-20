//
//  RZMeViewController.swift
//  Rize
//
//  Created by Matthew Russell on 7/2/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit
import Firebase

class RZMeViewController: UIViewController {
    @IBOutlet var profileImageView : UIImageView!
    @IBOutlet var activityIndicator : UIActivityIndicatorView!
    @IBOutlet var headerView : UIView!
    @IBOutlet var profileViewHeightConstraint : NSLayoutConstraint!
    var userId : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerView.translatesAutoresizingMaskIntoConstraints = true
        self.profileImageView.translatesAutoresizingMaskIntoConstraints = true
        
        let profileImageWidth = self.view.frame.width*0.25
        self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: profileImageWidth + 134)
        self.profileImageView.frame = CGRect(x: self.view.frame.width/2 - profileImageWidth/2, y: 84, width: profileImageWidth, height: profileImageWidth)
        
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
        self.profileImageView.clipsToBounds = true
        
        loadUserInfo();

    }
    override func viewWillAppear(_ animated: Bool) {
        if (FIRAuth.auth()?.currentUser != nil && FIRAuth.auth()?.currentUser!.uid != self.userId)
        {
            loadUserInfo()
        }
    }
    
    func loadUserInfo()
    {
        if (FIRAuth.auth()?.currentUser != nil)
        {
            self.userId = FIRAuth.auth()?.currentUser!.uid
            if (FIRAuth.auth()?.currentUser?.photoURL != nil)
            {
                ImageLoader.downloadImageFromURL((FIRAuth.auth()?.currentUser?.photoURL?.absoluteString)!) { (image: UIImage) -> Void in
                    self.activityIndicator.stopAnimating()
                    UIView.transition(with: self.profileImageView, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                        self.profileImageView.image = image
                    }, completion: nil)
                }
            }
        }
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
