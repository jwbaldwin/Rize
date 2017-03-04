//
//  RZLoginViewController.swift
//  Rize
//
//  Created by Matthew Russell on 8/12/16.
//  Copyright © 2016 Rize. All rights reserved.
//
//  Some code adapted from
//  http://stackoverflow.com/questions/19461678/how-do-i-use-uipagecontrol-in-my-app

import UIKit

class RZLoginViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var logo_grey: UIImageView!
    @IBOutlet var pageControl   : UIPageControl!
    @IBOutlet var scrollView    : UIScrollView!
    @IBOutlet var loginButton   : FBSDKLoginButton!
    weak var delegate : FBSDKLoginButtonDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.delegate = delegate
        self.loginButton.readPermissions = ["public_profile", "user_friends", "user_videos", "email"]
        self.view.addSubview(loginButton)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        self.loginButton.center.x += view.bounds.height
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if(FBSDKAccessToken.current() != nil){
            // logged in
            UIView.animate(withDuration: 0.5, animations: {
                self.logo_grey.alpha = 0.0
            })
        }else{
            UIView.animate(withDuration: 0.5, animations: {
                self.logo_grey.alpha = 0.0
            })
            
            UIView.animate(withDuration: 0.25, animations: {
                // Set up the intro scroll view
                self.scrollView.delegate = self
                var imageNames = [ "help_1", "help_2" , "help_3" ]
                for i in 0..<imageNames.count
                {
                    let image = UIImage(named: imageNames[i])
                    let imageView = UIImageView(image: image!)
                    imageView.frame = CGRect(x: CGFloat(i) * self.scrollView.frame.size.width, y: 0.0, width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height)
                    imageView.contentMode = .scaleAspectFit
                    self.scrollView.addSubview(imageView)
                }
                
                self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width*CGFloat(imageNames.count), height: self.scrollView.frame.size.height);

            })
            
            UIView.animate(withDuration: 1.5, delay: 0.5, animations:{
                self.scrollView.alpha = 1.0
                self.loginButton.center.y = self.view.bounds.height - 50
            })
        }

    }
    
    
//    override func viewDidLayoutSubviews() {
//        // Set up the intro scroll view
//        scrollView.delegate = self
//        var imageNames = [ "rize", "people" , "me" ]
//        for i in 0..<imageNames.count
//        {
//           let image = UIImage(named: imageNames[i])
//           let imageView = UIImageView(image: image!)
//           imageView.frame = CGRect(x: CGFloat(i) * scrollView.frame.size.width, y: 0.0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
//           imageView.contentMode = .scaleAspectFit
//           scrollView.addSubview(imageView)
//        }
//
//        scrollView.contentSize = CGSize(width: scrollView.frame.size.width*CGFloat(imageNames.count), height: scrollView.frame.size.height);
//    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let xPos = scrollView.contentOffset.x
        pageControl.currentPage = Int(xPos / scrollView.frame.size.width)
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

}
