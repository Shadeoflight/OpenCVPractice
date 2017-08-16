//
//  ViewController.swift
//  OpenCVTest
//
//  Created by Joshua Wu on 7/17/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    //---------------------------------------------------------------
    // General UI outlets
    //---------------------------------------------------------------
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var detectButton: UIButton!
    
    //---------------------------------------------------------------
    // Passed segue variable
    //---------------------------------------------------------------
    
    var passedSelection = String()
    
    //---------------------------------------------------------------
    // Camera variables
    //---------------------------------------------------------------
    
    var session : AVCaptureSession!
    var deviceUsed : AVCaptureDevice!
    var output : AVCaptureVideoDataOutput!
    
    //---------------------------------------------------------------
    // Detection variables
    //---------------------------------------------------------------
    
    var taken: Bool = false
    
    //---------------------------------------------------------------
    // View controller initialization
    //---------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let openCVWrapper = OpenCVWrapper()
        openCVWrapper.isThisWorking()
        
        if initCamera() {
            session.startRunning()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //---------------------------------------------------------------
    // Detection methods
    //---------------------------------------------------------------
    
    // If the button is tapped, call this method
    @IBAction func take(_ sender: Any){
        
        if(detectButton.titleLabel?.text == "Retry")
        {
            // Reset the imageView and reactivate camera
            self.imageView.setNeedsDisplay()
            
            // Reset the button text and BOOL
            detectButton.setTitle("Detect", for: .normal)
            self.taken = false
            
            return
        }
        if(!self.taken){
            
            self.taken = true
            
            // Do not need "break" keywords
            switch passedSelection {
            case "circle":
                
                // Call method to roughly detect circles and display image
                self.imageView.image = OpenCVWrapper.recognizeCircle(self.imageView.image)
                
            case "rectangle":
                
                // Call method to roughly detect square and display image
                self.imageView.image = OpenCVWrapper.recognizeRectangle(self.imageView.image)
                
            case "grayscale":
                
                // Call method to roughly detect square and display image
                self.imageView.image = OpenCVWrapper.convertImage(toGrayscale:(self.imageView.image))
                
            case "faceDetect":
                
                // Call method to roughly detect square and display image
                self.imageView.image = OpenCVWrapper.detectFace(self.imageView.image)
                
            default:
                
                print("Passed segue variable not valid")
                
            }
            
            
            detectButton.setTitle("Retry", for: .normal)
            
        }
    }
    
    //---------------------------------------------------------------
    // Camera methods
    //---------------------------------------------------------------
    
    // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
    func cameraWithPosition(_ position: AVCaptureDevicePosition) -> AVCaptureDevice?
    {
        if let deviceDescoverySession = AVCaptureDeviceDiscoverySession.init(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera],
                                                                             mediaType: AVMediaTypeVideo,
                                                                             position: AVCaptureDevicePosition.unspecified) {
            
            for device in deviceDescoverySession.devices {
                if device.position == position {
                    return device
                }
            }
        }
        
        return nil
    }
    
    // Initialize camera
    func initCamera() -> Bool{
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetMedium
        
        // Test if the cameraPosition has a value and not nil
        if cameraWithPosition(AVCaptureDevicePosition.back) != nil{
            
            // Retrieve camera position and store in variable
            deviceUsed = cameraWithPosition(AVCaptureDevicePosition.back)
            
            print("Device returned successfully")
        }
        else{
            print("Device returned contained nil")
        }
        
        do{
            let myInput: AVCaptureDeviceInput?
            try myInput = AVCaptureDeviceInput(device: deviceUsed);
            
            if session.canAddInput(myInput){
                session.addInput(myInput);
            }
            else{
                return false;
            }
            
            // Initialize variable with a capture output that records video
            output = AVCaptureVideoDataOutput()
            output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)]
            
            // Requests access to device hardware properties
            try deviceUsed.lockForConfiguration()
            deviceUsed.activeVideoMinFrameDuration = CMTimeMake(1,15)
            
            // Stop access to device hardware properties
            deviceUsed.unlockForConfiguration()
            
            let queue: DispatchQueue = DispatchQueue(label: "myqueue", attributes: [])
            output.setSampleBufferDelegate(self, queue: queue)
            
            output.alwaysDiscardsLateVideoFrames = true;
            
        } catch let error as NSError {
            print(error)
            return false
        }
        
        if(session.canAddOutput(output)){
            session.addOutput(output)
        }
        else{
            return false
        }
        
        for connection in output.connections{
            if let conn = connection as? AVCaptureConnection{
                if conn.isVideoOrientationSupported{
                    conn.videoOrientation = AVCaptureVideoOrientation.portrait
                }
            }
        }
        
        return true
    }
    
    // Notifies delegate that a new video frame is written
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
                       from connection: AVCaptureConnection!) {
        
        DispatchQueue.main.async(execute: {
            if(!self.taken){
                let image: UIImage = CameraUtil.imageFromSampleBuffer(buffer: sampleBuffer)
                self.imageView.image = image;
            }
        })
    }
    


}

