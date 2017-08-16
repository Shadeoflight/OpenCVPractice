//
//  OpenCVWrapper.h
//  OpenCVTest
//
//  Created by Joshua Wu on 7/17/17.
//  Copyright © 2017 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

- (void)isThisWorking;

// Wrapper methods
+ (UIImage *)ConvertImageToGrayscale:(UIImage *)image;
+ (UIImage *)recognizeCircle:(UIImage *)image;
+ (UIImage *)recognizeRectangle:(UIImage *)image;
+ (UIImage *)detectFace:(UIImage *)image;

@end
