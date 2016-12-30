//
//  RZMeViewController.swift
//  Rize
//
//  Created by Matthew Russell on 7/2/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit
import Firebase

class RZMeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var userId : String?
    @IBOutlet var tableView : UITableView?
    
    let ROW_HEIGHT : CGFloat = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // apply the color scheme
        self.view.backgroundColor = RZColors.background
        self.navigationController?.navigationBar.backgroundColor = RZColors.navigationBar
        self.navigationController?.navigationBar.tintColor = RZColors.primary
        self.navigationController?.navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] = RZColors.primary
        
        self.tableView?.backgroundColor = RZColors.background
        
        loadUserInfo();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserInfo()
    }
    
    func loadUserInfo()
    {
        RZDatabase.sharedInstance().updateAllSubmissionStats() {
            // reload the table
            self.tableView?.reloadData()
            
            // sync back with the database
            RZDatabase.sharedInstance().syncAllSubmissions()
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
    
    // MARK: - Table View data source/delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (RZDatabase.sharedInstance().submissions()?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ROW_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? RZSubmissionTableViewCell
        let challengeId = RZDatabase.sharedInstance().submissions()?[indexPath.row].challenge_id
        let submission = RZDatabase.sharedInstance().getSubmission(challengeId!)
        let challenge = RZDatabase.sharedInstance().getChallenge(challengeId!)
        
        cell?.textLabel?.text = "\(challenge!.title!) (\(Int(submission!.progress() * 100))%)"
        cell?.progressView?.setProgress(submission!.progress(), animated: true)
        ImageLoader.setImageViewImage(challenge!.iconUrl!, view: cell!.iconView!, round: true)
        ImageLoader.setImageViewImage(challenge!.bannerUrl!, view: cell!.bannerView!, round: false)
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let challengeId = RZDatabase.sharedInstance().submissions()?[indexPath.row].challenge_id
        
        // create the submission detail controller
        let submissionDetailController = self.storyboard?.instantiateViewController(withIdentifier: "RZSubmissionDetailViewController") as! RZSubmissionDetailViewController
        submissionDetailController.submissionId = challengeId
        
        // Get rid of the back button label
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // display the detail screen
        self.navigationController?.pushViewController(submissionDetailController, animated: true)

        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
