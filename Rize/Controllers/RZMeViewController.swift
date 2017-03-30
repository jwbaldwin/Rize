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
        if (RZDatabase.sharedInstance().getSubmissions(filter: .expired)!.count > 0) {
            return 2
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "ACTIVE SUBMISSIONS"
            case 1:
                return "PREVIOUS SUBMISSIONS"
            default:
                return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                let activeCount = (RZDatabase.sharedInstance().getSubmissions(filter: .active)?.count)!
                return (activeCount > 0 ? activeCount : 1)
            case 1:
                return (RZDatabase.sharedInstance().getSubmissions(filter: .expired)?.count)!
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ROW_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? RZSubmissionTableViewCell
        
        let submissions : [RZSubmission]?
        
        switch indexPath.section {
            case 0:
                submissions = RZDatabase.sharedInstance().getSubmissions(filter: .active)
            case 1:
                submissions = RZDatabase.sharedInstance().getSubmissions(filter: .expired)
            default:
                submissions = nil
        }
        
        guard let _ = submissions
            else { return cell! }
        
        if submissions!.count > 0 {
            let challengeId = submissions![indexPath.row].challenge_id
            let submission = RZDatabase.sharedInstance().getSubmission(challengeId!)
            let challenge = RZDatabase.sharedInstance().getChallenge(challengeId!)
            
            cell?.textLabel?.text = "\(challenge!.title!)"
            ImageLoader.setImageViewImage(challenge!.iconUrl!, view: cell!.iconView!, round: true)
            ImageLoader.setImageViewImage(challenge!.bannerUrl!, view: cell!.bannerView!, round: false)
            cell?.accessoryType = .disclosureIndicator
            return cell!
        } else {
            // no submissions
            let noSubmissionsCell = tableView.dequeueReusableCell(withIdentifier: "NoSubmissionsCell")
            return noSubmissionsCell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let submissions : [RZSubmission]?
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        switch indexPath.section {
            case 0:
                submissions = RZDatabase.sharedInstance().getSubmissions(filter: .active)
            case 1:
                submissions = RZDatabase.sharedInstance().getSubmissions(filter: .expired)
            default:
                submissions = nil
        }
        
        guard let _ = submissions
            else { return }
        
        if (submissions!.count > 0) {
            
            let challengeId = submissions![indexPath.row].challenge_id
            
            // create the submission detail controller
            let submissionDetailController = self.storyboard?.instantiateViewController(withIdentifier: "RZSubmissionDetailViewController") as! RZSubmissionDetailViewController
            submissionDetailController.submissionId = challengeId
            
            // Get rid of the back button label
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            
            // display the detail screen
            self.navigationController?.pushViewController(submissionDetailController, animated: true)
        } else {
            // user tapped the no submissions cell
        }
    }

}
