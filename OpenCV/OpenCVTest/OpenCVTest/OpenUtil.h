//
//  OpenUtil.h
//  OpenCVTest
//
//  Created by Miaoz on 2017/6/15.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/core.hpp>
#import <opencv2/features2d.hpp>
#import <opencv2/calib3d.hpp>
#import <opencv2/objdetect.hpp>
//#import <opencv2/nonfree/nonfree.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/core.hpp>
#include <iostream>


@interface OpenUtil : NSObject
+ (instancetype)share;
- (cv::Mat)cvMatFromUIImage:(UIImage *)image;
- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
-(cv::Mat)transformImageWithText;
-(UIImage *)testTest:(cv::Mat)image;
@end
