//
//  RZSubmissionDetailViewController.swift
//  Rize
//
//  Created by Matthew Russell on 12/22/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

class RZSubmissionDetailViewController: UIViewController {

    @IBOutlet var progressView : RZCircularProgressView!
    @IBOutlet var pointsLabel : UILabel!
    
    @IBOutlet var likesLabel : UILabel!
    @IBOutlet var likesPoints : UILabel!
    @IBOutlet var likesProgress : UIProgressView!
    
    @IBOutlet var sharesLabel : UILabel!
    @IBOutlet var sharesPoints : UILabel!
    @IBOutlet var sharesProgress : UIProgressView!
    
    @IBOutlet var fbLabel : UILabel!
    @IBOutlet var fbPoints : UILabel!
    
    @IBOutlet var backgroundImageView : UIImageView!
    
    @IBOutlet var redeemButton : UIButton!

    var submissionId : String?
    var submission : RZSubmission?
    var challenge : RZChallenge?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // apply the background color
        self.view.backgroundColor = RZColors.background
        
        challenge = RZDatabase.sharedInstance().getChallenge(submissionId!)!
        let challengeTitle = challenge!.title
        
        self.title = challengeTitle!.uppercased()
        
        // get the challenge submission information
        submission = RZDatabase.sharedInstance().getSubmission(submissionId!)

        // setup the circular progress view
        progressView.lineWidth = 10.0
        progressView.strokeColor = RZColors.primary
        progressView.bgStrokeColor = UIColor(white: 1.0, alpha: 0.5)
        progressView.startAngle = -CGFloat(M_PI_2)
        progressView.setProgress(0.0, animated: false)
        progressView.layer.opacity = 0.75
        
        pointsLabel.text = String(format: "%d", 75)
        
        // add delete icon
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSubmission))
        self.navigationItem.setRightBarButtonItems([deleteButton], animated: true)
        
        // setup the redeem button
        redeemButton.setTitle(challenge!.rewardTitle!.uppercased(), for: .normal)
        redeemButton.layer.borderColor = RZColors.primary.cgColor
        redeemButton.layer.cornerRadius = 4.0
        redeemButton.layer.borderWidth = 1.0
        redeemButton.layer.backgroundColor = RZColors.primary.cgColor
        redeemButton.setTitleColor(RZColors.background, for: .normal)
        
        // load the background image
        ImageLoader.setImageViewImage(challenge!.bannerUrl!, view: self.backgroundImageView, round: false)
        
        updateUI()
        
        // check for potential problems
        if (!self.submission!.facebook! && self.submission!.fb_id != nil)
        {
            // not on facebook, but fb_id is given. Maybe the user deleted their video
            let alert = UIAlertController(title: "Couldn't Find Facebook Content", message: "We can't find your video on Facebook! Should we delete your submission?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                // delete the submission
                RZDatabase.sharedInstance().deleteSubmission(self.submissionId!)
                self.navigationController?.popToRootViewController(animated: true)
            }))
            
            self.present(alert, animated: true,completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI()
    {
        // update the facebook labels
        if (self.submission!.facebook!) {
            self.fbLabel.isEnabled = true
            self.fbPoints.isEnabled = true
        } else {
            self.fbLabel.isEnabled = false
            self.fbPoints.isEnabled = false
        }
        
        // update the total points
        self.pointsLabel.text = String(format: "%d", self.submission!.points!)
        
        // update the progress circle
        self.progressView.setProgress(CGFloat(self.submission!.progress()), animated: true)
        
        // update the likes
        self.likesLabel.text = String(format: "LIKES (%d/%d)", self.submission!.likes!, self.challenge!.likesLimit!)
        self.likesProgress.setProgress(self.submission!.likesProgress(), animated: true)
        self.likesPoints.text = String(format: "+%d", self.submission!.pointsFromLikes())
        
        // update the shares
        self.sharesLabel.text = String(format: "SHARES (%d/%d)", self.submission!.shares!, self.challenge!.sharesLimit!)
        self.sharesProgress.setProgress(self.submission!.sharesProgress(), animated: true)
        self.sharesPoints.text = String(format: "+%d", self.submission!.pointsFromShares())
        
        // set the redeem button up
        if (self.submission!.complete!) {
            self.redeemButton.isEnabled = true
            self.redeemButton.layer.opacity = 1
        } else {
            self.redeemButton.isEnabled = false
            self.redeemButton.layer.opacity = 0.25
        }
    }
    
    func deleteSubmission()
    {
        let actionSheet = UIAlertController(title: "Delete Submission", message: "This action cannot be undone", preferredStyle: .actionSheet)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { action in
            // delete the submission
            RZDatabase.sharedInstance().deleteSubmission(self.submissionId!)
            self.navigationController?.popToRootViewController(animated: true)
        }
        actionSheet.addAction(cancelButton)
        actionSheet.addAction(deleteButton)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func redeem() {
        let redeemController = self.storyboard?.instantiateViewController(withIdentifier: "RedeemViewController") as! RZRedeemViewController
        redeemController.challengeId = challenge!.id!
        redeemController.submissionId = submissionId
        // Get rid of the back button label
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil);
        self.navigationController?.pushViewController(redeemController, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
