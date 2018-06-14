//
//  QHCameraPlugin.h
//  QHLoanLib
//
//  Created by yinxukun on 2016/12/21.
//  Copyright © 2016年 Miaoz. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "QHPlugin.h"
#import <UIKit/UIKit.h>

extern NSString *const QHImage_Key;

@class QHFetchCardViewController;
@interface QHCameraPlugin : QHPlugin

- (void)faceRecognition:(QHInvokedUrlCommand *)command;
- (void)fetchFace:(QHInvokedUrlCommand *)command;
- (void)fetchCard:(QHInvokedUrlCommand *)command;
- (void)pickPhoto:(QHInvokedUrlCommand *)command;

- (void)fetchAlbumPicture:(QHInvokedUrlCommand *)command;

- (QHFetchCardViewController *)invokCardCamera:(CGFloat)photoSize arg1:(NSString *)arg1 agr2:(NSString *)arg2 borderColor:(NSString *)borderColor takePhotoImageB64:(NSString *)takePhotoImageB64 viewController:(UIViewController *)vc;

@end

