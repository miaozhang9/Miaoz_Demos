//
//  VideoViewController.m
//  OpenCViOSTest
//
//  Created by Miaoz on 2017/6/26.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import "VideoViewController.h"
#import "OpenCVUtil.h"
#import <AssetsLibrary/AssetsLibrary.h>
using namespace cv;
using namespace std;

@interface VideoViewController ()<CvVideoCameraDelegate, AVCaptureFileOutputRecordingDelegate>//视频文件输出代理
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) CvVideoCamera* videoCamera;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIButton *button2;

@property (assign,nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;//后台任务标识


@end

@implementation VideoViewController

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
     [self.videoCamera stop];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Opencv视频";
    // Do any additional setup after loading the view.
    NSArray *aryPath=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *strDocPath=[aryPath objectAtIndex:0];
    NSLog(@"%@",strDocPath);
    [self createViews];

}
- (void)createViews {
    if (!_imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 64, self.view.frame.size.width -10, self.view.frame.size.width - 10)];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.layer.borderColor = [UIColor blackColor].CGColor;
        _imageView.layer.borderWidth = 1;
        
    }

    if (!_button) {
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(20, _imageView.frame.size.width + _imageView.frame.origin.y +20, 150, 40);
        [_button setTitle:@"start" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _button.layer.borderColor = [UIColor grayColor].CGColor;
        _button.layer.borderWidth = 1;
        [_button addTarget:self action:@selector(startClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_button2) {
        self.button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        _button2.frame = CGRectMake(self.view.frame.size.width - 20 - 150, _imageView.frame.size.width + _imageView.frame.origin.y +20, 150, 40);
        [_button2 setTitle:@"stop" forState:UIControlStateNormal];
        [_button2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _button2.layer.borderColor = [UIColor grayColor].CGColor;
        _button2.layer.borderWidth = 1;
        [_button2 addTarget:self action:@selector(stopClick) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.button];
    [self.view addSubview:self.button2];
    
    if (!_videoCamera) {
        self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
        _videoCamera.delegate = self;//设置代理
        _videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;//用背面摄像头
        _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480; //截取图片大小
        _videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;//竖屏
        _videoCamera.defaultFPS = 30;
        _videoCamera.grayscaleMode = NO;
         [_videoCamera start];
    }
    

//
    
}

- (void)startClick {
    NSError *error = nil;
    self.videoCamera.recordAssetWriter = [AVAssetWriter assetWriterWithURL:self.videoCamera.videoFileURL fileType:AVFileTypeMPEG4 error:&error];
   NSDictionary *videosetting = @{
     AVVideoCodecKey: AVVideoCodecH264,
     AVVideoWidthKey: @320,
     AVVideoHeightKey: @240,
     AVVideoCompressionPropertiesKey: @{
                                       AVVideoPixelAspectRatioKey: @{
                                               AVVideoPixelAspectRatioHorizontalSpacingKey :  @1,
                                               AVVideoPixelAspectRatioVerticalSpacingKey: @1
                                               },
                                       AVVideoMaxKeyFrameIntervalKey: @1,
                                       AVVideoAverageBitRateKey: @1280000
                                               }
     };
    
    self.videoCamera.recordAssetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videosetting];
    self.videoCamera.recordAssetWriterInput.expectsMediaDataInRealTime = true;
    self.videoCamera.recordAssetWriterInput.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2));
    [self.videoCamera.recordAssetWriter addInput:self.videoCamera.recordAssetWriterInput];
    
    [self.videoCamera.recordAssetWriter startWriting];
}

- (void)stopClick {
    
   
  [self.videoCamera saveVideo];
    [self.videoCamera.recordAssetWriterInput markAsFinished];
//    [self.videoCamera.recordAssetWriter finishWritingWithCompletionHandler:^{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:self.videoCamera.videoFileString]
                                    completionBlock:^(NSURL *assetURL, NSError *error) {
                                        if (error) {
                                            NSLog(@"Save video fail:%@",error);
                                        } else {
                                            NSLog(@"Save video succeed.");
                                        }
                                    }];
//    }];
    
    
   

    NSLog(@"%@",[self.videoCamera videoFileString]);
    
}

- (void)processImage:(cv::Mat&)image{

        [[OpenCVUtil share] addVisibleMarkText:image blindMarkText:@"This is a picture named lena!" point:cv::Point(45,45) fontSize:0.8 scalar:CV_RGB(255,0,0)];

}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {



}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
