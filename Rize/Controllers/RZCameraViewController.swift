//
//  RZCameraViewController.swift
//  Rize
//
//  Created by Matthew Russell on 6/21/16.
//  Copyright © 2016 Rize. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

protocol RZCameraViewControllerDelegate: class {
  func cameraViewDidFinish(_ sender: RZCameraViewController)
}

class RZCameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RZUploadAlertViewControllerDelegate, RZPostMessageViewControllerDelegate {

    // which challenge this capture is for
    // we assume this has been set from the presenting controller
    var challenge : RZChallenge!
    
    var captureSession : AVCaptureSession?
    
    var backCaptureDevice : AVCaptureDevice?
    var frontCaptureDevice : AVCaptureDevice?
    var audioDevice : AVCaptureDevice?
    
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var avPlayer : AVPlayer?
    var reviewLayer : AVPlayerLayer?
    
    var usingFrontCamera : Bool = true
    var videoFileOutput : AVCaptureMovieFileOutput?
    var photoFileOutput : AVCaptureStillImageOutput?
    var outputFileUrl : URL?
    
    var postMessage : String?
    
    var hideBar : Bool = false
    
    weak var delegate : RZCameraViewControllerDelegate?
    
    @IBOutlet var progressBar: UIView?
    @IBOutlet var dismissButton: UIButton?
    @IBOutlet var closeButton: UIButton?
    @IBOutlet var swapButton: UIButton?
    @IBOutlet var rollButton: UIButton?
    @IBOutlet var shutterButton: UIButton?
    @IBOutlet var uploadButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the shutter button image based on the challenge type
        if self.challenge.type == "photo" {
            shutterButton?.setImage(UIImage(named: "rize"), for: .normal)
        } else {
            shutterButton?.setImage(UIImage(named: "record"), for: .normal)
        }
        
        let devices = AVCaptureDevice.devices()
        
