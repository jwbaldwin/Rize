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
import AMPopTip

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
    
    // track which poptip we are on
    var popTipCounter = 0
    
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
        
        // disable tab bar until loaded
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /* refresh data on view appear */
        RZDatabase.sharedInstance().refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /* check to show tips */
        if (RZPoptipHelper.shared().shouldShowTips(forScreen: .Browse)) {
            popTipCounter = 0;
            self.showNextPoptip()
            RZPoptipHelper.shared().setDidShowTips(true, forScreen: .Browse)
        }

    }

    // check when view will disappear so we can get rid of active pop tips
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // cleanup pop tips
        RZPoptipHelper.shared().dismissAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupData() {
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
        
    }
    
    func databaseDidUpdate(_ database: RZDatabase) {
        self.activityIndicator?.stopAnimating()
        self.collectionView?.reloadData()
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    func legalDocumentDidChange(_ database: RZDatabase, whichDocument: String) {
        var title = ""
        var message = ""
        if (whichDocument == RZDatabase.TERMS_UPDATED) {
            title = "Terms of Service Updated"
            message = "By using this app you agree to our updated terms of service. Check them out in the Settings page!"
        } else if (whichDocument == RZDatabase.PRIVACY_UPDATED) {
            title = "Privacy Policy Update"
            message = "By using this app you agree to our updated privacy policy. Check it out in the Settings page!"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Location Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations[0]
        // reload data to include any new views
        //self.collectionView?.reloadData()
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
        // erase any previous image
        cell.imageView?.image = nil
        
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
        return UIEdgeInsetsMake(84.0, 10.0, 20.0, 10.0);
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
    
    // MARK: - Poptip sequence
    func showNextPoptip()
    {
        switch popTipCounter {
        case 0:
            /* browse tip */
            RZPoptipHelper.shared().showPopTip(text: "Tap a challenge to find out more about it", direction: .down, in: self.view, fromFrame: self.navigationController!.navigationBar.frame) { self.showNextPoptip() }
        case 1:
            /* me tip */
            var itemFrame = (self.tabBarController!.tabBar.items![1].value(forKey: "view") as! UIView).frame
            itemFrame = itemFrame.offsetBy(dx: self.tabBarController!.tabBar.frame.origin.x, dy: self.tabBarController!.tabBar.frame.origin.y)
            RZPoptipHelper.shared().showPopTip(text: "Your challenge submissions will appear down here", direction: .up, in: self.view, fromFrame: itemFrame) { self.showNextPoptip() }
        case 2:
            /* wallet tip */
            var itemFrame = (self.tabBarController!.tabBar.items![2].value(forKey: "view") as! UIView).frame
            itemFrame = itemFrame.offsetBy(dx: self.tabBarController!.tabBar.frame.origin.x, dy: self.tabBarController!.tabBar.frame.origin.y)
            RZPoptipHelper.shared().showPopTip(text: "Check out your wallet to find the rewards you've earned", direction: .up, in: self.view, fromFrame: itemFrame) { }
        default:
            break;
        }
        /* go to next index */
        popTipCounter += 1;
    }

}
