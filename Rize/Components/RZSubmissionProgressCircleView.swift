//
//  RZSubmissionProgressCircleView.swift
//  Rize
//
//  Created by Matthew Russell on 3/29/17.
//  Copyright © 2017 Rize. All rights reserved.
//

import UIKit

import UIKit

class RZSubmissionProgressCircleView: UIView, CAAnimationDelegate {

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
        
        self.backgroundColor = UIColor.clear
        
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
            _arcShapes[i].strokeStart = 0.0
            _arcShapes[i].strokeEnd = 0.0

            if (animated) {
                let anim = CABasicAnimation()
                anim.keyPath = "strokeEnd"
                anim.fromValue = 0.0
                anim.toValue = progress
                anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                anim.duration = 1.0
                anim.fillMode = kCAFillModeBoth
                anim.isRemovedOnCompletion = true
                _arcShapes[i].add(anim, forKey: "progress")
                _arcShapes[i].strokeEnd = progress
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
            
            _textLayers[i].frame = CGRect(origin: textOrigin, size: textSize)

        }
    }
    
    func reset(newTotal : Int)
    {
        total = newTotal
        
        for i in 0..<points.count
        {
            
            let startAnim = CABasicAnimation()
            startAnim.keyPath = "strokeStart"
            startAnim.fromValue = 0.0
            startAnim.toValue = 1.0
            _arcShapes[i].strokeStart = 1.0
            
            let endAnim = CABasicAnimation()
            endAnim.keyPath = "strokeEnd"
            endAnim.fromValue = _arcShapes[i].strokeEnd
            endAnim.toValue = 1.0
            _arcShapes[i].strokeEnd = 1.0
            
            let group = CAAnimationGroup()
            group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            group.duration = 1.0
            group.fillMode = kCAFillModeBoth
            group.isRemovedOnCompletion = true
            group.animations = [startAnim, endAnim]
            group.delegate = self
            
            if i == points.count - 1 {
                group.setValue("reset", forKey: "id")
            }
            
            _arcShapes[i].add(group, forKey: "reset")
        }
        
    }
    
    // MARK - Animation Delegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool)
    {
        guard let id = anim.value(forKey: "id") as? String
            else { return }
        print(id, flag)
        if flag && id == "reset" {
            self.updateProgress(animated: true)
        }
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
