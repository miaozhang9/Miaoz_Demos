//
//  QHCameraPlugin.m
//  QHLoanLib
//
//  Created by yinxukun on 2016/12/21.
//  Copyright © 2016年 Miaoz. All rights reserved.
//

#import "QHCameraPlugin.h"
#import "QHFetchFaceViewController.h"
#import "QHCode_message.h"
#import <AVFoundation/AVFoundation.h>
#import "QHCode_message.h"
#import "NSFileManager+QH.h"
#import "QHCode_message.h"
#import "NSArray+QHMASAdditions.h"
#import "QHFetchCardViewController.h"
#import "UIImage+QH.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "QHTakePictureDelegate.h"
#import "QHFetchAlbumPictureDelegate.h"
#import "QHLoanDoorBundle.h"
#import <pthread.h>
#import "QHFaceCheckDelegate.h"

#import "QHAlertManager.h"

NSString *const QHImage_Key = @"base64Img";

@interface QHCameraPlugin ()

@property (nonatomic, strong) QHTakePictureDelegate *pickPhotoDelegate;
@property (nonatomic, strong) QHFetchAlbumPictureDelegate *albumPictureDelegate;

@end
@implementation QHCameraPlugin

#pragma mark -- public
- (void)faceRecognition:(QHInvokedUrlCommand *)command{

    __weak typeof(self) weakSelf = self;
    [self qh_canUseCamera:command callBack:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
         [strongSelf qh_faceRecognition:command];
        });
       
    }];
}

- (void)fetchFace:(QHInvokedUrlCommand *)command{
    __weak typeof(self) weakSelf = self;
    [self qh_canUseCamera:command callBack:^{

        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
             [strongSelf qh_fetchFace:command];
        });

    }];
}

- (void)fetchCard:(QHInvokedUrlCommand *)command{
    __weak typeof(self) weakSelf = self;
    [self qh_canUseCamera:command callBack:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
             [strongSelf qh_fetchCard:command];
        });

    }];
}

- (void)pickPhoto:(QHInvokedUrlCommand *)command{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.pickPhotoDelegate = [[QHTakePictureDelegate alloc] init];
        [self.pickPhotoDelegate pickPhoto:command cameraPlugin:self];

    });
}

- (void)fetchAlbumPicture:(QHInvokedUrlCommand *)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.albumPictureDelegate = [[QHFetchAlbumPictureDelegate alloc] init];
        [self.albumPictureDelegate fetchAlbumPicture:command cameraPlugin:self];
    });
}


#pragma mark -- pravite
- (void)qh_canUseCamera:(QHInvokedUrlCommand *)command callBack:(void(^)())callback{

    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!hasCamera) {
        QHPluginResult *result = [QHPluginResult resultWithStatus:QHCommandStatus_ERROR messageAsDictionary:QHMsgNoCamera];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusAuthorized) {
        //
        callback();
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // Explicit user permission is required for media capture, but the user has not yet granted or denied such permission.
        __weak typeof(self) weakSelf = self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                //点击允许访问时调用
                //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                callback();
            }
        }];
    } else {
        QHPluginResult* result = [QHPluginResult resultWithStatus:QHCommandStatus_ERROR messageAsDictionary:QHMsgNoAuthority];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        QHAlertManager *alertManager = [QHAlertManager shareAlertManager];
        alertManager.viewController = self.viewController;
        [alertManager showAlertMessageWithMessage:@"请在设备的\"设置-隐私-相机\"中允许访问相机。"];
    }
}

