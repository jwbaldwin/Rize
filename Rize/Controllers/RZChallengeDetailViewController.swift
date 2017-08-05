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
import AVKit
import AVFoundation


class RZChallengeDetailViewController: UIViewController, UIScrollViewDelegate, RZCameraViewControllerDelegate {
    var challenge : RZChallenge!
    @IBOutlet var imageView : UIImageView!
    @IBOutlet var daysLabel : UILabel!
    @IBOutlet var timeLabel : UILabel!
    @IBOutlet var rizeButton : UIButton!
    @IBOutlet var bannerImageView : UIImageView!
    @IBOutlet var videoThumbnailView : UIImageView!
    @IBOutlet var giftLabel : UILabel!
    @IBOutlet var giftContainerView : UIView!
    
    // track which poptip we are on
    var popTipCounter = 0;

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
        
        // Setup the right image for the rize button
        if self.challenge.media == "photo" {
            self.rizeButton.setImage(UIImage(named: "rize"), for: .normal)
        } else {
            self.rizeButton.setImage(UIImage(named: "record"), for: .normal)
        }
        
        // disable the rize button if the user has already uploaded a submission
        if (RZDatabase.sharedInstance().getSubmission(self.challenge.id!) != nil) {
            // challenge submission already exists
            self.rizeButton.isEnabled = false
            self.rizeButton.isHidden = false
        } else {
            self.rizeButton.isEnabled = true
            self.rizeButton.isHidden = false
        }
        
        // setup the video content (async)
        if challenge.videoUrl != nil {
            ImageLoader.setImageViewImage(challenge.videoThumbnailUrl!, view: self.videoThumbnailView, round: false)
        }
        
        // setup the gift label
        // NEEDS UPDATING LATER
        self.giftLabel.text = challenge!.tiers[0].title
        
        // setup the gift container
        self.giftContainerView.layer.cornerRadius = 5
        
        // initial clock setup
        updateClock()

        // setup the timer
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /* check to show tips */
        if (RZPoptipHelper.shared().shouldShowTips(forScreen: .ChallengeDetail)) {
            popTipCounter = 0;
            RZPoptipHelper.shared().setDidShowTips(true, forScreen: .ChallengeDetail)
            self.showNextPoptip()
        }
    }
    // check when view will disappear so we can get rid of active pop tips
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // cleanup pop tips
        RZPoptipHelper.shared().dismissAll()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // make the image view a circle
        self.imageView.layer.cornerRadius = self.imageView.frame.width / 2
    }
    
    func updateClock()
    {
        
        let comps = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: challenge.getEndDateObject()!)
        daysLabel.text = String(format: "%d", (comps.day! < 0 ? 0 : comps.day!))
        timeLabel.text = String(format: "%d:%02d:%02d", (comps.hour! < 0 ? 0 : comps.hour!), (comps.minute! < 0 ? 0 : comps.minute!), (comps.second! < 0 ? 0 : comps.second!))
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
    }
    
    @IBAction func openCamera()
    {
        let cameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "cameraViewController") as! RZCameraViewController
        cameraViewController.delegate = self
        cameraViewController.challenge = self.challenge
        self.showDetailViewController(cameraViewController, sender: nil)
    }
    
    @IBAction func challengeFriends()
    {
        let link = "http://rizeapp.com/\(challenge.id!)?from=\(FIRAuth.auth()!.currentUser!.uid)"
        let message = "Will you rize to the challenge? Download Rize from the App Store today!"
        let url = URL(string: link)!
        let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        self.present(activityViewController, animated: true)
    }
    
    @IBAction func showVideo()
    {
        let videoURL = URL(string: challenge.videoUrl!)
        let player = AVPlayer(url: videoURL!)
        let controller = AVPlayerViewController()
        controller.player = player
        self.present(controller, animated: true) {
            player.play()
        }
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
    
    // MARK: - Poptip sequence
    func showNextPoptip()
    {
        /* Note that the frames are offset 60 px vertically. Must have something to do with the scroll view */
        switch popTipCounter {
        case 0:
            /* video tip */
            RZPoptipHelper.shared().showPopTip(text: "Watch the video to learn about the challenge", direction: .up, in: self.view, fromFrame: self.videoThumbnailView.frame.offsetBy(dx: 0, dy: 60)) { self.showNextPoptip() }
        case 1:
            /* time tip */
            RZPoptipHelper.shared().showPopTip(text: "Each challenge is only available for a limited time!", direction: .down, in: self.view, fromFrame: self.timeLabel.frame.offsetBy(dx: 0, dy: 60)) { self.showNextPoptip() }
        case 2:
            /* rize tip */
            RZPoptipHelper.shared().showPopTip(text: "Tap here to Rize to the challenge!", direction: .left, in: self.view, fromFrame: self.rizeButton.frame.offsetBy(dx: 0, dy: 60)) { self.showNextPoptip() }
        default:
            break;
        }
        /* go to next index */
        popTipCounter += 1;
    }
}
