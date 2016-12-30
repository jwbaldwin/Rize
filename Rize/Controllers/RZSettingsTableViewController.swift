//
//  RZSettingsTableViewController.swift
//  Rize
//
//  Created by Matthew Russell on 7/10/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit
import Firebase

class RZSettingsTableViewController: UITableViewController {

    let SIGNOUT_INDEXPATH = IndexPath(row: 0, section: 0)
    @IBOutlet var profileImageView : UIImageView!
    @IBOutlet var nameLabel : UILabel!

    var userId : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // apply the color scheme
        self.view.backgroundColor = RZColors.background
        self.navigationController?.navigationBar.backgroundColor = RZColors.navigationBar
        self.navigationController?.navigationBar.tintColor = RZColors.primary
        self.navigationController?.navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] = RZColors.primary
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Load the user information
        if (FIRAuth.auth()?.currentUser != nil && FIRAuth.auth()?.currentUser!.uid != self.userId)
        {
            self.userId = FIRAuth.auth()?.currentUser!.uid
            self.nameLabel.text = FIRAuth.auth()?.currentUser!.displayName
            self.profileImageView.image = ImageLoader.createRoundImage(UIImage(named: "generic_profile")!)
            self.profileImageView.contentMode = .scaleAspectFit
            self.profileImageView.clipsToBounds = true
            if (FIRAuth.auth()?.currentUser!.photoURL != nil)
            {
                ImageLoader.downloadImageFromURL((FIRAuth.auth()?.currentUser?.photoURL?.absoluteString)!) { (image: UIImage) -> Void in
                    UIView.transition(with: self.profileImageView, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                        self.profileImageView.image = ImageLoader.createRoundImage(image)
                    }, completion: nil)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath == SIGNOUT_INDEXPATH)
        {
            // Logged out. Show the login screen
            try! FIRAuth.auth()!.signOut()
            FBSDKLoginManager().logOut()
            let loginController : RZLoginViewController = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as! RZLoginViewController
            let browseNavController = self.tabBarController?.viewControllers![0] as! UINavigationController
            browseNavController.popToRootViewController(animated: false)
            loginController.delegate = browseNavController.viewControllers[0] as! RZBrowseViewController
            self.present(loginController, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
