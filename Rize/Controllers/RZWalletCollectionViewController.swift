//
//  RZWalletCollectionViewController.swift
//  Rize
//
//  Created by James Baldwin on 4/3/17.
//  Copyright © 2017 Rize. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SCLAlertView

private let reuseIdentifier = "Cell"

class RZWalletCollectionViewController: UICollectionViewController, RZDatabaseDelegate, CellInfoDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var rewardCodeView: UIView!
    @IBOutlet weak var rewardCode: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var dismissReward: UIButton!
    @IBOutlet weak var shareReward: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    var rewards : [RZReward]?
    var effect : UIVisualEffect!
    var db: FIRDatabaseReference!
    
    @IBAction func dismissReward(_ sender: Any) {
        animateOut();
    }
    
    @IBAction func emailInputActionTriggered(_ sender: Any) {
        print("GO")
    }
    
    @IBAction func shareReward(_ sender: Any) {
        let providedEmailAddress = self.emailInput.text!
        
        let isEmailAddressValid = isValidEmail(emailStr: providedEmailAddress)
        
        if isEmailAddressValid
        {
            print("Email address is valid: ",
                  self.emailInput.text!)
            
            db.queryOrdered(byChild: "email")
                .queryEqual(toValue: providedEmailAddress)
                .observe(.value, with: { snapshot in
                    
                    if let results = snapshot.value as? [String: Any]
                    {
                        for user in results {
                            let cell = sender as! UIButton
                            let reward = self.rewards![cell.tag]
                            self.handleSendReward(user: user, reward: reward)
                        }
                    } else {
                        print("USER NOT FOUND")
                        self.displayErrorAlertMessage(messageToDisplay: "User was not found :(")
                    }
                })
            
        } else {
            print("Email address is not valid: ", self.emailInput.text!)
            displayErrorAlertMessage(messageToDisplay: "Email address is not valid :(")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.db = FIRDatabase.database().reference().child("users")
        
        // Do any additional setup after loading the view.
        self.activityIndicator?.startAnimating()
        
        // apply the color scheme
        self.view.backgroundColor = RZColors.background
        self.navigationController?.navigationBar.backgroundColor = RZColors.navigationBar
        self.navigationController?.navigationBar.tintColor = RZColors.primary
        self.navigationController?.navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] = RZColors.primary
        
        //Set up
        RZDatabase.sharedInstance().delegate = self
        
        loadWalletInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWalletInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadWalletInfo(){
        rewards = RZDatabase.sharedInstance().getWallet()
        self.collectionView?.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Count num of codes in coredata/db
        if rewards!.count == 0{
            return 1
        }
        return rewards!.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? RZWalletCollectionViewCell
        
        //set delegate to self
        cell?.delegate = self
        
        
        if rewards!.count != 0 {
            //Configure cell's attributes
            cell!.rewardName.text = rewards![indexPath.row].title
            cell!.companyLocation.text = rewards![indexPath.row].challenge_title!.lowercased()
            cell!.expDate.text = "No Expiration"
            cell!.tier.text = rewards![indexPath.row].tier
            cell!.topView.backgroundColor = RZColors.cardColorArray[indexPath.row]
            cell!.setImageFromURL(rewards![indexPath.row].icon!)
            cell!.shareBtn.layer.opacity = 0
            cell!.showReward.layer.opacity = 0
            
            //Configure cell's appearance
            cell!.layer.cornerRadius = 3
            cell!.layer.masksToBounds = false
            cell!.layer.shadowOffset = CGSize(width: -1, height: -1)
            cell!.layer.shadowRadius = 3
            cell!.layer.shadowOpacity = 0.5
            
            cell!.tag = indexPath.row
            return cell!
        } else {
            //no rewards
            let noRewardsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoRewardsCell", for: indexPath)
            return noRewardsCell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView?.cellForItem(at: indexPath) as! RZWalletCollectionViewCell
        
        UIView.animate(withDuration: 0.6, animations: {
            if cell.shareBtn.layer.opacity == 0 {
                cell.shareBtn.layer.opacity = 1
                cell.showReward.layer.opacity = 1
            } else {
                cell.shareBtn.layer.opacity = 0
                cell.showReward.layer.opacity = 0
            }
        })
    }
    
    func getCodeForCell(_ cell : UICollectionViewCell) {
        rewardCode!.text = rewards![cell.tag].code
    }
    
    func databaseDidUpdate(_ database: RZDatabase) {
        self.activityIndicator?.stopAnimating()
        self.collectionView?.reloadData()
    }
    
    
//----------- Functions for emails and sharing -------------//
    //VALIDATE
    func isValidEmail(emailStr : String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailStr as NSString
            let results = regex.matches(in: emailStr, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    //SEND
    func handleSendReward(user : (key: String, Any), reward: RZReward){
        let receiverId = user.key
        
        //Cannot send to self
        if (receiverId != FIRAuth.auth()!.currentUser!.uid) {
            let challengeId = reward.challenge_id!
            let tier = reward.tier!
            let title = reward.title!
            let code = reward.code!
            let icon = reward.icon!
            let challengeTitle = reward.challenge_title!
            
            
            RZDatabase.sharedInstance().shareReward(recieverId: receiverId, challengeId: challengeId, tier: tier, title: title, code: code, icon: icon, challengeTitle: challengeTitle)
            displaySuccessAlertMessage(messageToDisplay: "Congratulations! Your reward has been sent!")
            loadWalletInfo()
        } else {
            self.displayErrorAlertMessage(messageToDisplay: "Sharing is caring! Try sending it to someone who is not yourself.")
        }
        
    }
    
    //ERROR
    func displayErrorAlertMessage(messageToDisplay: String)
    {
        SCLAlertView().showError("Ooops", subTitle: messageToDisplay)
        self.emailInput.text = ""
    }
    
    //SUCCESS
    func displaySuccessAlertMessage(messageToDisplay: String)
    {
        let alert = SCLAlertView().showSuccess("Success!", subTitle: messageToDisplay)
        alert.setDismissBlock {
            self.animateOut()
        }
        self.emailInput.text = ""
    }
    
    
//----------- Animations for reward code view -------------//
    // ==== For Redeeming
    func animateInRedeem(_ cellSender: UICollectionViewCell) {
        self.view.addSubview(visualEffectView)
        self.view.addSubview(rewardCodeView)
        
        //Hide share elements & show redeem
        setUpRewardView(cellSender)
        showRedeemElements()
        
        UIView.animate(withDuration: 0.4, animations: {
            self.visualEffectView.transform = CGAffineTransform.identity
            self.rewardCodeView.transform = CGAffineTransform.identity
            self.visualEffectView.alpha = 1
            self.rewardCodeView.alpha = 1
        })
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.rewardCodeView.transform = CGAffineTransform.init(scaleX: 1.3, y:1.3)
            self.rewardCodeView.alpha = 0
            self.visualEffectView.transform = CGAffineTransform.init(scaleX: 1.3, y:1.3)
            self.visualEffectView.alpha = 0
        }) { (success:Bool) in
            self.visualEffectView.removeFromSuperview()
            self.rewardCodeView.removeFromSuperview()
        }
        //Clear email input
        self.emailInput.text = ""
        
    }
    
    // ==== For Sharing
    func animateInShare(_ cellSender: UICollectionViewCell) {
        self.view.addSubview(visualEffectView)
        self.view.addSubview(rewardCodeView)
        
        //Show share elements & hide redeem & pass tag
        setUpRewardView(cellSender)
        showShareElements()
        self.shareReward.tag = cellSender.tag
        
        UIView.animate(withDuration: 0.4, animations: {
            self.visualEffectView.transform = CGAffineTransform.identity
            self.rewardCodeView.transform = CGAffineTransform.identity
            self.visualEffectView.alpha = 1
            self.rewardCodeView.alpha = 1
        })
        
    }
    
    func showRedeemElements() {
        //Hide share elements & show redeem
        self.shareReward.isHidden = true
        self.emailInput.isHidden = true
        self.emailLabel.isHidden = true
        self.rewardCode.isHidden = false
        
        rewardCodeView.frame.size.height = 145
        dismissReward.center.y = rewardCode.frame.size.height + 40
        rewardCodeView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
    }
    
    func showShareElements(){
        //Hide share elements & show redeem
        self.shareReward.isHidden = false
        self.emailInput.isHidden = false
        self.emailLabel.isHidden = false
        self.rewardCode.isHidden = true
        
        rewardCodeView.frame.size.height = 230
        shareReward.center.y = rewardCode.frame.size.height + 70
        dismissReward.center.y = rewardCode.frame.size.height + 105
        rewardCodeView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
    }
    
    // Setup animation for reward
    func setUpRewardView(_ cell: UICollectionViewCell) {
        visualEffectView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
        rewardCodeView.transform = CGAffineTransform.init(scaleX:1.3, y: 1.3)
        visualEffectView.transform = CGAffineTransform.init(scaleX:1.3, y: 1.3)
        rewardCodeView.alpha = 0
        visualEffectView.alpha = 0
        
        self.shareReward.layer.cornerRadius = 3
        self.dismissReward.layer.cornerRadius = 3
        
        rewardCodeView.layer.cornerRadius = 5
        rewardCodeView.layer.masksToBounds = false
        rewardCodeView.layer.shadowOffset = CGSize(width: -1, height: 1)
        rewardCodeView.layer.shadowRadius = 5
        rewardCodeView.layer.shadowOpacity = 0.5
        visualEffectView.bounds = self.view.bounds
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        
        let width  = self.view.frame.size.width;
        let height = CGFloat(175);
        // in case you you want the cell to be 40% of your controllers view
        return CGSize(width: width*0.95, height: height)
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
