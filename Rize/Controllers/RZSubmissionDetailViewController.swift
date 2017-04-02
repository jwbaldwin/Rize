//
//  RZSubmissionDetailViewController.swift
//  Rize
//
//  Created by Matthew Russell on 12/22/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

class RZSubmissionDetailViewController: UIViewController {

    @IBOutlet var progressView : RZSubmissionProgressCircleView!
    @IBOutlet var likesButton : UIButton!
    @IBOutlet var sharesButton : UIButton!
    @IBOutlet var progressLabel : UILabel!
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
        progressView.lineWidth = 20.0
        progressView.bgStrokeColor = UIColor(white: 1.0, alpha: 0.5)
        progressView.startAngle = -CGFloat(M_PI_2)
        
        // add delete icon
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSubmission))
        self.navigationItem.setRightBarButtonItems([deleteButton], animated: true)
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI()
    {
        // update the circular progress view
        progressView.total = submission!.getChallenge()!.pointsRequired!
        progressView.points[0] = submission!.pointsFromUploads()
        progressView.points[1] = submission!.pointsFromLikes()
        progressView.points[2] = submission!.pointsFromShares()
        progressView.updateProgress(animated: true)
        
        // update the buttons
        likesButton.setTitle("\(submission!.pointsFromLikes())", for: .normal)
        sharesButton.setTitle("\(submission!.pointsFromShares())", for: .normal)
        
        // update the redeem button and progress text
        progressLabel.text = "\(submission!.points!)/\(submission!.getChallenge()!.pointsRequired!)"
        if submission!.points! >= submission!.getChallenge()!.pointsRequired! {
            redeemButton.isEnabled = true
        } else {
            redeemButton.isEnabled = false
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
        progressView.reset(newTotal: 200)
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
