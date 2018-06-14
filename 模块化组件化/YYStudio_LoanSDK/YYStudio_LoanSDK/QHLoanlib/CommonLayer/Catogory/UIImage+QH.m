//
//  UIImage+QH.m
//  LoanLib
//
//  Created by yinxukun on 2016/12/17.
//  Copyright © 2016年 Miaoz. All rights reserved.
//

#import "UIImage+QH.h"

@implementation UIImage (QH)

#pragma mark  保存图片到document

- (BOOL)qh_saveImageName:(NSString *)imageName callBack:(void(^)(NSString *imagePath))callBack{

    NSString *path = [self qh_getImageDocumentFolderPath];
    NSData *imageData = UIImagePNGRepresentation(self);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/", path];
    // Now we get the full path to the file
    NSString *imageFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    // and then we write it out
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //如果文件路径存在的话
    BOOL bRet = [fileManager fileExistsAtPath:imageFile];
    if (bRet)
    {
        //        NSLog(@"文件已存在");
        if ([fileManager removeItemAtPath:imageFile error:nil])
        {
            //            NSLog(@"删除文件成功");
            if ([imageData writeToFile:imageFile atomically:YES])
            {
                //                NSLog(@"保存文件成功");
                callBack(imageFile);
            }
        }
        else
        {

        }
    }
    else
    {
        BOOL success = [imageData writeToFile:imageFile atomically:YES];
        if (!success)
        {
            [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            if ([imageData writeToFile:imageFile atomically:YES])
            {
                callBack(imageFile);
            }
        }
        else
        {
            callBack(imageFile);
            return YES;
        }

    }
    return NO;
}

#pragma mark  从文档目录下获取Documents路径

- (NSString *)qh_getImageDocumentFolderPath{

    NSString *patchDocument = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [NSString stringWithFormat:@"%@/Images", patchDocument];
}

//1.等比率缩放
- (UIImage *)qh_scaleImageToScale:(float)scaleSize

{
    CGRect rect = CGRectZero;
    rect.size = CGSizeMake(self.size.width * scaleSize, self.size.height * scaleSize);
    rect = CGRectIntegral(rect);
    UIGraphicsBeginImageContext(rect.size);
    [self drawInRect:rect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

//图片裁剪
-(UIImage*)qh_getSubImageInRect:(CGRect)rect
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));

    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);

    return smallImage;
}


//压缩质量后直接返回base64 String
-(NSString *)qh_imageCompressionQualityToBase64:(CGFloat)size{
    
    
    
    //循环次数多，效率低，耗时长。
    CGFloat compression = 1.0;
    UIImage *image = self;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (size <=0)  return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    int i = 0;
    while (data.length/1024 > size && compression > 0 && i < 6) {//最多循环6次
        compression -= 0.01;
        data = UIImageJPEGRepresentation(image, compression); // When compression less than a value, this code dose not work
        i ++ ;
    }
    
   
    NSString *str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    return str;
}

//压缩图片所占内存大小

- (UIImage *)qh_toDiskSize:(CGFloat)size{
    if (size <=0)  return self;

    //循环次数多，效率低，耗时长。
    CGFloat compression = 1;
     UIImage *image = self;
    NSData *data = UIImageJPEGRepresentation(image, compression);

    int i = 0;
    while (data.length/1024 > size && compression > 0 && i < 6) {//最多循环6次
        compression -= 0.01;
        data = UIImageJPEGRepresentation(image, compression); // When compression less than a value, this code dose not work
        i ++ ;
    }
    
    UIImage *resultImage = [UIImage imageWithData:data];
    return resultImage;
    
    
//    //二分法来优化。
//    CGFloat compression = 1;
//    UIImage *image = self;
//    NSData *data = UIImageJPEGRepresentation(image, compression);
//    if (data.length/1024 < size) return image;
//    CGFloat max = 1;
//    CGFloat min = 0;
//    for (int i = 0; i < 6; ++i) {
//        compression = (max + min) / 2;
//        data = UIImageJPEGRepresentation(image, compression);
//        if (data.length/1024 < size * 0.9) {
//            min = compression;
//        } else if (data.length/1024 > size) {
//            max = compression;
//        } else {
//            break;
//        }
//    }
//    UIImage *resultImage = [UIImage imageWithData:data];
//    return resultImage;
    
   
    
//    UIImage *newImage = self;
//    NSData *newImageData = nil;
//    newImageData = UIImageJPEGRepresentation(newImage, 1.0);
//    NSLog(@"____%li____", newImageData.length);
//    if(newImageData.length/1024 > size) {
//        for (CGFloat scale = 1 - 0.01; scale > 0; scale -= 0.01) {
//            newImageData = UIImageJPEGRepresentation(newImage, scale);
//            newImage = [UIImage imageWithData:newImageData];
//            NSLog(@"____%li____", newImageData.length);
//            if (newImageData.length/1024 < size) {
//                break;
//            }
//            else
//                if (newImageData.length/1024 > size) {
//                    scale = scale * 2.0/3.0;
//                }
//        }
//    }
//    NSLog(@"%li", newImageData.length/1024);
    
//    return newImage;
}

//指定宽度按比例缩放
-(UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{

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

    UIGraphicsBeginImageContext(size);

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();

    if(newImage == nil){

        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}


- (NSString *)qh_toBase64{

    NSData *data = UIImagePNGRepresentation(self);
    NSString *str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

    return str;
}

+ (UIImage *)qh_base64ToImage:(NSString *)strEncodeData{

    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}


@end
