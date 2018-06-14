//
//  QHFetchAlbumPicture.m
//  QHLoanlib
//
//  Created by guopengwen on 2017/11/6.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import "QHFetchAlbumPictureDelegate.h"
#import <Photos/Photos.h>
#import "QHAlertManager.h"
#import "UIImage+QH.h"
#import "QHCode_message.h"


@interface QHFetchAlbumPictureDelegate ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) QHCameraPlugin *cameraPlugin;

@property (nonatomic, strong) QHInvokedUrlCommand *command;


@end

@implementation QHFetchAlbumPictureDelegate

- (void)fetchAlbumPicture:(QHInvokedUrlCommand *)command cameraPlugin:(QHCameraPlugin *)plugin {
    self.command = command;
    self.cameraPlugin = plugin;
    __weak typeof(self) weakself = self;
    [self.cameraPlugin.commandDelegate runInBackground:^{
         __strong typeof(weakself) strongSelf = weakself;
        [strongSelf goToPhotoLibrary];
    }];
}

- (void)goToPhotoLibrary{
     __weak typeof(self) weakself = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        __strong typeof(weakself) strongSelf = weakself;
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied) {
            [strongSelf showAlertMessageWithMessage];
        } else if (status == PHAuthorizationStatusNotDetermined) {
            [strongSelf showAlertMessageWithMessage];
        } else {
            [strongSelf presentImagePickerController];
        }
    }];
}
- (void)presentImagePickerController {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self.cameraPlugin.viewController presentViewController:picker animated:YES completion:^{
            
        }];
        
    });
  
}

- (void)showAlertMessageWithMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        QHAlertManager *alertManager = [QHAlertManager shareAlertManager];
        alertManager.viewController = self.cameraPlugin.viewController;
        [alertManager showAlertMessageWithMessage:@"请在设备的\"设置-隐私-相机\"中允许访问照片。"];
    });
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage * image = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (image) {
        CGFloat photoSize = [[self.command argumentAtIndex:0 withDefault:@"10000"] floatValue];
        
        
        NSString *imgBase64Str =  [image qh_imageCompressionQualityToBase64:photoSize];
        if (imgBase64Str && imgBase64Str.length > 0) {
        
            QHPluginResult *result = [QHPluginResult resultWithStatus:QHCommandStatus_OK messageAsDictionary:@{QHImage_Key: imgBase64Str}];
            [self.cameraPlugin.commandDelegate sendPluginResult:result callbackId:self.command.callbackId];
        } else {
            
            QHPluginResult *result = [QHPluginResult resultWithStatus:QHCommandStatus_ERROR messageAsDictionary:QHMsgImageFailed];
            [self.cameraPlugin.commandDelegate sendPluginResult:result callbackId:self.command.callbackId];
        }
        
      
    } else {
        QHPluginResult *result = [QHPluginResult resultWithStatus:QHCommandStatus_ERROR messageAsDictionary:nil];
        [self.cameraPlugin.commandDelegate sendPluginResult:result callbackId:self.command.callbackId];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
     [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
