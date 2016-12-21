//
//  LoadingArcShape.swift
//  Rize
//
//  Created by Matthew Russell on 12/20/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

class LoadingArcShape: CAShapeLayer {

    override init() {
        super.init()
        
    }
    
    init(frame: CGRect)
    {
        super.init()
        self.frame = frame
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = UIColor(white: 0.85, alpha: 1.0).cgColor//UIColor(red: 0.914, green: 0.118, blue: 0.388, alpha: 1.0).cgColor
        let arcPath = UIBezierPath()
        arcPath.addArc(withCenter: CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2), radius: self.frame.size.width/2, startAngle: 3.14159*(0.5 - 0.3), endAngle: 3.14159*0.5, clockwise: true)
        self.lineWidth = 5.0
        self.path = arcPath.cgPath
        self.lineCap = kCALineCapRound
    }
    
    override init(layer: Any)
    {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
