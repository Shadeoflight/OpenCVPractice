//
//  OpenCVWrapper.mm
//  OpenCVTest
//
//  Created by Joshua Wu on 7/17/17.
//  Copyright © 2017 None. All rights reserved.
//

//
//  Reference for "recognizeRectangle" method:
//  https://stackoverflow.com/questions/8667818/opencv-c-obj-c-detecting-a-sheet-of-paper-square-detection
//

//---------------------------------------
//  C++ usage
//---------------------------------------

// Import first to avoid conflicts/errors
// Alternative: Comment out the include for "opencv2/stitching.hpp" in opencv.hpp
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h> // UIImageToMat

#import <opencv2/highgui/highgui.hpp>
#import <opencv2/imgproc/imgproc.hpp>


// Wrapper import
#import "OpenCVWrapper.h"

// General imports
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

using namespace std;

@implementation OpenCVWrapper

//---------------------------------------
//  Instance methods
//---------------------------------------

- (void) isThisWorking {
    cout << "OpenCV started" << endl;
}

//---------------------------------------
//  Class methods
//---------------------------------------

+ (UIImage *)ConvertImageToGrayscale:(UIImage *)image {
    
    // Mat class represents n-dimensional array that can be used to store real or complex-valued vectors and matrices
    // Used to store grayscale or color images
    cv::Mat colorMat;
    UIImageToMat(image, colorMat);
    
    // Convert color matrix to grayscale matrix
    cv::Mat greyMatResult;
    cv::cvtColor(colorMat, greyMatResult, cv::COLOR_BGR2GRAY);
    
    // Convert greyMatResult to UIImage
    UIImage *generatedImg = MatToUIImage(greyMatResult);
    
    return generatedImg;
}

//---------------------------------------
//  Helper methods
//---------------------------------------