        // grab the front and back cameras
        for device in devices!
        {
            if ((device as AnyObject).hasMediaType(AVMediaTypeVideo))
            {
                if ((device as AnyObject).position == AVCaptureDevicePosition.back)
                {
                    backCaptureDevice = device as? AVCaptureDevice
                }
                else if ((device as AnyObject).position == AVCaptureDevicePosition.front)
                {
                    frontCaptureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        // grab the audio device
        audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        
        // make sure we have the devices before starting
        if backCaptureDevice != nil && frontCaptureDevice != nil && audioDevice != nil
        {
            beginSession(usingFrontCamera)
        }
        
        // Show the record UI first
        showRecordUI()
        setShadowButton(shutterButton!)
        setShadowButton(uploadButton!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // hide the status bar
        hideBar = true
        UIView.animate(withDuration: 0.25, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    //shutterButton and uploadButton shadow
    func setShadowButton(_ shutterButton: UIButton){
        shutterButton.layer.shadowColor = UIColor.black.cgColor
        shutterButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        shutterButton.layer.masksToBounds = false
        shutterButton.layer.shadowRadius = 5.0
        shutterButton.layer.shadowOpacity = 0.15
    }
    
    override var prefersStatusBarHidden : Bool {
        return hideBar
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .slide
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Visibility setup
    func showRecordUI() {
        shutterButton?.isHidden = false
        rollButton?.isHidden = false
        swapButton?.isHidden = false
        dismissButton?.isHidden = true
        closeButton?.isHidden = false
        uploadButton?.isHidden = true
    }
    
    func showReviewUI() {
        shutterButton?.isHidden = true
        rollButton?.isHidden = true
        swapButton?.isHidden = true
        dismissButton?.isHidden = false
        closeButton?.isHidden = true
        uploadButton?.isHidden = false
    }
    
    func hideAllUI() {
        shutterButton?.isHidden = true
        rollButton?.isHidden = true
        swapButton?.isHidden = true
        dismissButton?.isHidden = true
        closeButton?.isHidden = true
        uploadButton?.isHidden = true
    }
    
    // MARK: - AV Session
    
    func beginSession(_ useFrontCamera: Bool)
    {
        do
        {
            captureSession?.stopRunning()
            previewLayer?.removeFromSuperlayer()
            reviewLayer?.removeFromSuperlayer()
            captureSession = AVCaptureSession()
            usingFrontCamera = useFrontCamera
            if useFrontCamera
            {
                try captureSession?.addInput(AVCaptureDeviceInput(device: frontCaptureDevice))
            } else {
                try captureSession?.addInput(AVCaptureDeviceInput(device: backCaptureDevice))
            }
            try captureSession?.addInput(AVCaptureDeviceInput(device: audioDevice))
            
            if challenge.type == "photo" {
                captureSession?.sessionPreset = AVCaptureSessionPresetPhoto
                self.photoFileOutput = AVCaptureStillImageOutput()
                self.captureSession?.addOutput(self.photoFileOutput)
            } else {
                captureSession?.sessionPreset = AVCaptureSessionPresetHigh
                self.videoFileOutput = AVCaptureMovieFileOutput()
                self.captureSession?.addOutput(self.videoFileOutput)
                let maxDuration: CMTime = CMTimeMakeWithSeconds(10, 1)
                self.videoFileOutput?.maxRecordedDuration = maxDuration
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.frame = self.view.bounds
            previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.view.layer.insertSublayer(previewLayer!, at: 0)
            captureSession?.startRunning()
        } catch { }
    }
    
    @IBAction func done()
    {
        self.delegate?.cameraViewDidFinish(self)
    }
    
    @IBAction func dismissReview()
    {
        self.avPlayer?.pause()
        showRecordUI()
        self.beginSession(self.usingFrontCamera)
    }
    
    @IBAction func writeMessage() {
        self.avPlayer?.pause()
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostMessageViewController") as! RZPostMessageViewController
        postViewController.delegate = self
        self.present(postViewController, animated: true, completion: nil)
    }
    
    func postMessageControllerDidDismiss(withMessage message: String?) {
        // dismiss the controller
        self.dismiss(animated: true, completion: nil)
        
        // got the message
        if message != nil {
            postMessage = message
            beginUpload()
        } else {
            self.avPlayer?.play()
        }
    }
    
    @IBAction func beginUpload()
    {
        // upload process begins by ensuring we have the proper FBSDK permissions
        if (!FBSDKAccessToken.current().hasGranted("publish_actions")) {
            let loginManager = FBSDKLoginManager()
            loginManager.logIn(withPublishPermissions: ["publish_actions"], from: self, handler: { (result, error) in
                print(result, error)
            })
        } else {
            // if everything is good, call uploadVideo
            uploadVideo()
        }
    }
    
    func uploadVideo()
    {
        // hide all the ui 
        UIView.animate(withDuration: 0.5) {
            self.hideAllUI()
        }
        
        // fade out the video layers
        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.duration = 0.5
        fadeOut.fromValue = 1.0
        fadeOut.toValue = 0.0
        fadeOut.fillMode = kCAFillModeForwards
        fadeOut.isRemovedOnCompletion = false
        self.avPlayer?.pause()
        reviewLayer?.removeFromSuperlayer()
        previewLayer?.removeFromSuperlayer()
        
        // make sure the challenge is still active
        if (!RZDatabase.sharedInstance().getChallenge(challenge.id!)!.isActive()) {
            // not active, show alert
            showExpiredAlert()
            return
        }
        
        let videoData = NSData(contentsOf: self.outputFileUrl!)
        var videoObject = [AnyHashable : Any]()
        videoObject["description"] = postMessage
        videoObject[self.outputFileUrl!.lastPathComponent] = videoData
        
        // TESTING if set to PRIVATE
        videoObject["privacy"] = "{ \"value\" : \"ALL_FRIENDS\" }"
        
        let request = FBSDKGraphRequest(graphPath: "me/videos", parameters: videoObject, httpMethod: "POST")
        
        let uploadAlert = RZUploadAlertViewController()
        uploadAlert.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        uploadAlert.delegate = self
        self.present(uploadAlert, animated: false, completion: nil)

        request?.start(completionHandler: {(connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
                self.showUploadErrorAlert()
            }
            else
            {
                uploadAlert.showSuccess()
                let resultDict = result! as! [ String : AnyObject? ]
                
                // record the submission information in the database
                var submission = [String : AnyObject]()
                submission["challenge_id"] = self.challenge.id as AnyObject
                submission["fb_id"] =  String(format: "%@_%@", FBSDKAccessToken.current().userID!, resultDict["id"] as! String) as AnyObject
                submission["approved"] = false as AnyObject
                submission["facebook"] = true as AnyObject
                submission["views"] = 0 as AnyObject
                submission["likes"] = 0 as AnyObject
                submission["shares"] = 0 as AnyObject
                submission["friends"] = 0 as AnyObject
                submission["points"] = 0 as AnyObject
                submission["redeemed"] = false as AnyObject
                submission["tier"] = 0 as AnyObject
                RZDatabase.sharedInstance().pushSubmission(self.challenge.id!, submission: submission)
            }
        })
    }
    
    func showUploadErrorAlert() {
        let alert = UIAlertController(title: "Oops", message: "Something went wrong and we couldn't upload your video", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.done()
        }))
        self.present(alert, animated: true,completion: nil)
    }
    
    func showExpiredAlert() {
        let alert = UIAlertController(title: "This is embarassing", message: "It looks like this challenge is now expired", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.done()
        }))
        self.present(alert, animated: true,completion: nil)
    }
    
    // MARK: - Upload Alert Delegate
    func uploadAlertDidFinish(_ sender: RZUploadAlertViewController, success: Bool) {
        self.dismiss(animated: false) {
            self.done()
        }
    }
    
    // MARK: - Camera Roll Functions
    func openCameraRoll()
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.videoMaximumDuration = 6.0
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)

        showReviewUI() // load the other ui buttons
        self.captureSession?.stopRunning()
        self.progressBar?.layer.removeAllAnimations()
        previewLayer?.removeFromSuperlayer() // remove the preview layer
        // display the review
        self.avPlayer = AVPlayer(url: info[UIImagePickerControllerMediaURL] as! URL)
        self.reviewLayer = AVPlayerLayer(player: self.avPlayer)
        self.avPlayer?.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        NotificationCenter.default.addObserver(self, selector: #selector(restartVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer?.currentItem)
        self.reviewLayer?.frame = self.view.bounds
        self.view.layer.insertSublayer(self.reviewLayer!, at: 0)
        self.reviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.avPlayer?.play()
        
        self.outputFileUrl = info[UIImagePickerControllerMediaURL] as? URL
    }
    
    // MARK: Camera Functions
    
    @IBAction func flipCamera()
    {
        usingFrontCamera = !usingFrontCamera
        beginSession(usingFrontCamera)
    }
    
    @IBAction func startRecording()
    {
        if self.captureSession!.isRunning {
            let outputUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("video.mp4")
            do {
                try FileManager.default.removeItem(at: outputUrl)
            } catch {
                print("Error")
            }
            self.videoFileOutput?.startRecording(toOutputFileURL: outputUrl, recordingDelegate: self)
            // animate the progress bar
            self.progressBar?.isHidden = false
            self.progressBar?.frame = CGRect(x: 0, y: 0, width: 0, height: 10)
            UIView.animate(withDuration: 10.0, delay: 0, options: .curveLinear, animations: { () in
                self.progressBar?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 10)
            }) { (completed) in
                self.progressBar?.isHidden = true
            }
        }
    }
    
    @IBAction func stopRecording()
    {
        self.videoFileOutput?.stopRecording()
    }
    
    func capturePhoto()
    {
        self.captureSession?.stopRunning()
        // code adapted from answer http://stackoverflow.com/a/28756857/2213377
        if let videoConnection = photoFileOutput?.connection(withMediaType: AVMediaTypeVideo) {
            photoFileOutput?.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                let outputUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("photo.jpg")
                do {
                    // save the photo to a file
                    try imageData?.write(to: outputUrl)
                    self.outputFileUrl = outputUrl
                } catch let error {
                    self.outputFileUrl = nil
                }
                
                
                
                self.showReviewUI()
            }
        }
    }
    
    // MARK: Capture Delegate
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        // finished recording the video
        showReviewUI() // load the other ui buttons
        self.captureSession?.stopRunning()
        self.progressBar?.layer.removeAllAnimations()
        previewLayer?.removeFromSuperlayer() // remove the preview layer
        
        // display the review
        self.avPlayer = AVPlayer(url: outputURL)
        self.reviewLayer = AVPlayerLayer(player: self.avPlayer)
        self.avPlayer?.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        NotificationCenter.default.addObserver(self, selector: #selector(restartVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer?.currentItem)
        self.reviewLayer?.frame = self.view.bounds
        self.view.layer.insertSublayer(self.reviewLayer!, at: 0)
        self.reviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.avPlayer?.play()
        self.outputFileUrl = outputURL
    }
    
    func restartVideo(_ notification: Notification) {
        self.avPlayer?.seek(to: kCMTimeZero)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
