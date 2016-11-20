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

    @IBOutlet var pageControl   : UIPageControl!
    @IBOutlet var scrollView    : UIScrollView!
    weak var delegate : FBSDKLoginButtonDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        loginButton.delegate = delegate
        self.view.addSubview(loginButton)
    }
    
    override func viewDidLayoutSubviews() {
        // Set up the intro scroll view
        scrollView.delegate = self
        var imageNames = [ "intro_page1", "intro_page1" ]
        for i in 0..<imageNames.count
        {
           let image = UIImage(named: imageNames[i])
           let imageView = UIImageView(image: image!)
           imageView.frame = CGRect(x: CGFloat(i) * scrollView.frame.size.width, y: 0.0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
           imageView.contentMode = .scaleAspectFit
           scrollView.addSubview(imageView)
        }

        scrollView.contentSize = CGSize(width: scrollView.frame.size.width*CGFloat(imageNames.count), height: scrollView.frame.size.height);
    }
    
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
