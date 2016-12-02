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
    @IBOutlet var profileViewHeightConstraint : NSLayoutConstraint!
    var userId : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
