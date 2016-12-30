//
//  ArrowBaseShape.swift
//  Rize
//
//  Created by Matthew Russell on 12/21/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

class ArrowBaseShape: CAShapeLayer {

    init(frame: CGRect) {
        super.init()
        self.frame = frame
        self.strokeColor = RZColors.primary.cgColor
        self.lineWidth = 5.0
        self.fillColor = UIColor.clear.cgColor
        self.lineCap = kCALineCapRound
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var finalBasePath : UIBezierPath {
        let finalPath = UIBezierPath()
        finalPath.move(to: CGPoint(x: self.frame.width/2, y: self.frame.height))
        finalPath.addLine(to: CGPoint(x: self.frame.width/2, y: 0))
        finalPath.stroke()
        return finalPath
    }
}
