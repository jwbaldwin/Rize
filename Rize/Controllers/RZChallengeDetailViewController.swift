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
    @IBOutlet var imageView : UIImageView!
    @IBOutlet var daysLabel : UILabel!
    @IBOutlet var timeLabel : UILabel!
    @IBOutlet var rizeButton : UIButton!
    @IBOutlet var bannerImageView : UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // apply the background color
        self.view.backgroundColor = RZColors.background
                
        // Make sure we actually have a challenge to display
        if (self.challenge != nil) {
            // Update the title
            self.title = self.challenge.title!.uppercased()
        }
        let favButton = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: self, action: #selector(toggleFavorite))
        if (RZDatabase.sharedInstance().isLiked(self.challenge.id!)) {
            favButton.image = UIImage(named: "heart-liked")
        }
        self.navigationItem.setRightBarButtonItems([favButton], animated: true)
        
        // Update the view components for the new challenge
        // set up the image view as a circle
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        ImageLoader.setImageViewImage(self.challenge.iconUrl!, view: self.imageView, round: true)
        
        // set up the banner image view
        self.bannerImageView.contentMode = .scaleAspectFill
        ImageLoader.setImageViewImage(self.challenge.bannerUrl!, view: self.bannerImageView, round: false)
        
        // disable the rize button if the user has already uploaded a submission
        if (RZDatabase.sharedInstance().getSubmission(self.challenge.id!) != nil) {
            // challenge submission already exists
            self.rizeButton.isEnabled = false
            self.rizeButton.isHidden = false
        } else {
            self.rizeButton.isEnabled = true
            self.rizeButton.isHidden = false
        }
        
        // initial clock setup
        updateClock()

        // setup the timer
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // make the image view a circle
        self.imageView.layer.cornerRadius = self.imageView.frame.width / 2
    }
    
    func updateClock()
    {
        let comps = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: Date(timeIntervalSince1970: Double(self.challenge.endDate!)))
        daysLabel.text = String(format: "%d", comps.day!)
        timeLabel.text = String(format: "%d:%02d:%02d", comps.hour!, comps.minute!, comps.second!)
    }
    
    func toggleFavorite()
    {
        if (!RZDatabase.sharedInstance().isLiked(self.challenge.id!)) {
            RZDatabase.sharedInstance().putLike(self.challenge.id!)
        } else {
            RZDatabase.sharedInstance().removeLike(self.challenge.id!)
        }
        RZDatabase.sharedInstance().pushLikes()
        let favButton = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: self, action: #selector(toggleFavorite))
        if (RZDatabase.sharedInstance().isLiked(self.challenge.id!)) {
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
