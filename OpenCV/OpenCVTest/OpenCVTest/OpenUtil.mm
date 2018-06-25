//
//  OpenUtil.m
//  OpenCVTest
//
//  Created by Miaoz on 2017/6/15.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import "OpenUtil.h"
//using namespace std;
//using namespace cv;

@interface OpenUtil ()
@property (nonatomic, strong) NSMutableArray *planes;
@end

@implementation OpenUtil
static OpenUtil *openUtil;
+ (instancetype)share{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        openUtil = [[self alloc] init];
    });
    return openUtil;
}
-(NSMutableArray *)planes{
    if (!_planes) {
        _planes = [NSMutableArray new];
    }
    
    return _planes;
}
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    
    return cvMat;
}


-(cv::Mat)transformImageWithText{
    NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"lena" ofType:@"jpg"];
//    设置一个图片的存储路径
//    NSString *pathStr = [NSHomeDirectory() stringByAppendingString:@"/Documents/pic.png"];
    const char * aa =[pathStr UTF8String];
    cv::Mat image = cv::imread(aa, CV_LOAD_IMAGE_GRAYSCALE);
//     cv::Mat image = [self cvMatFromUIImage:[UIImage imageNamed:@"WechatIMG1.png"]];
    cv::Mat padded = cv::Mat();
    int m = cv::getOptimalDFTSize(image.rows);  // Return size of 2^x that suite for FFT
    int n = cv::getOptimalDFTSize(image.cols);
    // Padding 0, result is @padded
    copyMakeBorder(image, padded, 0, m-image.rows, 0, n-image.cols, cv::BORDER_CONSTANT, cv::Scalar::all(0));
    padded.convertTo(padded, CV_32F);
    cv::Mat planes[] = { cv::Mat_<float>(padded), cv::Mat::zeros(padded.size(),CV_32F) };
    cv::Mat complexI = cv::Mat();
    //将planes融合合并成一个多通道数组complexI
    merge(planes, 2, complexI);
     //进行幅度运算
    dft(complexI, complexI);
    
        cv::String text = "TestTestTestTestTest";
        cv::Point pt(50,100);
        cv::Scalar color = CV_RGB(0,255,255);
        putText(complexI,text,pt,CV_FONT_HERSHEY_DUPLEX,1.0f,color);
        flip(complexI, complexI, -1);
        putText(complexI,text,pt,CV_FONT_HERSHEY_DUPLEX,1.0f,color);
        flip(complexI, complexI, -1);
    
    // Reconstructing original imae from the DFT coefficients
    cv::Mat invDFT, invDFTcvt;
    cv::idft(complexI, invDFT, cv::DFT_SCALE | cv::DFT_REAL_OUTPUT ); // Applying IDFT
    invDFT.convertTo(invDFTcvt, CV_8U);
    
//    cv::Mat image2 = invDFTcvt;
//    cv::Mat padded2;
//    int m2 = cv::getOptimalDFTSize(image.rows);  // Return size of 2^x that suite for FFT
//    int n2 = cv::getOptimalDFTSize(image.cols);
//    // Padding 0, result is @padded
//    copyMakeBorder(image2, padded2, 0, m2-image2.rows, 0, n2-image2.cols, cv::BORDER_CONSTANT, cv::Scalar::all(0));
//    
//    cv::Mat planes2[] = { cv::Mat_<float>(padded2), cv::Mat::zeros(padded2.size(),CV_32F) };
//    cv::Mat complexI2;
//    //将planes融合合并成一个多通道数组complexI
//    merge(planes2, 2, complexI2);
//    //进行幅度运算
//    dft(complexI2, complexI2);
  
//    dft(invDFTcvt, invDFTcvt);
    
    //show the image
//    cv::imshow("Original Image", img);
//
//        cv::Mat invDFT = cv::Mat();
//        cv::idft(complexI, invDFT, cv::DFT_SCALE | cv::DFT_REAL_OUTPUT, 0);
//        cv::Mat restoredImage = cv::Mat();
//        invDFT.convertTo(restoredImage,0);
    
    
//    split(complexI, planes);
//    magnitude(planes[0], planes[0], planes[1]);
//    cv::Mat magI = planes[0];
//    
//    // => log(1+sqrt(Re(DFT(I))^2+Im(DFT(I))^2))
//    magI += cv::Scalar::all(1);
//    cv::log(magI, magI);
//    
////     crop the spectrum
//    magI = magI(cv::Rect(0, 0, magI.cols & (-2), magI.rows & (-2)));
//    cv::String text = "TestTestTestTestTest";
//    cv::Point pt(50,100);
//    cv::Scalar color = CV_RGB(0,255,255);
//    putText(magI,text,pt,CV_FONT_HERSHEY_DUPLEX,1.0f,color);
//    flip(magI, magI, -1);
//    putText(magI,text,pt,CV_FONT_HERSHEY_DUPLEX,1.0f,color);
//    flip(magI, magI, -1);
    
    
//    cv::Mat invDFT = cv::Mat();
//    cv::idft(magI, invDFT, cv::DFT_SCALE | cv::DFT_REAL_OUTPUT, 0);
//    cv::Mat restoredImage = cv::Mat();
//    invDFT.convertTo(restoredImage,0);

    return invDFTcvt;
}

