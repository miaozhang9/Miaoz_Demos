//
//  QHFetchAlbumPicture.h
//  QHLoanlib
//
//  Created by guopengwen on 2017/11/6.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHCameraPlugin.h"

@interface QHFetchAlbumPictureDelegate : NSObject

@property (nonatomic, copy) void(^cameraCompleteAction)(UIImage *img, NSDictionary *errorInfo);

- (void)fetchAlbumPicture:(QHInvokedUrlCommand *)command cameraPlugin:(QHCameraPlugin *)plugin;

@end
