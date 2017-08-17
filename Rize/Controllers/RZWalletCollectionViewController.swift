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
    @IBOutlet var organizeView: UITableView!

    var rewards : [RZReward]?
    var effect : UIVisualEffect!
    var db: FIRDatabaseReference!
    var open = false
    var option = "all"
    /* The height of the non-featured cell */
    let standardHeight: CGFloat = 130
    /* The height of the first visible cell */
    let featuredHeight: CGFloat = 280
    
    @IBOutlet weak var showActive: UIButton!
    @IBOutlet weak var showAll: UIButton!
    @IBOutlet weak var orgBtn: UIBarButtonItem!
    @IBAction func dismissReward(_ sender: Any) {
        animateOut();
    }
    
    @IBAction func emailInputActionTriggered(_ sender: Any) {
        print("GO")
    }
    
    @IBAction func organizeBtn(_ sender: Any) {
        switch(open){
            case true:
                animateOutOrganize()
                break
            case false:
                animateInOrganize()
                break
        }
        open = !open
    }
    
    @IBAction func showAll(_ sender: Any) {
        option = "all"
        print("Active option:", option)
        animateOutOrganize()
        self.collectionView?.reloadData()
        open = false
    }
    @IBAction func showActive(_ sender: Any) {
        option = "active"
        print("Active option:", option)
        animateOutOrganize()
        self.collectionView?.reloadData()
        open = false
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
//        self.collectionView?.contentInset = UIEdgeInsetsMake(-50, 0, 0, 10)
        
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
        rewards = RZDatabase.sharedInstance().getWallet(filter: .all)
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
    
    // MARK: - Table View data source/delegate
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0:
//            return "ACTIVE SUBMISSIONS"
//        case 1:
//            return "PREVIOUS SUBMISSIONS"
//        default:
//            return nil
//        }
//    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as! RZWalletHeader
        let section = indexPath.section
        switch section {
            case 0:
                header.header.text = "Active Rewards"
                return header
            case 1:
                header.header.text = "Used Rewards"
                return header
            default:
                header.header.text = nil
                return header
        }
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if (RZDatabase.sharedInstance().getWallet(filter: .used)!.count > 0) {
            if(option == "all") {
                return 2
            } else {
                return 1
            }
        }
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            let activeCount = (RZDatabase.sharedInstance().getWallet(filter: .active)?.count)!
            return (activeCount > 0 ? activeCount : 1)
        case 1:
            return (RZDatabase.sharedInstance().getWallet(filter: .used)?.count)!

        default:
            return 1
        }
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
            cell!.setImageFromURL(rewards![indexPath.row].icon!)
            cell!.setBackgroundImageFromURL(rewards![indexPath.row].banner!)
            
            //Configure cell's appearance
            cell!.bottomView.layer.cornerRadius = 3
            
            cell!.shareBtn.layer.cornerRadius = 5
            cell!.shareBtn.layer.masksToBounds = false
            cell!.shareBtn.layer.shadowOffset = CGSize(width: -1, height: -1)
            cell!.shareBtn.layer.shadowRadius = 5
            cell!.shareBtn.layer.shadowOpacity = 0.2
            cell!.shareBtn.layer.borderWidth = 0.5
            cell!.shareBtn.layer.borderColor = UIColor.lightGray.cgColor
            
            cell!.showReward.layer.cornerRadius = 5
            cell!.showReward.layer.masksToBounds = false
            cell!.showReward.layer.shadowOffset = CGSize(width: -1, height: -1)
            cell!.showReward.layer.shadowRadius = 5
            cell!.showReward.layer.shadowOpacity = 0.2
            cell!.showReward.layer.borderWidth = 0.5
            cell!.showReward.layer.borderColor = UIColor.lightGray.cgColor
            
            cell!.layer.cornerRadius = 3
            cell!.layer.masksToBounds = false
            cell!.layer.shadowOffset = CGSize(width: -1, height: -1)
            cell!.layer.shadowRadius = 3
            cell!.layer.shadowOpacity = 0.8
            
            cell!.tag = indexPath.row
            return cell!
        } else {
            //no rewards
            let noRewardsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoRewardsCell", for: indexPath)
            return noRewardsCell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = self.collectionView?.cellForItem(at: indexPath) as! RZWalletCollectionViewCell
//        
//        UIView.transition(with: collectionView, duration: 0.6, options: UIViewAnimationOptions.curveEaseIn , animations: {
//            if(cell.frame.height != 280){
//                cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cell.frame.width, height: 280)
//            } else{
//                print(cell.frame.height)
//                cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cell.frame.width, height: 150)
//            }
//        }, completion: { finished in
//            if(finished) {
//            print("Finished")
//            }})
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
        let active = reward.active!
        
        //Cannot send to self
        //And not innactive rewards
        if (receiverId != FIRAuth.auth()!.currentUser!.uid) {
            if(active != "no"){
                let challengeId = reward.challenge_id!
                let tier = reward.tier!
                let title = reward.title!
                let code = reward.code!
                let icon = reward.icon!
                let challengeTitle = reward.challenge_title!
                let banner = reward.banner!
                let active = reward.active!
                
                
                RZDatabase.sharedInstance().shareReward(recieverId: receiverId, challengeId: challengeId, tier: tier, title: title, code: code, icon: icon, challengeTitle: challengeTitle, banner: banner, active: active)
                displaySuccessAlertMessage(messageToDisplay: "Congratulations! Your reward has been sent!")
                loadWalletInfo()
            } else {
                self.displayErrorAlertMessage(messageToDisplay: "You cannot send innactive rewards.")
            }
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
    
    // ==== For Organization
    func animateInOrganize() {
        self.view.addSubview(organizeView)
        
        //Show share elements & hide redeem & pass tag
        setUpOrganizeView()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.organizeView.transform = CGAffineTransform.identity
            self.organizeView.alpha = 1
        })
        
    }
    
    // ==== For Share & Redeem
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
    
    func animateOutOrganize(){
        UIView.animate(withDuration: 0.2, animations: {
            self.organizeView.alpha = 0
        }) { (success:Bool) in
            self.organizeView.removeFromSuperview()
        }
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
    
    func setUpOrganizeView() {
        if option == "all" {
            self.showAll.layer.backgroundColor = RZColors.primary.cgColor
            self.showAll.titleLabel?.textColor = UIColor.white
            
            self.showActive.layer.backgroundColor = UIColor.white.cgColor
            self.showActive.titleLabel?.textColor = RZColors.primary
        } else{
            self.showAll.layer.backgroundColor = UIColor.white.cgColor
            self.showAll.titleLabel?.textColor = RZColors.primary
            
            self.showActive.layer.backgroundColor = RZColors.primary.cgColor
            self.showActive.titleLabel?.textColor = UIColor.white
        }
        
        organizeView.center = CGPoint(x: self.view.frame.width - 75 , y: 100)
        organizeView.layer.borderWidth = 1.25
        organizeView.layer.borderColor = RZColors.primary.cgColor
        organizeView.layer.cornerRadius = 3
        organizeView.layer.masksToBounds = true
        organizeView.layer.shadowOffset = CGSize(width: -1, height: -1)
        organizeView.layer.shadowRadius = 3
        organizeView.layer.shadowOpacity = 0.8
        organizeView.alpha = 0
        
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width - 10, height: self.featuredHeight)
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
