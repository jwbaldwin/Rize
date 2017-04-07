//
//  RZWalletCollectionViewController.swift
//  Rize
//
//  Created by James Baldwin on 4/3/17.
//  Copyright © 2017 Rize. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseDatabase //Unsure if necessary

private let reuseIdentifier = "Cell"

class RZWalletCollectionViewController: UICollectionViewController, RZDatabaseDelegate{

    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    
    var rewards : [RZReward]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes TODO: Uncomment when ready
        //self.collectionView!.register(RZWalletCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        self.activityIndicator?.startAnimating()
        
        //RZDatabase.sharedInstance().delegate = self
        
        // apply the color scheme
        self.view.backgroundColor = RZColors.background
        self.navigationController?.navigationBar.backgroundColor = RZColors.navigationBar
        self.navigationController?.navigationBar.tintColor = RZColors.primary
        self.navigationController?.navigationBar.titleTextAttributes?[NSForegroundColorAttributeName] = RZColors.primary
        
        rewards = RZDatabase.sharedInstance().getWallet()
        print("----------")
        print(rewards?.count)
        print(rewards?[0].title)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        //Count num of codes in coredata/db
        return rewards!.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RZWalletCollectionViewCell
        
        for index in 0...rewards!.count-1{
            print(index)
            cell.rewardName.text = rewards?[index].title
            cell.expDate.text = "Endless"
            //cell.redeemBtn.title = rewards?[index].code
            //cell.companyLoc.text = rewards?[index].challenge_id!.uppercased()
            
        }
    
    
        return cell
    }
    
    func databaseDidUpdate(_ database: RZDatabase) {
        //self.activityIndicator?.stopAnimating()
        //self.collectionView?.reloadData()
    }

    // MARK: UICollectionViewDelegate

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