-(cv::Mat)commonLoad:(cv::Mat)image{
   
    if (!image.data) {
        NSLog(@"图片为nil");
        return image;
    }
    
    cv::Mat padded;
    int m = cv::getOptimalDFTSize(image.rows);  // Return size of 2^x that suite for FFT
    int n = cv::getOptimalDFTSize(image.cols);
    // Padding 0, result is @padded
    copyMakeBorder(image, padded, 0, m-image.rows, 0, n-image.cols, cv::BORDER_CONSTANT, cv::Scalar::all(0));
    
    // Create planes to storage REAL part and IMAGE part, IMAGE part init are 0
    //为虚数部分分配空间，image2是一个二维的向量，一个内容是image1的复制，一个内容全为0
    cv::Mat planes[] = {cv::Mat_<float>(padded), cv::Mat::zeros(padded.size(), CV_32F) };
    cv::Mat complexI;
    merge(planes, 2, complexI);
    //进行傅里叶运算
    dft(complexI, complexI);
    
    return complexI;
}





-(UIImage *)testTest:(cv::Mat)image{
  NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"lena" ofType:@"jpg"];
//    NSString *pathStr = [NSHomeDirectory() stringByAppendingString:@"/Documents/pic.png"];
     const char * a =[pathStr UTF8String];
    // Read as grayscale image
//    cv::Mat imageT = [self cvMatFromUIImage:[UIImage imageNamed:@"lena.jpg"]];
    cv::Mat imageT = cv::imread(a, CV_LOAD_IMAGE_GRAYSCALE);
   
    image = imageT;
    if (!image.data) {
        NSLog(@"图片为nil");
        return nil;
    }
    
    cv::Mat padded;
    int m = cv::getOptimalDFTSize(image.rows);  // Return size of 2^x that suite for FFT
    int n = cv::getOptimalDFTSize(image.cols);
    // Padding 0, result is @padded
    copyMakeBorder(image, padded, 0, m-image.rows, 0, n-image.cols, cv::BORDER_CONSTANT, cv::Scalar::all(0));
    
    // Create planes to storage REAL part and IMAGE part, IMAGE part init are 0
    //为虚数部分分配空间，image2是一个二维的向量，一个内容是image1的复制，一个内容全为0
    cv::Mat planes[2] = {cv::Mat_<float>(padded), cv::Mat::zeros(padded.size(), CV_32F) };
    cv::Mat complexI;
    merge(planes, 2, complexI);
    //进行傅里叶运算
    dft(complexI, complexI);
    
    cv::String text = "TestTestTestTestTest";
    cv::Point pt(50,100);
    cv::Scalar color = CV_RGB(0,255,255);
    putText(complexI,text,pt,CV_FONT_HERSHEY_DUPLEX,1.0f,color);
    flip(complexI, complexI, -1);
    putText(complexI,text,pt,CV_FONT_HERSHEY_DUPLEX,1.0f,color);
    flip(complexI, complexI, -1);
    
    
    // Reconstructing original imae from the DFT coefficients
    cv::Mat invDFT, invDFTcvt;
    cv::idft(complexI, invDFT, cv::DFT_SCALE | cv::DFT_REAL_OUTPUT ); // Applying IDFT
    invDFT.convertTo(invDFTcvt, CV_8U);

    
   /***
    // compute the magnitude and switch to logarithmic scale
    //进行幅度运算
    split(complexI, planes);
    magnitude(planes[0], planes[0], planes[1]);
    cv::Mat magI = planes[0];
    
    // => log(1+sqrt(Re(DFT(I))^2+Im(DFT(I))^2))
    magI += cv::Scalar::all(1);
    log(magI, magI);
    
    // crop the spectrum
    magI = magI(cv::Rect(0, 0, magI.cols & (-2), magI.rows & (-2)));
    
    cv::Mat _magI = magI.clone();
    normalize(_magI, _magI, 1, 0, CV_MINMAX);
    
    //进行剪切和重分部，对于重分部，是让四个顶点集中到中心这一点上，形成四个象限
    // rearrange the quadrants of Fourier image so that the origin is at the image center
    int cx = magI.cols/2;
    int cy = magI.rows/2;
      cv::Mat q0(magI, cv::Rect(0,0,cx,cy));    // Top-Left
    cv::Mat q1(magI, cv::Rect(cx,0,cx,cy));   // Top-Right
    cv::Mat q2(magI, cv::Rect(0,cy,cx,cy));   // Bottom-Left
    cv::Mat q3(magI, cv::Rect(cx,cy,cx,cy));  // Bottom-Right
    
    // exchange Top-Left and Bottom-Right
    cv::Mat tmp;
    q0.copyTo(tmp);
    q3.copyTo(q0);
    tmp.copyTo(q3);
    
    // exchange Top-Right and Bottom-Left
    q1.copyTo(tmp);
    q2.copyTo(q1);
    tmp.copyTo(q2);
    
    normalize(magI, magI, 1, 0, CV_MINMAX);
    
    ****/
    
    
//    imshow("Input image", image);//原始灰度图
//    imshow("Spectrum magnitude before shift frequency", _magI);//频域平移前的频域图像
//    imshow("Spectrum magnitude after shift frequency", magI);//频域中心平移后的频域图像
//    cv::waitKey();
    
    
    
    
//
    
    
    
    
    
    
    
    
    
    cv::Mat cvMat =  invDFTcvt; [self commonLoad:invDFTcvt];;
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
//    UIImage *finalImage = [UIImage imageWithData:data];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    return finalImage;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
//    UIImage *finalImage = [UIImage imageWithData:data];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}



- (UIImage *) MatToUIImage:(cv::Mat)image {
    
    NSData *data = [NSData dataWithBytes:image.data
                                  length:image.elemSize()*image.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (image.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Preserve alpha transparency, if exists
    bool alpha = image.channels() == 4;
    CGBitmapInfo bitmapInfo = (alpha ? kCGImageAlphaLast : kCGImageAlphaNone) | kCGBitmapByteOrderDefault;
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(image.cols,
                                        image.rows,
                                        8,
                                        8 * image.elemSize(),
                                        image.step.p[0],
                                        colorSpace,
                                        bitmapInfo,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}








@end
