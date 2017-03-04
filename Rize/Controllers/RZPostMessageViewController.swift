//
//  RZPostMessageViewController.swift
//  Rize
//
//  Created by Matthew Russell on 2/11/17.
//  Copyright © 2017 Rize. All rights reserved.
//

import UIKit

protocol RZPostMessageViewControllerDelegate {
    func postMessageControllerDidDismiss(withMessage message: String?)
}

class RZPostMessageViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var textField : UITextView!
    @IBOutlet var customNavBar : UINavigationBar!
    var delegate : RZPostMessageViewControllerDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup colors
        self.customNavBar.backgroundColor = RZColors.navigationBar
        self.customNavBar.tintColor = RZColors.primary
        self.customNavBar.titleTextAttributes?[NSForegroundColorAttributeName] = RZColors.primary
        self.textField.tintColor = RZColors.primary
        
        self.textField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.	
    }
    
    @IBAction func textFieldDidReturn() {
        delegate?.postMessageControllerDidDismiss(withMessage: textField.text)
    }
    
    @IBAction func done() {
        delegate?.postMessageControllerDidDismiss(withMessage: textField.text)
    }
    
    @IBAction func cancel() {
        delegate?.postMessageControllerDidDismiss(withMessage: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
