//
//  RZBrowseCollectionViewController.swift
//  Rize
//
//  Created by Matthew Russell on 5/25/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation

private let reuseIdentifier = "ChallengeCell"

class RZBrowseViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, CLLocationManagerDelegate, RZDatabaseDelegate {

    @IBOutlet var collectionView: UICollectionView?
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    
    // location storage
    var location : CLLocation?

    // Declare the list of challenge data
    // This will later be loaded from an API endpoint
    var challenges : [RZChallenge] = []
    
    // start location manager
    let locationManager = CLLocationManager()
    
    // MARK: View loading
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(RZChallengeCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // start the activity indicator
        self.activityIndicator?.startAnimating()
        
        locationManager.delegate = self
        
        RZDatabase.sharedInstance().delegate = self
        
        // user should already be logged in
        self.setupData()
        
        // apply the color scheme
        self.view.backgroundColor = RZColors.background
        self.navigationController?.navigationBar.backgroundColor = RZColors.navigationBar
        self.navigationController?.navigationBar.tintColor = RZColors.primary
        self.navigationController?.navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] = RZColors.primary
        self.tabBarController?.tabBar.barTintColor = RZColors.tabBar
        self.tabBarController?.tabBar.backgroundColor = RZColors.tabBarUnselected
        self.tabBarController?.tabBar.tintColor = RZColors.tabBarSelected
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Show Login
    /*
    func showLogin() {
        let loginController = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as! RZLoginViewController
        loginController.delegate = self
        self.present(loginController, animated: true, completion: nil)

    }
    */
    
    // MARK: - FB Login Delegate
    /*
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (error == nil)
        {
            // Authenticate Firebase via Facebook
            self.loginWithCurrentFacebookToken()
        }
        else
        {
            // Error: not logged in
            // Show the login controller
            print(error)
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // do nothing
    }
    
    public func loginWithCurrentFacebookToken() {
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            // Signed in! Awesome!
            if (error == nil) {
                // Dismiss the modal view if we sign in with the other view controller
                self.dismiss(animated: true, completion: nil)
                self.setupData()
            }
        }
        self.tabBarController?.selectedIndex = 0
        self.navigationController?.popToRootViewController(animated: false)
    }
    */
    
    func setupData() {
        RZDatabase.sharedInstance().observe()
    
        // request location data
        if CLLocationManager.authorizationStatus() == .denied {
            let alert = UIAlertController(title: "We Need Your Location", message: "Looks like we can't get your location to show you challenges near you. Please go to Settings to give us permission", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }))
            self.present(alert, animated: true, completion: nil)
        } else if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.locationManager.requestLocation()
        }
        
        // get demographic info
        RZFBGraphRequestHelper.getFBGraphData(endpoint: "me?fields=age_range") { (result, error) in
            // check to make sure we successfully got the age
            guard let ageRange = result?["age_range"] as? [String : AnyObject?]
                else { return }

            guard let _ = ageRange["min"]
                else { return }
            
            guard let _ = ageRange["max"]
                else { return }
            
            let ageRangeString = "\(ageRange["min"]!!)-\(ageRange["max"]!!)"
            RZDatabase.sharedInstance().setDatabaseValue(value: ageRangeString, forKey: "age_range")
        }
    }
    
    func databaseDidUpdate(_ database: RZDatabase) {
        self.activityIndicator?.stopAnimating()
        self.collectionView?.reloadData()
    }
    
    // MARK: - Location Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations[0]
        // reload data to include any new views
        self.collectionView?.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let challenges = RZDatabase.sharedInstance().getChallenges(onlyActive: true, forLocation: self.location)
            else { return 0 }
        
        return challenges.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RZChallengeCollectionViewCell
    
        // Configure the cell
        
        // make sure we have the challenges
        guard let challenges = RZDatabase.sharedInstance().getChallenges(onlyActive: true, forLocation: self.location)
            else { return cell }
        
        let challenge = challenges[(indexPath as NSIndexPath).row]
        cell.setImageFromURL(challenge.bannerUrl!)
        cell.setLiked(RZDatabase.sharedInstance().isLiked(challenge.id!))
        cell.sponsorLabel!.text = challenge.sponsor!.uppercased()
        cell.titleLabel!.text = challenge.title!.uppercased()
        
        return cell
    }

    // MARK: UICollectionViewDelegate


    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */
    

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width - 20, height: self.view.frame.width / 2);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(84.0, 20.0, 20.0, 20.0);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Grab the correct challenge data
        let theChallenge : RZChallenge = RZDatabase.sharedInstance().getChallenges(onlyActive: true, forLocation: self.location)![(indexPath as NSIndexPath).row]
        
        // Create the detail view controller
        let detailViewController : RZChallengeDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "RZChallengeDetailViewController") as! RZChallengeDetailViewController
                
        // Set the challenge for the detail
        detailViewController.challenge = theChallenge
        
        // Get rid of the back button label
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil);
        
        // Push it onto the navigation stack! Let's GO!
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }

}
