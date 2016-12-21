//
//  ArrowTipShape.swift
//  Rize
//
//  Created by Matthew Russell on 12/21/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

class ArrowTipShape: CAShapeLayer {
    
    init(frame: CGRect) {
        super.init()
        self.frame = frame
        self.strokeColor = UIColor(red: 0.914, green: 0.118, blue: 0.388, alpha: 1.0).cgColor
        self.lineWidth = 5.0
        self.fillColor = UIColor.clear.cgColor
        self.lineCap = kCALineCapRound
        self.cornerRadius = 5.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var finalTipPath : UIBezierPath {
        let tipPath = UIBezierPath()
        tipPath.move(to: CGPoint(x: 0, y: self.frame.height))
        tipPath.addLine(to: CGPoint(x: self.frame.width/2, y: 0))
        tipPath.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        tipPath.stroke()
        return tipPath
    }
}
