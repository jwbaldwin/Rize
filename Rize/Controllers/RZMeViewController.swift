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

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (FIRAuth.auth()?.currentUser != nil && FIRAuth.auth()?.currentUser!.uid != self.userId)
        {
            loadUserInfo()
        }
    }
    
    func loadUserInfo()
    {
        if (FIRAuth.auth()?.currentUser != nil)
        {
            self.userId = FIRAuth.auth()?.currentUser!.uid
        }
        self.getLikesForVideo(id: "527797930754581")
        
    }
    
    func getLikesForVideo(id: String)
    {
        let request = FBSDKGraphRequest(graphPath: "\(id)?fields=likes.limit(1).summary(true)", parameters: nil)
        request?.start(completionHandler: { (connection, result, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                print((result as? Dictionary)!["likes"]!)
            }
        })
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = RZDatabase.sharedInstance().submissions()?[indexPath.row].challenge_id
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
