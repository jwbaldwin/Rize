//
//  RZUploadAlertViewController.swift
//  
//
//  Created by Matthew Russell on 12/20/16.
//
//

import UIKit

protocol RZUploadAlertViewControllerDelegate: class {
    func uploadAlertDidFinish(_ sender: RZUploadAlertViewController, success: Bool)
}

class RZUploadAlertViewController: UIViewController, CAAnimationDelegate {
    var contentView : UIView?
    var arcLayer    : LoadingArcShape?
    var arrowBaseLayer : ArrowBaseShape?
    var arrowTipLayer : ArrowTipShape?
    weak var delegate : RZUploadAlertViewControllerDelegate?
    
    let ARC_PERIOD = 0.8
    let ARROW_GROW_TIME = 0.3
    let PAUSE_BEFORE_DISMISS = 1.0
    let TIP_HEIGHT : CGFloat = 30.0
    let TIP_WIDTH : CGFloat = 60.0
    let BASE_HEIGHT : CGFloat = 70.0
    let TOTAL_HEIGHT : CGFloat = 100.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        
        self.contentView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        contentView?.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2)
        contentView?.layer.cornerRadius = 100.0
        contentView?.backgroundColor = UIColor.white
        
        self.view.addSubview(contentView!)
        
        // add the grayed out arrow
        let grayArrowBaseLayer = ArrowBaseShape(frame: CGRect(x: self.contentView!.frame.size.width/2 - 60/2, y: self.contentView!.frame.size.height/2 - TOTAL_HEIGHT/2 + TIP_HEIGHT, width: TIP_WIDTH, height: BASE_HEIGHT))
        grayArrowBaseLayer.path = grayArrowBaseLayer.finalBasePath.cgPath
        grayArrowBaseLayer.strokeColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        self.contentView!.layer.addSublayer(grayArrowBaseLayer)
        
        let grayArrowTipLayer = ArrowTipShape(frame: CGRect(x: self.contentView!.frame.size.width/2 - TIP_WIDTH/2, y: self.contentView!.frame.size.height/2 - TOTAL_HEIGHT/2, width: TIP_WIDTH, height: TIP_HEIGHT))
        grayArrowTipLayer.path = grayArrowTipLayer.finalTipPath.cgPath
        grayArrowTipLayer.strokeColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        self.contentView!.layer.addSublayer(grayArrowTipLayer)
        
        arcLayer = LoadingArcShape(frame: CGRect(x: contentView!.frame.size.width/2 - 150/2, y: contentView!.frame.size.height/2 - 150/2, width: 150, height: 150))
        contentView!.layer.insertSublayer(arcLayer!, at: 0)
        
        let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnim.duration = ARC_PERIOD
        rotationAnim.fromValue = 0
        rotationAnim.toValue = 3.141592654 * 2
        rotationAnim.repeatCount = .infinity
        rotationAnim.fillMode = kCAFillModeForwards
        rotationAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        rotationAnim.isRemovedOnCompletion = false
        arcLayer?.add(rotationAnim, forKey: "rotation")
    }
    
    func showSuccess()
    {
        // remove the circle animation
        arcLayer?.removeAllAnimations()
        
        // add the rotation to the base of the arrow
        let startingRotation = arcLayer?.presentation()?.value(forKeyPath: "transform.rotation.z") as! Double
        let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
        let duration = ARC_PERIOD - startingRotation / (2*3.14159265)
        rotationAnim.duration = duration
        rotationAnim.fromValue = startingRotation
        rotationAnim.toValue = 2*3.141592654
        rotationAnim.repeatCount = 1
        rotationAnim.fillMode = kCAFillModeForwards
        rotationAnim.isRemovedOnCompletion = false
        rotationAnim.setValue("finishRotating", forKey: "id")
        rotationAnim.delegate = self
        arcLayer?.add(rotationAnim, forKey: "rotation")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let animId = anim.value(forKey: "id") as! String
        if (animId == "finishRotating")
        {
            // shrink the arc layer
            let shrinkAnim = CABasicAnimation(keyPath: "strokeStart")
            shrinkAnim.duration = 0.1
            shrinkAnim.fromValue = 0.0
            shrinkAnim.toValue = 1.0
            shrinkAnim.fillMode = kCAFillModeForwards
            shrinkAnim.isRemovedOnCompletion = false
            shrinkAnim.setValue("shrinkArc", forKey: "id")
            shrinkAnim.delegate = self
            self.arcLayer?.add(shrinkAnim, forKey: "shrink")
            
            arrowBaseLayer = ArrowBaseShape(frame: CGRect(x: self.contentView!.frame.size.width/2 - 60/2, y: self.contentView!.frame.size.height/2 - TOTAL_HEIGHT/2 + TIP_HEIGHT, width: TIP_WIDTH, height: BASE_HEIGHT+(150-TOTAL_HEIGHT)/2))
            arrowBaseLayer?.path = arrowBaseLayer?.finalBasePath.cgPath
            self.contentView!.layer.addSublayer(arrowBaseLayer!)
            
            let baseAnim = CABasicAnimation(keyPath: "strokeEnd")
            baseAnim.duration = ARROW_GROW_TIME
            baseAnim.fromValue = 0
            baseAnim.toValue = 1.0
            baseAnim.fillMode = kCAFillModeForwards
            baseAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            baseAnim.isRemovedOnCompletion = false
            baseAnim.delegate = self
            baseAnim.setValue("drawBase", forKey: "id")
            arrowBaseLayer?.add(baseAnim, forKey: "strokeDraw")
            
        } else if (animId == "shrinkArc") {
            arrowTipLayer = ArrowTipShape(frame: CGRect(x: self.contentView!.frame.size.width/2 - 60/2, y: self.contentView!.frame.size.height/2 - TOTAL_HEIGHT/2, width: TIP_WIDTH, height: TIP_HEIGHT))
            arrowTipLayer?.path = arrowTipLayer?.finalTipPath.cgPath
            self.contentView!.layer.addSublayer(arrowTipLayer!)
            
            let tipAnimEnd = CABasicAnimation(keyPath: "strokeEnd")
            tipAnimEnd.duration = ARROW_GROW_TIME
            tipAnimEnd.fromValue = 0.5
            tipAnimEnd.toValue = 1.0
            tipAnimEnd.fillMode = kCAFillModeForwards
            tipAnimEnd.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            tipAnimEnd.isRemovedOnCompletion = false
            
            let tipAnimStart = CABasicAnimation(keyPath: "strokeStart")
            tipAnimStart.duration = ARROW_GROW_TIME
            tipAnimStart.fromValue = 0.5
            tipAnimStart.toValue = 0
            tipAnimStart.fillMode = kCAFillModeForwards
            tipAnimStart.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            tipAnimStart.isRemovedOnCompletion = false

            arrowTipLayer?.add(tipAnimStart, forKey: "strokeStart")
            arrowTipLayer?.add(tipAnimEnd, forKey: "strokeEnd")
            
        } else if (animId == "drawBase") {
            self.arcLayer?.removeFromSuperlayer()
            let baseAnim = CABasicAnimation(keyPath: "strokeStart")
            baseAnim.duration = 0.1
            baseAnim.fromValue = 0
            baseAnim.toValue = ((150 - TOTAL_HEIGHT)/2) / (BASE_HEIGHT + (150 - TOTAL_HEIGHT)/2)
            baseAnim.fillMode = kCAFillModeForwards
            baseAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            baseAnim.isRemovedOnCompletion = false
            arrowBaseLayer?.add(baseAnim, forKey: "strokeStartShift")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + PAUSE_BEFORE_DISMISS) {
                self.delegate?.uploadAlertDidFinish(self, success: true)
            }
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
