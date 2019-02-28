//
//  ViewController.m
//  OpenCViOSTest
//
//  Created by Miaoz on 2017/6/18.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import "ViewController.h"
#import "OpenCVUtil.h"


#define imageName @"IMG_2381.JPG"
#define saveimageName @"/Documents/savepic.png"
@interface ViewController ()<CvPhotoCameraDelegate>
@property (nonatomic, strong)  UIImageView *imgView;
@property (nonatomic, strong)  UIImageView *photoimgView;
@property (strong, nonatomic) CvPhotoCamera * photoCamera;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIButton *button2;
@property (nonatomic, strong) UIButton *button3;
@property (nonatomic, strong) UIButton *button4;
@property (nonatomic, strong) UIButton *button5;
@property (nonatomic, strong) UIButton *button6;
@property (nonatomic, strong) UIButton *button7;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Openc图片";
    NSArray *aryPath=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *strDocPath=[aryPath objectAtIndex:0];
    NSLog(@"%@",strDocPath);
    [self createViews];

}
- (void) viewDidDisappear:(BOOL)animated
{
    [_photoCamera stop];
}

- (void)createViews {

    if (!_imgView) {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 64, (self.view.frame.size.width -10)/1, (self.view.frame.size.width - 10)/1)];
        _imgView.contentMode = UIViewContentModeScaleToFill;
        _imgView.backgroundColor = [UIColor clearColor];
        _imgView.image = self.getImage? self.getImage : [UIImage imageNamed:imageName];
    }
    
    if (!_photoimgView) {
        self.photoimgView = [[UIImageView alloc] initWithFrame:CGRectMake(_imgView.frame.origin.x + _imgView.frame.size.width, 64, (self.view.frame.size.width -10)/2, (self.view.frame.size.width - 10)/2)];
        _photoimgView.contentMode = UIViewContentModeScaleToFill;
        _photoimgView.backgroundColor = [UIColor clearColor];
        _photoimgView.image = self.getImage? self.getImage :[UIImage imageNamed:imageName];
    }

    if (!_button) {
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(40, _imgView.frame.size.width + _imgView.frame.origin.y +20, 150, 40);
        [_button setTitle:@"def盲水印" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _button.layer.borderColor = [UIColor grayColor].CGColor;
        _button.layer.borderWidth = 1;
        [_button addTarget:self action:@selector(fourierConversion) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_button2) {
        self.button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        _button2.frame = CGRectMake(self.view.frame.size.width - 40 - 150, _imgView.frame.size.width + _imgView.frame.origin.y +20, 150, 40);
        [_button2 setTitle:@"显示盲水印图" forState:UIControlStateNormal];
        [_button2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _button2.layer.borderColor = [UIColor grayColor].CGColor;
        _button2.layer.borderWidth = 1;
        [_button2 addTarget:self action:@selector(reverseFourier) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    if (!_button4) {
        self.button4 = [UIButton buttonWithType:UIButtonTypeCustom];
        _button4.frame = CGRectMake(40, _button.frame.size.height + _button.frame.origin.y +20, 150, 40);
        [_button4 setTitle:@"matrixAdd" forState:UIControlStateNormal];
        [_button4 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _button4.layer.borderColor = [UIColor grayColor].CGColor;
        _button4.layer.borderWidth = 1;
        [_button4 addTarget:self action:@selector(matrixAdd) forControlEvents:UIControlEventTouchUpInside];
    }

    if (!_button5) {
        self.button5 = [UIButton buttonWithType:UIButtonTypeCustom];
        _button5.frame = CGRectMake(_button2.frame.origin.x,_button4.frame.origin.y, 150, 40);
        [_button5 setTitle:@"matrixRemove" forState:UIControlStateNormal];
        [_button5 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _button5.layer.borderColor = [UIColor grayColor].CGColor;
        _button5.layer.borderWidth = 1;
        [_button5 addTarget:self action:@selector(matrixRemove) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_button6) {
        self.button6 = [UIButton buttonWithType:UIButtonTypeCustom];
        _button6.frame = CGRectMake(40,_button4.frame.size.height + _button4.frame.origin.y +20, 150, 40);
        [_button6 setTitle:@"添加明水印" forState:UIControlStateNormal];
        [_button6 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _button6.layer.borderColor = [UIColor grayColor].CGColor;
        _button6.layer.borderWidth = 1;
        [_button6 addTarget:self action:@selector(addVisibleMarkText) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_button7) {
        self.button7 = [UIButton buttonWithType:UIButtonTypeCustom];
        _button7.frame = CGRectMake(_button5.frame.origin.x,_button6.frame.origin.y , 150, 40);
        [_button7 setTitle:@"去除明水印" forState:UIControlStateNormal];
        [_button7 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _button7.layer.borderColor = [UIColor grayColor].CGColor;
        _button7.layer.borderWidth = 1;
        [_button7 addTarget:self action:@selector(removeVisibleMarkText) forControlEvents:UIControlEventTouchUpInside];
    }

    if (!_button3) {
        self.button3 = [UIButton buttonWithType:UIButtonTypeCustom];
        _button3.frame = CGRectMake(40,_button6.frame.size.height + _button6.frame.origin.y +20, 150, 40);
        [_button3 setTitle:@"takePhoto" forState:UIControlStateNormal];
        [_button3 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _button3.layer.borderColor = [UIColor grayColor].CGColor;
        _button3.layer.borderWidth = 1;
        [_button3 addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    }

    
    if (!_photoCamera) {
        self.photoCamera = [[CvPhotoCamera alloc] initWithParentView:self.photoimgView];
        _photoCamera.delegate = self;//设置代理
        _photoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;//用背面摄像头
        _photoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetPhoto; //截取图片大小
        _photoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;//竖屏
        [_photoCamera start];
        
    }

   
    [self.view addSubview:self.button];
    [self.view addSubview:self.button2];
//    [self.view addSubview:self.button3];
    [self.view addSubview:self.button4];
    [self.view addSubview:self.button5];
    [self.view addSubview:self.button6];
    [self.view addSubview:self.button7];
    [self.view addSubview:self.imgView];
    [self.view addSubview:self.photoimgView];

}

- (void)takePhoto {
    [self.photoCamera takePicture];
}
- (void)photoCamera:(CvPhotoCamera*)photoCamera capturedImage:(UIImage *)image {

//    self.imgView.image = image;
    NSString *imagePath = [NSHomeDirectory() stringByAppendingString:saveimageName];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
}

- (void)photoCameraCancel:(CvPhotoCamera*)photoCamera {

}

- (void)removeVisibleMarkText {

    cv::Mat orignMat = [[OpenCVUtil share] cvMatFromUIImage:self.imgView.image];//
    cv::Mat getMat = [[OpenCVUtil share] removeVisibleMarkText:orignMat scalar:CV_RGB(255,255,255)];
    UIImage *image = [[OpenCVUtil share] UIImageFromCVMat:getMat];
    self.imgView.image = image;
}

- (void)addVisibleMarkText{
//     NSString *imagePath = [NSHomeDirectory() stringByAppendingString:saveimageName];
//     UIImage *imagetmp = [UIImage imageWithContentsOfFile:imagePath];
     cv::Mat orignMat = [[OpenCVUtil share] cvMatFromUIImage:self.getImage? self.getImage :[UIImage imageNamed:imageName]];//
     cv::Mat getMat = [[OpenCVUtil share] addVisibleMarkText:orignMat blindMarkText:@"XXXX" point:cv::Point(45,45) fontSize:0.8 scalar:CV_RGB(255,255,255)];
     UIImage *image = [[OpenCVUtil share] UIImageFromCVMat:getMat];
     self.imgView.image = image;
    
}
- (void)matrixAdd {
    //傅里叶打水印
    cv::Mat orignMat = [[OpenCVUtil share] cvMatFromUIImage:self.getImage? self.getImage :[UIImage imageNamed:imageName]];//
//    [[OpenCVUtil share] transformImageWithText:orignMat blindMarkText:@"Test" point:cv::Point(45,45) fontSize:0.8 scalar:CV_RGB(255,255,255)];
//    cv::Mat cvMat = [[OpenCVUtil share] antitransformImage];
    UIImage *image = [[OpenCVUtil share] UIImageFromCVMat:orignMat];
    
    //把打水印的图片添加信息
    cv::Mat matTmp = [[OpenCVUtil share] addMessageMatrixToOriginalMatRow:orignMat messageDic:@{@"imageMD5":[[OpenCVUtil share] getImageMatrixMD5String:orignMat],@"data":@"data"}];
    self.imgView.image = [[OpenCVUtil share] UIImageFromCVMat:matTmp];
    
    NSString *imagePath = [NSHomeDirectory() stringByAppendingString:saveimageName];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(self.imgView.image) writeToFile:imagePath atomically:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"添加完成" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alertView show];

}

- (void)matrixRemove {
     //从保存的打水印并添加信息的图片获取信息并对比
    NSString *imagePath = [NSHomeDirectory() stringByAppendingString:saveimageName];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
//    UIImage *image = [UIImage imageNamed:imageName];
    cv::Mat orignMat = [[OpenCVUtil share] cvMatFromUIImage:image];
    [[OpenCVUtil share] removeMessageMatrixToOriginalMatRow:orignMat getRestoreData:^(NSDictionary *dataDic, cv::Mat restoreMat) {
        
         NSLog(@"%@",dataDic);
        UIImage *image = [[OpenCVUtil share] UIImageFromCVMat:restoreMat];
        self.imgView.image = image;

        if ([dataDic[@"imageMD5"] isEqualToString:[[OpenCVUtil share] getImageMatrixMD5String:restoreMat]]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"对比success" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}


-(void)extractWatermarkImage {

//    cv::Mat matTmp = [[OpenCVUtil share] extractImage];
//     self.imgView.image = [[OpenCVUtil share] UIImageFromCVMat:matTmp];
    
   
    
}
- (void)fourierConversion {
    
    cv::Mat orignMat = [[OpenCVUtil share] cvMatFromUIImage:self.getImage? self.getImage :[UIImage imageNamed:imageName]];//
//        NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"image1" ofType:@"jpg"];
//        cv::Mat orignMat = cv::imread( [pathStr UTF8String], CV_LOAD_IMAGE_COLOR );
    cv::Scalar color = CV_RGB(0,255,255);
    [[OpenCVUtil share] transformImageWithText:orignMat blindMarkText:@"Test" point:cv::Point(45,45) fontSize:0.8 scalar:color];
    cv::Mat cvMat = [[OpenCVUtil share] antitransformImage];
    self.imgView.image = [[OpenCVUtil share] UIImageFromCVMat:cvMat];
    
}

- (void)reverseFourier {
    
    cv::Mat cvMat = [[OpenCVUtil share] antitransformImage];
    cvMat = [[OpenCVUtil share] transformImage:cvMat];
    self.imgView.image = [[OpenCVUtil share] UIImageFromCVMat:cvMat];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
