//
//  MenuViewController.swift
//  OpenCVTest
//
//  Created by Joshua Wu on 7/19/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    //---------------------------------------------------------------
    // General UI outlets
    //---------------------------------------------------------------
    
    @IBOutlet weak var circleButton: UIButton!
    
    //---------------------------------------------------------------
    // Variable to pass by segue
    //---------------------------------------------------------------
    
    var selectionToPass = String()
    
    //---------------------------------------------------------------
    // View controller initialization
    //---------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //---------------------------------------------------------------
    // Button interaction functions
    //---------------------------------------------------------------
    
    @IBAction func circleButtonTap(_ sender: Any){
        
        self.selectionToPass = "circle"
        
        performSegue(withIdentifier: "shapeSelect", sender: nil)
    }
    
    @IBAction func rectangleButtonTap(_ sender: Any){
        
        self.selectionToPass = "rectangle"
        
        performSegue(withIdentifier: "shapeSelect", sender: nil)
    }
    
    @IBAction func grayscaleButton(_ sender: Any){
        
        self.selectionToPass = "grayscale"
        
        performSegue(withIdentifier: "shapeSelect", sender: nil)
    }
    
    @IBAction func faceDetectButton(_ sender: Any){
        
        self.selectionToPass = "faceDetect"
        
        performSegue(withIdentifier: "shapeSelect", sender: nil)
    }
    
    //---------------------------------------------------------------
    // Unwind segue
    //---------------------------------------------------------------
    
    // Unwind segue to this MenuViewController
    @IBAction func unwindToMenuViewController(segue: UIStoryboardSegue) {
        
    }
    
    //---------------------------------------------------------------
    // Pass data with segue
    //---------------------------------------------------------------

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shapeSelect" {
            if let vc = segue.destination as? CameraViewController {
                vc.passedSelection = self.selectionToPass
            }
        }
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
