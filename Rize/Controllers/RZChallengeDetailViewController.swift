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

    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Make sure we actually have a challenge to display
        if (self.challenge != nil) {
            // Update the title
            self.title = self.challenge.title.uppercased()
        }
        let favButton = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: self, action: #selector(toggleFavorite))
        if (RZDatabase.sharedInstance().isLiked(self.challenge.id)) {
            favButton.image = UIImage(named: "heart-liked")
        }
        self.navigationItem.setRightBarButtonItems([favButton], animated: true)
        
        // Update the view components for the new challenge
        if (self.imageView != nil)
        {
            // set up the image view as a circle
            self.imageView.contentMode = .scaleAspectFill
            self.imageView.clipsToBounds = true
            ImageLoader.setImageViewImage(self.challenge.imageUrl, view: self.imageView)
        }
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var comps = (calendar as NSCalendar?)?.components(.day, from: Date(), to:             Date(timeIntervalSince1970: Double(challenge.endDate)), options: NSCalendar.Options())
        let days = comps!.day
        comps = (calendar as NSCalendar?)?.components(.hour, from: Date(), to:             Date(timeIntervalSince1970: Double(challenge.endDate)), options: NSCalendar.Options())
        let hours = comps!.hour! - days! * 24
        daysLabel.text = String(format: "%02d", days!)
        timeLabel.text = String(format: "%02d", hours)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // make the image view a circle
        self.imageView.layer.cornerRadius = self.imageView.frame.width / 2
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
