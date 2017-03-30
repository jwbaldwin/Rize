//
//  RZSubmissionProgressCircleView.swift
//  Rize
//
//  Created by Matthew Russell on 3/29/17.
//  Copyright © 2017 Rize. All rights reserved.
//

import UIKit

import UIKit

class RZSubmissionProgressCircleView: UIView {

    fileprivate var _lineWidth : CGFloat = 0.0
    fileprivate var _uploadStrokeColor : UIColor = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1.0)
    fileprivate var _likesStrokeColor : UIColor = UIColor(red: 0.741, green: 0.741, blue: 0.741, alpha: 1.0)
    fileprivate var _sharesStrokeColor : UIColor = UIColor(red: 1.0, green: 0.757, blue: 0.027, alpha: 1.0)


    fileprivate var _bgStrokeColor : UIColor = UIColor.white
    fileprivate var _startAngle : CGFloat = 0.0
    fileprivate var _clockwise : Bool = false
    fileprivate var uploadArcShape : CAShapeLayer?
    fileprivate var likesArcShape : CAShapeLayer?
    fileprivate var sharesArcShape : CAShapeLayer?
    fileprivate var uploadsText : CATextLayer?

    fileprivate var bgArcShape : CAShapeLayer?
    
    var shares : Int = 0
    var uploads : Int = 0
    var likes : Int = 0
    var total : Int = 100
    var bubbleDistance : CGFloat = 20.0
    
    var lineWidth : CGFloat {
        set {
            _lineWidth = newValue
            bgArcShape?.lineWidth = _lineWidth
            uploadArcShape?.lineWidth = _lineWidth
            likesArcShape?.lineWidth = _lineWidth
            sharesArcShape?.lineWidth = _lineWidth
            updateArcPath()
        }
        get { return _lineWidth }
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
        
        self.likesArcShape = CAShapeLayer()
        self.sharesArcShape = CAShapeLayer()
        self.uploadArcShape = CAShapeLayer()
        
        self.bgArcShape = CAShapeLayer()
        self.bgArcShape?.fillColor = UIColor.clear.cgColor
        self.bgArcShape?.strokeColor = UIColor(white: 0.95, alpha: 1.0).cgColor
        
        self.likesArcShape?.fillColor = UIColor.clear.cgColor
        self.likesArcShape?.strokeColor = _likesStrokeColor.cgColor
        
        self.uploadArcShape?.fillColor = UIColor.clear.cgColor
        self.uploadArcShape?.strokeColor = _uploadStrokeColor.cgColor

        self.sharesArcShape?.fillColor = UIColor.clear.cgColor
        self.sharesArcShape?.strokeColor = _sharesStrokeColor.cgColor
        
        // drop shadow
        self.bgArcShape?.shadowColor = UIColor.black.cgColor
        self.bgArcShape?.shadowRadius = 10.0
        self.bgArcShape?.shadowOpacity = 0.25
        self.bgArcShape?.shadowOffset = CGSize(width: 0, height: 0)
        
        self.layer.addSublayer(self.bgArcShape!)
        self.layer.addSublayer(self.sharesArcShape!)
        self.layer.addSublayer(self.likesArcShape!)
        self.layer.addSublayer(self.uploadArcShape!)
        
        // Text bubbles
        self.uploadsText = CATextLayer()
        self.layer.addSublayer(self.uploadsText!)

        updateArcPath()
        setProgress(uploadProgress: 0, likesProgress: 0, sharesProgress: 0, animated: false)
    }
    
    fileprivate func updateArcPath()
    {
        // set the new arc path
        self.uploadArcShape?.path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: self.frame.width/2 - self._lineWidth/2, startAngle: _startAngle, endAngle: _startAngle + (_clockwise ? 1 : -1) * 2 * CGFloat(M_PI), clockwise: _clockwise).cgPath
        
        self.likesArcShape?.path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: self.frame.width/2 - self._lineWidth/2, startAngle: _startAngle, endAngle: _startAngle + (_clockwise ? 1 : -1) * 2 * CGFloat(M_PI), clockwise: _clockwise).cgPath
        
        self.sharesArcShape?.path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: self.frame.width/2 - self._lineWidth/2, startAngle: _startAngle, endAngle: _startAngle + (_clockwise ? 1 : -1) * 2 * CGFloat(M_PI), clockwise: _clockwise).cgPath
        
        self.bgArcShape?.path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: self.frame.width/2 - self._lineWidth/2, startAngle: _startAngle, endAngle: _startAngle + (_clockwise ? 1 : -1) * 2 * CGFloat(M_PI), clockwise: _clockwise).cgPath
        
        setNeedsDisplay()
    }
    
    func updateProgress(animated: Bool)
    {
        uploadArcShape?.removeAllAnimations()
        likesArcShape?.removeAllAnimations()
        sharesArcShape?.removeAllAnimations()
        
        let uploadsProgress = CGFloat(uploads) / CGFloat(total)
        let likesProgress = CGFloat(likes) / CGFloat(total)
        let sharesProgress = CGFloat(shares) / CGFloat(total)

        uploadArcShape?.strokeEnd = uploadsProgress
        likesArcShape?.strokeEnd = uploadsProgress + likesProgress
        sharesArcShape?.strokeEnd = uploadsProgress + likesProgress + sharesProgress
        
        /*
        uploadsText?.string = "\(uploads)"
        uploadsText?.fontSize = 20.0
        let uploadsPoint = CGPoint(x: self.frame.width/2 + (self.frame.width/2 + bubbleDistance) * cos(2*Double.pi*uploadsProgress + startAngle), y: self.frame.height/2 - (self.frame.height/2 + bubbleDistance) * sin(2*Double.pi*uploadsProgress + startAngle))
        uploadsText?.frame = CGRect(origin: uploadsPoint, size: CGSize(width: 20, height: 20))
        */
    }
    
    func setProgress(uploadProgress : CGFloat, likesProgress : CGFloat, sharesProgress : CGFloat, animated : Bool)
    {
        if (animated) {
            let uploadAnim = CABasicAnimation()
            uploadAnim.keyPath = "strokeEnd"
            uploadAnim.fromValue = 0.0
            uploadAnim.toValue = uploadProgress
            uploadAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            uploadAnim.duration = 1.0
            uploadAnim.fillMode = kCAFillModeForwards
            uploadAnim.isRemovedOnCompletion = false
            uploadArcShape?.add(uploadAnim, forKey: "progress")
            
            let likesAnim = CABasicAnimation()
            likesAnim.keyPath = "strokeEnd"
            likesAnim.fromValue = 0.0
            likesAnim.toValue = uploadProgress + likesProgress
            likesAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            likesAnim.duration = 1.0
            likesAnim.fillMode = kCAFillModeForwards
            likesAnim.isRemovedOnCompletion = false
            likesArcShape?.add(likesAnim, forKey: "progress")
            
            let sharesAnim = CABasicAnimation()
            sharesAnim.keyPath = "strokeEnd"
            sharesAnim.fromValue = 0.0
            sharesAnim.toValue = uploadProgress + likesProgress + sharesProgress
            sharesAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            sharesAnim.duration = 1.0
            sharesAnim.fillMode = kCAFillModeForwards
            sharesAnim.isRemovedOnCompletion = false
            sharesArcShape?.add(sharesAnim, forKey: "progress")
            
        } else {
            uploadArcShape?.removeAllAnimations()
            likesArcShape?.removeAllAnimations()
            sharesArcShape?.removeAllAnimations()

            uploadArcShape?.strokeEnd = uploadProgress
            likesArcShape?.strokeEnd = uploadProgress + likesProgress
            sharesArcShape?.strokeEnd = uploadProgress + likesProgress + sharesProgress
            print("\(uploadProgress + likesProgress + sharesProgress)")
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.uploadArcShape?.frame = self.bounds
        self.sharesArcShape?.frame = self.bounds
        self.likesArcShape?.frame = self.bounds
        updateArcPath()
        print(self.frame)
    }
}
