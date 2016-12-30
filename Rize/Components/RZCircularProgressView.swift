//
//  RZCircularProgressView.swift
//  Rize
//
//  Created by Matthew Russell on 12/22/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit

class RZCircularProgressView: UIView {

    fileprivate var _progress : CGFloat = 0.0
    fileprivate var _lineWidth : CGFloat = 0.0
    fileprivate var _strokeColor : UIColor = UIColor.black
    fileprivate var _bgStrokeColor : UIColor = UIColor.white
    fileprivate var _startAngle : CGFloat = 0.0
    fileprivate var _clockwise : Bool = false
    fileprivate var arcShape : CAShapeLayer?
    fileprivate var bgArcShape : CAShapeLayer?
    var lineWidth : CGFloat {
        set {
            _lineWidth = newValue
            arcShape?.lineWidth = _lineWidth
            bgArcShape?.lineWidth = _lineWidth
            updateArcPath()
        }
        get { return _lineWidth }
    }
    var strokeColor : UIColor {
        set {
            _strokeColor = newValue
            arcShape?.strokeColor = _strokeColor.cgColor
            setNeedsDisplay()
        }
        get { return _strokeColor }
    }
    
    var bgStrokeColor : UIColor {
        set {
            _bgStrokeColor = newValue
            bgArcShape?.strokeColor = _bgStrokeColor.cgColor
            setNeedsDisplay()
        }
        get { return _bgStrokeColor }
    }
    
    var startAngle : CGFloat {
        set {
            _startAngle = newValue
            updateArcPath()
        }
        get { return _startAngle }
    }
    var clockwise : Bool {
        set {
            _clockwise = newValue
            updateArcPath()
        }
        get { return _clockwise }
    }


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.arcShape = CAShapeLayer()
        self.arcShape?.fillColor = UIColor.clear.cgColor
        self.bgArcShape = CAShapeLayer()
        self.bgArcShape?.fillColor = UIColor.clear.cgColor
        self.bgArcShape?.strokeColor = UIColor(white: 0.95, alpha: 1.0).cgColor
        self.layer.addSublayer(self.bgArcShape!)
        self.layer.addSublayer(self.arcShape!)
        updateArcPath()
        setProgress(0.0, animated: false)
    }
    
    fileprivate func updateArcPath()
    {
        // set the new arc path
        self.arcShape?.path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: self.frame.width/2 - self._lineWidth/2, startAngle: _startAngle, endAngle: _startAngle + (_clockwise ? 1 : -1) * 2 * CGFloat(M_PI), clockwise: _clockwise).cgPath
        self.bgArcShape?.path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: self.frame.width/2 - self._lineWidth/2, startAngle: _startAngle, endAngle: _startAngle + (_clockwise ? 1 : -1) * 2 * CGFloat(M_PI), clockwise: _clockwise).cgPath
        setNeedsDisplay()
    }
    
    func setProgress(_ progress : CGFloat, animated : Bool)
    {
        if (animated) {
            let anim = CABasicAnimation()
            anim.keyPath = "strokeEnd"
            anim.fromValue = _progress
            anim.toValue = progress
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            anim.duration = 1.0
            anim.fillMode = kCAFillModeForwards
            anim.isRemovedOnCompletion = false
            arcShape?.add(anim, forKey: "progress")
        } else {
            arcShape?.removeAllAnimations()
            arcShape?.strokeEnd = progress
        }
        
        _progress = progress
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.arcShape?.frame = self.bounds
        updateArcPath()
        print(self.frame)
    }
}
