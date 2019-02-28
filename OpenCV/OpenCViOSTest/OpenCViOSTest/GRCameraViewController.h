//
//  GRCameraViewController.h
//  OpenCViOSTest
//
//  Created by Miaoz on 2017/6/29.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface GRMotionManager : NSObject

@property(nonatomic, assign)UIDeviceOrientation deviceOrientation;

@property(nonatomic, assign)AVCaptureVideoOrientation videoOrientation;

@end

@interface GRCameraPreview : UIView

@property (strong, nonatomic) AVCaptureSession *captureSessionsion;

@end


@interface GRCameraViewController : UIViewController

@end
