//
//  RZLegalViewController.swift
//  Rize
//
//  Created by Matthew Russell on 1/21/17.
//  Copyright © 2017 Rize. All rights reserved.
//

import UIKit

class RZLegalViewController: UIViewController {

    @IBOutlet var webView : UIWebView!
    var htmlContent : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = htmlContent {
            self.webView.loadHTMLString("<style>body { font-family: sans-serif; }</style><body>\(self.htmlContent!)</body>", baseURL: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
