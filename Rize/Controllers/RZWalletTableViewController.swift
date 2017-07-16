////
////  RZWalletTableViewController.swift
////  Rize
////
////  Created by James Baldwin on 5/29/17.
////  Copyright © 2017 Rize. All rights reserved.
////
//
//import UIKit
//import Firebase
//import FirebaseDatabase
//
//private let reuseIdentifier = "Cell"
//
//
//class RZWalletTableViewController: UITableViewController, RZDatabaseDelegate, CellInfoDelegate {
//    
//    @IBOutlet var activityIndicator: UIActivityIndicatorView?
//    @IBOutlet var rewardCodeView: UIView!
//    @IBOutlet weak var rewardCode: UILabel!
//    @IBOutlet weak var emailLabel: UILabel!
//    @IBOutlet weak var emailInput: UITextField!
//    @IBOutlet weak var dismissReward: UIButton!
//    @IBOutlet weak var shareReward: UIButton!
//    
//    var rewards : [RZReward]?
//    var effect : UIVisualEffect!
//    var db: FIRDatabaseReference!
//    
//    let ROW_HEIGHT : CGFloat = 150
//    
//    @IBAction func dismissReward(_ sender: Any) {
//        animateOut();
//    }
//    
//    @IBAction func shareReward(_ sender: Any) {
//        let providedEmailAddress = self.emailInput.text!
//        
//        let isEmailAddressValid = isValidEmail(emailStr: providedEmailAddress)
//        
//        if isEmailAddressValid
//        {
//            print("Email address is valid: ",
//                  self.emailInput.text!)
//            
//            db.queryOrdered(byChild: "email")
//                .queryEqual(toValue: providedEmailAddress)
//                .observe(.value, with: { snapshot in
//                    
//                    if let results = snapshot.value as? [String: Any]
//                    {
//                        for user in results {
//                            let cell = sender as! UIButton
//                            let reward = self.rewards![cell.tag]
//                            self.handleSendReward(user: user, reward: reward)
//                        }
//                    } else {
//                        print("USER NOT FOUND")
//                        self.displayAlertMessage(messageToDisplay: "User was not found :(")
//                    }
//                })
//            
//        } else {
//            print("Email address is not valid: ", self.emailInput.text!)
//            displayAlertMessage(messageToDisplay: "Email address is not valid :(")
//        }
//    }
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.db = FIRDatabase.database().reference().child("users")
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//        
//        // Do any additional setup after loading the view.
//        self.activityIndicator?.startAnimating()
//        
//        // apply the color scheme
//        self.view.backgroundColor = RZColors.background
//        self.navigationController?.navigationBar.backgroundColor = RZColors.navigationBar
//        self.navigationController?.navigationBar.tintColor = RZColors.primary
//        self.navigationController?.navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] = RZColors.primary
//        
//        //Set up databse
//        RZDatabase.sharedInstance().delegate = self
//        
//        //Set UIView corner radius and remove separator for table cells
//        tableView.separatorStyle = .singleLine
//        self.rewardCodeView.layer.cornerRadius = 5
//        loadWalletInfo()
//
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        loadWalletInfo()
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    func loadWalletInfo(){
//        rewards = RZDatabase.sharedInstance().getWallet()
//        self.tableView?.reloadData()
//    }
//    
//    // MARK: - Table view data source
//    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if rewards!.count == 0 {
//            return 1
//        }
//        return rewards!.count
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return ROW_HEIGHT
//    }
//    
//    //---- Set up each cell ----//
//     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//     let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? RZWalletTableViewCell
//        
//        //set delegate to self
//        cell?.delegate = self
//        
//        //remove blur and add spacing
//        effect = cell?.visualEffectView.effect
//        cell!.visualEffectView.effect = nil
//        
//        if rewards!.count != 0 {
//            
//            //get reward information
//            cell!.rewardName.text = rewards![indexPath.row].title
//            cell!.companyLocation.text = rewards![indexPath.row].challenge_title
//            cell!.expDate.text = "None"
//            cell!.topView.backgroundColor = RZColors.cardColorArray[indexPath.row]
//            cell!.accessoryView?.backgroundColor = RZColors.cardColorArray[indexPath.row]
//            cell!.tag = indexPath.row
//            
//            
//            return cell!
//        } else {
//            //no rewards
//            let noRewardsCell = tableView.dequeueReusableCell(withIdentifier: "NoRewardsCell", for: indexPath)
//            return noRewardsCell
//        }
//     }
//    
//    func getCodeForCell(_ cell : UITableViewCell) {
//        rewardCode!.text = rewards![cell.tag].code
//    }
//    
//    func databaseDidUpdate(_ database: RZDatabase) {
//        self.activityIndicator?.stopAnimating()
//        self.tableView?.reloadData()
//    }
//    
////----------- Functions for emails and sharing -------------//
//    //VALIDATE
//    func isValidEmail(emailStr : String) -> Bool {
//        var returnValue = true
//        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
//        
//        do {
//            let regex = try NSRegularExpression(pattern: emailRegEx)
//            let nsString = emailStr as NSString
//            let results = regex.matches(in: emailStr, range: NSRange(location: 0, length: nsString.length))
//            
//            if results.count == 0
//            {
//                returnValue = false
//            }
//            
//        } catch let error as NSError {
//            print("invalid regex: \(error.localizedDescription)")
//            returnValue = false
//        }
//        
//        return  returnValue
//    }
//    
//    //SEND
//    func handleSendReward(user : (key: String, Any), reward: RZReward){
//        let receiverId = user.key
//        
//        //Cannot send to self
//        if (receiverId != FIRAuth.auth()!.currentUser!.uid) {
//            let challengeId = reward.challenge_id!
//            let tier = reward.tier!
//            let title = reward.title!
//            let code = reward.code!
//            let icon = reward.icon!
//            let challengeTitle = reward.challenge_title!
//        
//        
//            RZDatabase.sharedInstance().shareReward(recieverId: receiverId, challengeId: challengeId, tier: tier, title: title, code: code, icon: icon, challengeTitle: challengeTitle)
//        } else {
//            self.displayAlertMessage(messageToDisplay: "Sharing is caring! Try sending it to someone who is not yourself.")
//        }
//        
//    }
//    
//    //ERROR
//    func displayAlertMessage(messageToDisplay: String)
//    {
//        let alertController = UIAlertController(title: "Alert", message: messageToDisplay, preferredStyle: .alert)
//        
//        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
//            
//            // Code in this block will trigger when OK button tapped.
//            print("Ok button tapped");
//            
//        }
//        
//        alertController.addAction(OKAction)
//        
//        self.present(alertController, animated: true, completion:nil)
//    }
//    
//    
////----------- Animations for reward code view -------------//
//    // ==== For Redeeming
//    func animateInRedeem(_ : UITableViewCell) {
//        self.view.addSubview(rewardCodeView)
//        
//        //Hide share elements & show redeem
//        setUpRewardView()
//        showRedeemElements()
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? RZWalletTableViewCell
//        UIView.animate(withDuration: 0.4, animations: {
//            cell!.visualEffectView.effect = self.effect
//            self.rewardCodeView.alpha = 1
//            self.rewardCodeView.transform = CGAffineTransform.identity
//        })
//    }
//    
//    func animateOut() {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? RZWalletTableViewCell
//        UIView.animate(withDuration: 0.3, animations: {
//            self.rewardCodeView.transform = CGAffineTransform.init(scaleX: 1.3, y:1.3)
//            self.rewardCodeView.alpha = 0
//            cell!.visualEffectView.effect = self.effect
//        }) { (success:Bool) in
//            self.rewardCodeView.removeFromSuperview()
//        }
//        
//        //Clear email input
//        self.emailInput.text = ""
//
//    }
//    
//    // ==== For Sharing
//    func animateInShare(_ cell: UITableViewCell) {
//        self.view.addSubview(rewardCodeView)
//        
//        //Show share elements & hide redeem & pass tag
//        setUpRewardView()
//        showShareElements()
//        self.shareReward.tag = cell.tag
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? RZWalletTableViewCell
//        UIView.animate(withDuration: 0.4, animations: {
//            cell!.visualEffectView.effect = self.effect
//            self.rewardCodeView.alpha = 1
//            self.rewardCodeView.transform = CGAffineTransform.identity
//        })
//
//    }
//    
//    func showRedeemElements() {
//        //Hide share elements & show redeem
//        self.shareReward.isHidden = true
//        self.emailInput.isHidden = true
//        self.emailLabel.isHidden = true
//        self.rewardCode.isHidden = false
//    }
//    
//    func showShareElements(){
//        //Hide share elements & show redeem
//        self.shareReward.isHidden = false
//        self.emailInput.isHidden = false
//        self.emailLabel.isHidden = false
//        self.rewardCode.isHidden = true
//    }
//    
//    // Setup animation for reward
//    func setUpRewardView() {
//        rewardCodeView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 50)
//        
//        rewardCodeView.transform = CGAffineTransform.init(scaleX:1.3, y: 1.3)
//        rewardCodeView.backgroundColor = UIColor.black
//        rewardCodeView.alpha = 0
//    }
//
//    /*
//    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
//    */
//
//    /*
//    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }    
//    }
//    */
//
//    /*
//    // Override to support rearranging the table view.
//    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
//
//    }
//    */
//
//    /*
//    // Override to support conditional rearranging of the table view.
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the item to be re-orderable.
//        return true
//    }
//    */
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
