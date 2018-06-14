//
//  QHFaceCheckDelegate.m
//  LoanLib
//
//  Created by yinxukun on 2016/12/20.
//  Copyright © 2016年 Miaoz. All rights reserved.
//



#import "QHFaceCheckDelegate.h"
#import "UIImage+QH.h"


@interface QHFaceCheckDelegate ()

@end

@implementation QHFaceCheckDelegate

static QHFaceCheckDelegate *delegate = nil;
+ (instancetype)shareDelegate{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegate = [[self alloc] init];
    });
    return delegate;
}

- (instancetype)init{
    if (self = [super init]) {
    }
    return self;
}

/**
 *  等比例缩小
 *
 *  @param sourceImage 原始图片
 *  @param defineWidth 目标图片宽度
 *
 *  @return 缩小后图片
 */
- (UIImage *)qh_imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{

    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    UIGraphicsBeginImageContext(thumbnailRect.size);

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }

    UIGraphicsEndImageContext();
    return newImage;
}

/**
 *  图片方向修正
 *
 *  @param aImage 传入图片
 *
 *  @return 修正方向后返回图片
 */
- (UIImage *)qh_fixOrientation:(UIImage *)aImage {

    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
    {
        return aImage;
    }

    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (aImage.imageOrientation) {

        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:

            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:

            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);

            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:

            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);

            break;
        default:
            break;
    }

    switch (aImage.imageOrientation) {

        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:

            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);

            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:

            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);

            break;

        default:

            break;

    }

    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));

    CGContextConcatCTM(ctx, transform);

    switch (aImage.imageOrientation) {

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:

            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);

            break;

        default:

            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);

            break;

    }

    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);

    return img;
}

@end



