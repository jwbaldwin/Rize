//
//  RZRedeemViewController.swift
//  Rize
//
//  Created by Matthew Russell on 2/26/17.
//  Copyright © 2017 Rize. All rights reserved.
//

import UIKit
import Firebase

class RZRedeemViewController: UIViewController {

    var challengeId : String?
    var submissionId : String?
    
    @IBOutlet var congratsLabel : UILabel!
    @IBOutlet var messageLabel : UILabel!
    @IBOutlet var codeButton : UIButton!
    @IBOutlet var imageView : UIImageView!
    
    var linkUrl : String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if challengeId != nil {
            let challenge = RZDatabase.sharedInstance().getChallenge(challengeId!)
            congratsLabel.text = "Nice job!"
            messageLabel.text = challenge!.rewardMessage
            codeButton.setTitle("YOUR_CODE", for: .normal)
            linkUrl = challenge!.rewardLink
            ImageLoader.setImageViewImage(challenge!.iconUrl!, view: imageView, round: true)
            
            let submission = RZDatabase.sharedInstance().getSubmission(submissionId!)
            if !submission!.redeemed! {
                submission?.redeemed = true
                RZDatabase.sharedInstance().syncSubmission(submissionId!)
                // grab the redeem code
            } else {
                // display the previously redeemed code
            }
        }
        
        // set the colors
        self.view.backgroundColor = RZColors.background
        self.congratsLabel.textColor = RZColors.primary
        self.codeButton.setTitleColor(RZColors.primary, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openLink()
    {
        guard let _ = linkUrl
            else { return }
        UIApplication.shared.openURL(URL(string: linkUrl!)!)
        UIPasteboard.general.string = codeButton.title(for: .normal)
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
