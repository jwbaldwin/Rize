//
//  RZFBGraphRequestHelper.swift
//  Rize
//
//  Created by Matthew Russell on 12/26/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

class RZFBGraphRequestHelper {
    // MARK: - Data setup
    static func getFBGraphData(endpoint : String, complete : @escaping (_ result : [String : AnyObject?]?, _ error : Error?) -> Void) {
        let request = FBSDKGraphRequest(graphPath: endpoint, parameters: nil)
        request?.start(completionHandler: { (connection, result, error) -> Void in
            let resultDict = result as? [String : AnyObject]
            complete(resultDict, error)
        })
    }

}