- (void)qh_fetchFace:(QHInvokedUrlCommand *)command{

    CGFloat photoSize = [[command argumentAtIndex:0 withDefault:@"10000"] floatValue];
    QHFetchFaceViewController *faceCtrl = [[QHFetchFaceViewController alloc] init];
    __weak typeof(self) weakself = self;
    [faceCtrl setFetchFaceComplete:^(UIImage *image, NSDictionary *errorInfo) {
        [weakself.commandDelegate runInBackground:^{
            if (image) {
                QHPluginResult *result = [QHPluginResult resultWithStatus:QHCommandStatus_OK messageAsDictionary:@{QHImage_Key: [image qh_imageCompressionQualityToBase64:photoSize]}];
                [weakself.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
            else{
                QHPluginResult *result = [QHPluginResult resultWithStatus:QHCommandStatus_ERROR messageAsDictionary:errorInfo];
                [weakself.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
        }];
    }];
    [self.viewController presentViewController:faceCtrl animated:YES completion:nil];
}

- (void)qh_faceRecognition:(QHInvokedUrlCommand *)command{
   
    CGFloat photoSize = [[command argumentAtIndex:0 withDefault:@"10000"] floatValue];
 
    QHFaceCheckDelegate *delegate = [QHFaceCheckDelegate shareDelegate];
    if (delegate.startLaunchFaceRecognition) {
        delegate.startLaunchFaceRecognition(@{});
    }
/****
    __weak typeof(self) weakself = self;
    [delegate setFaceRecognitionComplete:^(BOOL isSuccess, UIImage *oriImg, UIImage *faceImg, NSDictionary *otherInfo) {
        // 将获取头像结果返回给js
        [weakself.commandDelegate runInBackground:^{
            
            
            NSDictionary *face_rectDic = otherInfo[@"face_rect"];
            NSMutableDictionary *resultDic = [NSMutableDictionary new];
            if (face_rectDic) {
                
                NSString *centerX = [NSString stringWithFormat:@"%ld",[face_rectDic[@"face_rect_top_left"] integerValue]];
                 NSString *centerY = [NSString stringWithFormat:@"%ld",[face_rectDic[@"face_rect_top_right"] integerValue]];
                NSString *width = [NSString stringWithFormat:@"%ld",[face_rectDic[@"face_rect_width"] integerValue]];
                NSString *height = [NSString stringWithFormat:@"%ld",[face_rectDic[@"face_rect_height"] integerValue]];
                [resultDic setObject:centerX forKey:@"photoCodnt_X"];
                [resultDic setObject:centerY forKey:@"photoCodnt_Y"];
                [resultDic setObject:width forKey:@"photo_W"];
                [resultDic setObject:height forKey:@"photo_H"];
            }
            
            if (faceImg) {
                [resultDic setObject:[faceImg qh_toBase64] forKey:QHImage_Key];
            }
            
            QHPluginResult *result = nil;
            if (isSuccess && faceImg) {
                result = [QHPluginResult resultWithStatus:QHCommandStatus_OK messageAsDictionary:resultDic];
            }
            else{
                result = [QHPluginResult resultWithStatus:QHCommandStatus_ERROR messageAsDictionary:QHMsgFaceRecognitionFailed];
            }
            [weakself.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }];
    
    dispatch_sync_on_main_queue(^{
        PAFaceCheckHome *faceVC = [[PAFaceCheckHome alloc] initWithPAcheckWithTheCountdown:YES andTheAdvertising:@"" number0fAction:@"2" voiceSwitch:YES delegate:delegate];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:faceVC];
        
        [self.viewController presentViewController:nav animated:YES completion:nil];

    });
    
*****/

}

- (void)deleteFile:(QHInvokedUrlCommand *)command{
    for (NSString *arg in command.arguments) {
        if (![arg isKindOfClass:[NSString class]]) {
            return;
        }
        BOOL isSuccess = [NSFileManager qh_deleteFile:arg];
        __weak typeof(self) weakself = self;
        [weakself.commandDelegate runInBackground:^{
            QHPluginResult *result = nil;
            if (isSuccess) {
                result = [QHPluginResult resultWithStatus:QHCommandStatus_OK messageAsString:arg];
            }
            else{
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:QHMsgOther];
                [dict setObject:arg forKey:@"filePath"];
                result = [QHPluginResult resultWithStatus:QHCommandStatus_ERROR messageAsDictionary:[NSMutableDictionary dictionaryWithDictionary:dict]];
            }
            [weakself.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }
}

- (void)qh_fetchCard:(QHInvokedUrlCommand *)command{

    CGFloat photoSize = [[command argumentAtIndex:0 withDefault:@"10000"] floatValue];
    NSString *arg1 = [command argumentAtIndex:1 withDefault:nil];
    NSString *arg2 = [command argumentAtIndex:2 withDefault:nil];
    NSString *lineColor = [command argumentAtIndex:3 withDefault:nil];
    NSString *photoBtnBase64 = [command argumentAtIndex:4 withDefault:nil];
   
    //反面
//    arg2 = @"右右右";
//    arg1 = [[QHLoanDoorBundle imageNamed:@"test"] qh_toBase64];
    //正面
//     arg1 = @"左左左";
//     arg2 = [[QHLoanDoorBundle imageNamed:@"test"] qh_toBase64];;
    //不展示图片
//    arg2 = @"请将您的银行卡置于方框中,请将您的银行卡置于方框中,请将您的银行卡置于方框中";
  QHFetchCardViewController *fetchCardCtrl = [self invokCardCamera:photoSize arg1:arg1 agr2:arg2 borderColor:lineColor takePhotoImageB64:photoBtnBase64  viewController:self.viewController];
    __weak typeof(self) weakself = self;
    [fetchCardCtrl setCameraCompleteAction:^(UIImage *img, NSDictionary *errorInfo) {
        [weakself.commandDelegate runInBackground:^{
            if (img) {
                
                NSString *imgBase64Str =  [img qh_imageCompressionQualityToBase64:photoSize];
                if (imgBase64Str && imgBase64Str.length > 0) {
                    QHPluginResult *result = [QHPluginResult resultWithStatus:QHCommandStatus_OK messageAsDictionary:@{QHImage_Key: imgBase64Str}];
                    [weakself.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                } else {
                    
                    QHPluginResult *result = [QHPluginResult resultWithStatus:QHCommandStatus_ERROR messageAsDictionary:QHMsgImageFailed];
                    [weakself.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                }
               
            }
            else{
                QHPluginResult *result = [QHPluginResult resultWithStatus:QHCommandStatus_ERROR messageAsDictionary:errorInfo];
                [weakself.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
        }];
    }];
   
}


- (QHFetchCardViewController *)invokCardCamera:(CGFloat)photoSize arg1:(NSString *)arg1 agr2:(NSString *)arg2 borderColor:(NSString *)borderColor takePhotoImageB64:(NSString *)takePhotoImageB64 viewController:(UIViewController *)vc {
    //反面
    //    arg1 = [[QHLoanDoorBundle imageNamed:@"guohui"] qh_toBase64];
//        arg2 = @"拍摄国徽面，请将国徽与国徽轮廓对齐";

    //正面
//         arg1 = @"拍摄人像，请将头像与轮廓对齐";
//         arg2 = [[QHLoanDoorBundle imageNamed:@"rentou"] qh_toBase64];;
    //不展示图片
    //    arg2 = @"请将您的银行卡置于方框中,请将您的银行卡置于方框中,请将您的银行卡置于方框中";
    UIImage *argImage = nil;
    NSString *argText = nil;
    BOOL imageLeft = YES;
    //展示用字符串／图片base64用长度区分
    if (arg1.length > 100) {
         arg1 = [[QHLoanDoorBundle imageNamed:@"guohui"] qh_toBase64];
        argImage = [UIImage qh_base64ToImage:arg1];
    }
    else{
        argText = arg1;
    }
    if (arg2.length > 100) {
        arg2 = [[QHLoanDoorBundle imageNamed:@"rentou"] qh_toBase64];;
        argImage = [UIImage qh_base64ToImage:arg2];
        imageLeft = NO;
    }
    else{
        argText = arg2;
    }
    
    NSLog(@"需要相片尺寸%fk", photoSize);
    QHFetchCardViewController *fetchCardCtrl = [[QHFetchCardViewController alloc] init];
    fetchCardCtrl.isIconLeft = imageLeft;
    fetchCardCtrl.argIcon = argImage;
    fetchCardCtrl.argText = argText;
    fetchCardCtrl.borderColor = borderColor;
    fetchCardCtrl.takePhotoImageB64 = takePhotoImageB64;
 
    [vc presentViewController:fetchCardCtrl animated:YES completion:nil];
    
    return fetchCardCtrl;
    
}


static inline void dispatch_sync_on_main_queue(void (^block)()) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}


@end
