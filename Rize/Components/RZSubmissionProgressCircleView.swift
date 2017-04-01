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
    
    fileprivate var _strokeColors = [UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1.0), UIColor(red: 0.741, green: 0.741, blue: 0.741, alpha: 1.0), UIColor(red: 1.0, green: 0.757, blue: 0.027, alpha: 1.0)]
    fileprivate var _textColor : UIColor = UIColor(white: 0.75, alpha: 1.0)


    fileprivate var _bgStrokeColor : UIColor = UIColor.white
    fileprivate var _startAngle : CGFloat = 0.0
    fileprivate var _clockwise : Bool = false
    fileprivate var _arcShapes : [CAShapeLayer] = []
    fileprivate var _textLayers: [CATextLayer] = []
    fileprivate var bgArcShape : CAShapeLayer?
    
    var points = [0, 0, 0]
    var total : Int = 100
    
    let LABEL_DISTANCE : CGFloat = 30.0
    
    var lineWidth : CGFloat {
        set {
            _lineWidth = newValue
            bgArcShape?.lineWidth = _lineWidth
            _arcShapes[0].lineWidth = _lineWidth
            _arcShapes[1].lineWidth = _lineWidth
            _arcShapes[2].lineWidth = _lineWidth
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
        
        self.bgArcShape = CAShapeLayer()
        self.bgArcShape?.fillColor = UIColor.clear.cgColor
        self.bgArcShape?.strokeColor = UIColor(white: 0.95, alpha: 1.0).cgColor
        // drop shadow
        self.bgArcShape?.shadowColor = UIColor.black.cgColor
        self.bgArcShape?.shadowRadius = 10.0
        self.bgArcShape?.shadowOpacity = 0.25
        self.bgArcShape?.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.addSublayer(self.bgArcShape!)
        
        _arcShapes = [CAShapeLayer(), CAShapeLayer(), CAShapeLayer()]
        for i in stride(from: points.count-1, through: 0, by: -1)
        {
            _arcShapes[i].fillColor = UIColor.clear.cgColor
            _arcShapes[i].strokeColor = _strokeColors[i].cgColor
            self.layer.addSublayer(_arcShapes[i])
        }
        
        // Text bubbles
        _textLayers = [CATextLayer(), CATextLayer(), CATextLayer()]
        for i in 0..<points.count
        {
            _textLayers[i].foregroundColor = _strokeColors[i].cgColor
            _textLayers[i].fontSize = 20.0
            _textLayers[i].contentsScale = UIScreen.main.scale
            _textLayers[i].alignmentMode = kCAAlignmentCenter
            self.layer.addSublayer(_textLayers[i])
        }

        updateArcPath()
        setProgress(uploadProgress: 0, likesProgress: 0, sharesProgress: 0, animated: false)
    }
    
    fileprivate func updateArcPath()
    {
        // set the new arc path
        self.bgArcShape?.path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: self.frame.width/2 - self._lineWidth/2 - LABEL_DISTANCE*1.5, startAngle: _startAngle, endAngle: _startAngle + (_clockwise ? 1 : -1) * 2 * CGFloat(M_PI), clockwise: _clockwise).cgPath
        
        for i in 0..<points.count
        {
            _arcShapes[i].path = self.bgArcShape?.path
        }
        
        setNeedsDisplay()
    }
    
    func updateProgress(animated: Bool)
    {
        var progress : CGFloat = 0.0
        let textSize = CGSize(width: 30, height: 20)
        let textRadius = self.frame.width/2 - 0.5 * LABEL_DISTANCE
        print(self.frame)
        for i in 0..<points.count
        {
            progress += CGFloat(points[i]) / CGFloat(total)
            
            if (animated) {
                let anim = CABasicAnimation()
                anim.keyPath = "strokeEnd"
                anim.fromValue = 0.0
                anim.toValue = progress
                anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                anim.duration = 1.0
                anim.fillMode = kCAFillModeForwards
                anim.isRemovedOnCompletion = false
                _arcShapes[i].add(anim, forKey: "progress")
            } else {
                _arcShapes[i].removeAllAnimations()
                _arcShapes[i].strokeEnd = progress
            }
            
            _textLayers[i].string = "\(points[i])"

            var angle = startAngle
            for j in 0..<i
            {
                angle -= 2*CGFloat(Double.pi)*CGFloat(points[j]) / CGFloat(total)
            }
            angle -= CGFloat(Double.pi)*CGFloat(points[i]) / CGFloat(total)
            
            let textOrigin = CGPoint(x: self.frame.width/2 + textRadius * cos(angle) - textSize.width/2, y: self.frame.height/2 + textRadius * sin(angle) - textSize.height/2)
            print(textOrigin)
            
            _textLayers[i].frame = CGRect(origin: textOrigin, size: textSize)

        }
    }
    
    func setProgress(uploadProgress : CGFloat, likesProgress : CGFloat, sharesProgress : CGFloat, animated : Bool)
    {
        /*
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
        */
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgArcShape?.frame = self.bounds
        print(self.frame)
        for i in 0..<points.count
        {
            _arcShapes[i].frame = self.bounds
        }
        updateArcPath()
    }
}