// Determines the cosine angle
double cosAngle( cv::Point pt1, cv::Point pt2, cv::Point pt3 ) {
    double dx1 = pt1.x - pt3.x;
    double dy1 = pt1.y - pt3.y;
    double dx2 = pt2.x - pt3.x;
    double dy2 = pt2.y - pt3.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

//---------------------------------------
//  Detection methods
//---------------------------------------

+ (UIImage *)recognizeCircle:(UIImage *)image {
    
    // Mat class represents n-dimensional array that can be used to store real or complex-valued vectors and matrices
    // Used to store grayscale or color images
    cv::Mat colorMat;
    UIImageToMat(image, colorMat);
    
    // Convert color matrix to grayscale matrix
    cv::Mat greyMatResult;
    cv::cvtColor(colorMat, greyMatResult, cv::COLOR_BGR2GRAY);
    
    // Reduce the noise to avoid false circle detection
    cv::Mat gaussianBlurMatResult;
    cv::GaussianBlur(greyMatResult, gaussianBlurMatResult, cv::Size(9,9), 2, 2);
    
    vector<cv::Vec3f> circles;
    
    // Apply Hough Transform to find circles - 200, 100, 0, 0
    cv::HoughCircles(gaussianBlurMatResult, circles, CV_HOUGH_GRADIENT, 1, gaussianBlurMatResult.rows/8, 150, 50, 0, 0 );
    
    // Draw the circles detected
    for( size_t i = 0; i < circles.size(); i++)
    {
        cv::Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
        int radius = cvRound(circles[i][2]);
        // circle center
        circle( colorMat, center, 3, cvScalar(0,255,0,255), -1, 8, 0 );
        // circle outline
        circle( colorMat, center, radius, cvScalar(0,0,255,255), 3, 8, 0 );
    }
    
    // Convert greyMatResult to UIImage
    UIImage *generatedImg = MatToUIImage(colorMat);
    
    return generatedImg;
}

// Implemented with StackOverflow code
+ (UIImage *)recognizeRectangle:(UIImage *)image
{
    
    // Mat class represents n-dimensional array that can be used to store real or complex-valued vectors and matrices
    // Used to store grayscale or color images
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    // Declare 2 dimensional array for detected squares
    std::vector<std::vector<cv::Point>> squares;
    
    cv::Mat pyr, timg, gray0(imageMat.size(), CV_8U), gray;
    
    // Initialize threshold variables
    int thresh = 50, thresholdLevelMax = 11;
    
    // Blur and downsample image
    cv::pyrDown(imageMat, pyr, cv::Size(imageMat.cols/2, imageMat.rows/2));
    
    // Blur and upsample image
    cv::pyrUp(pyr, timg, imageMat.size());
    
    // Declare 2 dimensional array for contours
    std::vector<std::vector<cv::Point>> contours;
    
    // Find squares for every color plane of the image
    for( int c = 0; c < 3; c++ ) {
        int ch[] = {c, 0};
        mixChannels(&timg, 1, &gray0, 1, ch, 1);
        
        // Try iterating through different threshold levels
        for( int l = 0; l < thresholdLevelMax; l++ ) {
            
            // Use Canny algorithm instead of zero threshold level to catch squares with gradient shading
            if( l == 0 ) {
                cv::Canny(gray0, gray, 0, thresh, 5);
                
                // Try to remove potential holes between edge segments
                cv::dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
            }
            else {
                gray = gray0 >= (l+1)*255/thresholdLevelMax;
            }
            
            // Find contours and store them in a list
            cv::findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
            
            // Test contours
            std::vector<cv::Point> approx;
            for( size_t i = 0; i < contours.size(); i++ )
            {
                // Approximate contour with accuracy proportional to the contour perimeter
                cv::approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
                if( approx.size() == 4 && fabs(contourArea(cv::Mat(approx))) > 1000 && cv::isContourConvex(cv::Mat(approx))) {
                    double maxCosine = 0;
                    
                    for( int j = 2; j < 5; j++ )
                    {
                        double cosine = fabs(cosAngle(approx[j%4], approx[j-2], approx[j-1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }
                    
                    if( maxCosine < 0.3 ) {
                        squares.push_back(approx);
                    }
                }
            }
        }
    }
    
    // Mat class represents n-dimensional array that can be used to store real or complex-valued vectors and matrices
    // Used to store grayscale or color images
    cv::Mat colorMat;
    UIImageToMat(image, colorMat);
    
    // Draw squares on imageMat
    for ( int i = 0; i< squares.size(); i++ ) {
        // draw contour
        //cv::drawContours(colorMat, squares, i, cv::Scalar(255,0,0,255), 1, 8, std::vector<cv::Vec4i>(), 0, cv::Point());
        
        // draw bounding rect
        //cv::Rect rect = boundingRect(cv::Mat(squares[i]));
        //cv::rectangle(colorMat, rect.tl(), rect.br(), cv::Scalar(0,255,0,255), 2, 8, 0);
        
        // draw rotated rect
        cv::RotatedRect minRect = minAreaRect(cv::Mat(squares[i]));
        cv::Point2f rect_points[4];
        minRect.points( rect_points );
        for ( int j = 0; j < 4; j++ ) {
            cv::line( colorMat, rect_points[j], rect_points[(j+1)%4], cv::Scalar(0,0,255,255), 1, 8 ); // blue
        }
    }
    
    // Convert greyMatResult to UIImage
    UIImage *generatedImg = MatToUIImage(colorMat);
    
    return generatedImg;
}

//---------------------------------------
//  Basic face detection method
//---------------------------------------

+ (UIImage *)detectFace:(UIImage *)image {
    
    // Mat class represents n-dimensional array that can be used to store real or complex-valued vectors and matrices
    // Used to store grayscale or color images
    cv::Mat colorMat;
    UIImageToMat(image, colorMat);
    
    // Convert color matrix to grayscale matrix
    cv::Mat grayMat;
    cv::cvtColor(colorMat, grayMat, cv::COLOR_BGR2GRAY);
    
    // Load classifier from file
    cv::CascadeClassifier classifier;
    NSString* cascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_default"
                                                            ofType:@"xml"];
    classifier.load([cascadePath UTF8String]);
    
    // Initialize variables for classifier
    std::vector<cv::Rect> detections;
    
    const double scalingFactor = 1.1;
    const int minNeighbors = 2;
    const int flags = 0;
    const cv::Size minimumSize(30, 30);
    
    // Detect object of different sizes
    classifier.detectMultiScale(
                                grayMat,
                                detections,
                                scalingFactor,
                                minNeighbors,
                                flags,
                                minimumSize
                                );
    
    // If no detections found
//    if (detections.size() <= 0) {
//        return nil;
//    }

    // Retrieve detected "face" object and draw rectangle around it
    for (auto &face : detections) {
        
        const cv::Point tl(face.x,face.y);
        const cv::Point br = tl + cv::Point(face.width, face.height);
        const cv::Scalar magenta = cv::Scalar(255, 0, 255, 255);
        
        cv::rectangle(colorMat, tl, br, magenta, 4, 8, 0);
    }
    
    // Convert greyMatResult to UIImage
    UIImage *generatedImg = MatToUIImage(colorMat);
    
    return generatedImg;
}

@end














