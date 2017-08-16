//
//  GradientView.swift
//  OpenCVTest
//
//  Created by Joshua Wu on 7/24/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let gradientLayer = CAGradientLayer()
    
    override func draw(_ rect: CGRect) {
        gradientLayer.frame = rect
        
        let turquoise_one = UIColor(red: 0/255, green: 245/255, blue: 255/255, alpha: 1.000).cgColor as CGColor
        let darkturquoise = UIColor(red: 122/255, green: 197/255, blue: 205/255, alpha: 1.000).cgColor as CGColor
        
        // UIView top is the first parameter
        gradientLayer.colors = [turquoise_one, darkturquoise]
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
