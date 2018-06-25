//
//  OpenCVUtil.m
//  OpenCViOSTest
//
//  Created by Miaoz on 2017/6/18.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import "OpenCVUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import "Base64.h"
using namespace cv;
using namespace std;

@interface OpenCVUtil ()
{
    cv::Mat _complexImage;
//    Mat planes[100];
    vector<Mat> planes;
    vector<Mat> allPlanes;
    
   
}
@end

@implementation OpenCVUtil
static OpenCVUtil *openCVUtil;
+ (instancetype)share{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        openCVUtil = [[self alloc] init];
    });
    return openCVUtil;
}

- (UIImage *)imageWithImage:(UIImage*)image
               scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    

//    UIImage *tmpImage = [self imageWithImage:image scaledToSize:CGSizeMake(600, 600)];
    UIImage *tmpImage = image;
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(tmpImage.CGImage);
    CGFloat cols = tmpImage.size.width;
    CGFloat rows = tmpImage.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4);
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,cols,rows,8,cvMat.step[0],colorSpace,kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), tmpImage.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}


- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                             cvMat.rows,8, 8 * cvMat.elemSize(), cvMat.step[0],colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false,kCGRenderingIntentDefault);
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1);
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,cols,rows,8,cvMat.step[0],colorSpace,kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}


#pragma mark --- public
//转换
- (cv::Mat)transformImage:(cv::Mat)image {
    // planes数组中存的通道数若开始不为空,需清空.
    if (!planes.empty()) {
        planes.clear();
    }
    
//    split(image,allPlanes);
//    Mat image2 = allPlanes[0];
//    
//    // optimize the dimension of the loaded image
//    Mat padded = [self optimizeImageDim:image2];
   
     Mat padded = [self splitSrc:image];
    padded.convertTo(padded, CV_32F);
    // prepare the image planes to obtain the complex image
    planes.push_back(padded);
    planes.push_back(cv::Mat::zeros(padded.size(), CV_32F));
    // prepare a complex image for performing the dft
    merge(planes, _complexImage);
    // dft
    dft(_complexImage, _complexImage);
    // optimize the image resulting from the dft operation
    Mat magnitude = [self createOptimizedMagnitude:_complexImage];
    
    planes.clear();
    return magnitude;
}


- (void)transformImageWithText:(cv::Mat) image blindMarkText:(NSString *) blindMarkText point:(cv::Point) point fontSize:(double)fontSize scalar:(cv::Scalar) scalar {
    // planes数组中存的通道数若开始不为空,需清空.
    if (!planes.empty()) {
        planes.clear();
    }
//    split(image,allPlanes);
//    cv::Mat grayMat = allPlanes[0];
    //获取灰色通道
//    //cv::cvtColor(image, grayMat, COLOR_RGB2GRAY);
    // optimize the dimension of the loaded image
//    Mat padded = [self optimizeImageDim:grayMat];

    Mat padded = [self splitSrc:image];
    
    padded.convertTo(padded, CV_32F);
    // prepare the image planes to obtain the complex image
    planes.push_back(padded);
    planes.push_back(cv::Mat::zeros(padded.size(), CV_32F));
    // prepare a complex image for performing the dft
    merge(planes, _complexImage);
    // dft
    dft(_complexImage, _complexImage);
    // 频谱图上添加文本
    //Core.putText(complexImage, watermarkText, point, Core.FONT_HERSHEY_DUPLEX, fontSize, scalar,2);
    putText(_complexImage, [blindMarkText UTF8String], point, CV_FONT_HERSHEY_DUPLEX, fontSize, scalar);
    flip(_complexImage, _complexImage, -1);
    putText(_complexImage, [blindMarkText UTF8String], point, CV_FONT_HERSHEY_DUPLEX, fontSize, scalar);
    flip(_complexImage, _complexImage, -1);
    
    planes.clear();
}
//idft
- (cv::Mat)antitransformImage {
    
    Mat invDFT ;
    idft(_complexImage, invDFT, DFT_SCALE | DFT_REAL_OUTPUT, 0);
    Mat restoredImage ;
    invDFT.convertTo(restoredImage, CV_8U);
    //合并多通道
    allPlanes.erase(allPlanes.begin());
    allPlanes.insert(allPlanes.begin(), restoredImage);
    Mat lastImage ;
    merge(allPlanes,lastImage);

    return lastImage;
}

- (cv::Mat)extractImage{
    UIImage* image=[UIImage imageNamed:@"imagebig.png"];
    cv::Mat orignMat = [[OpenCVUtil share] cvMatFromUIImage:image];
    cv::Mat orgnMatSingle = [self splitSrc:orignMat];
    
    cv::Mat cvMat = [[OpenCVUtil share] antitransformImage];
//    cvMat = [[OpenCVUtil share] transformImage:cvMat];
   
//    cv::Mat image2 = cvMat - orgnMatSingle;

   
    Mat image2 =  [[OpenCVUtil share] transformImage:cvMat] -  [[OpenCVUtil share] transformImage:orgnMatSingle];;

    
    return image2;
}



- (cv::Mat)removeVisibleMarkText:(cv::Mat) image scalar:(cv::Scalar) scalar {
    
    Mat dstImg = image.clone();
      Mat_<Vec4b>::iterator it = dstImg.begin<Vec4b>();
     Mat_<Vec4b>::iterator itend = dstImg.end<Vec4b>();
    for(; it != itend; it++)
    {
        if((*it)[2] == 255)//对红色分量做阈值处理
        {
            (*it)[0] = 0;
            (*it)[1] = 0;
            //(*it)[2] = 255;//红色分量保持不变
        }
        
        else
        {
            (*it)[0] = 0;
            (*it)[1] = 0;
            (*it)[2] = 0;
        }
    }
    
    
    Mat grayMaskImg;
    Mat element = getStructuringElement(MORPH_RECT, cv::Size(7, 7));
    dilate(dstImg, dstImg, element);//膨胀后结果作为修复掩膜
    //将彩色图转换为单通道灰度图，最后一个参数为通道数
    cvtColor(dstImg, grayMaskImg, CV_BGR2GRAY, 1);
    //修复图像的掩膜必须为8位单通道图像
    Mat inpaintedImage;
    cvtColor(image , image , CV_RGBA2RGB);
    //该方法只能单通道或三通道使用
    inpaint(image, grayMaskImg, inpaintedImage, 3, INPAINT_TELEA);

    
    return inpaintedImage;

    
}

- (cv::Mat)addVisibleMarkText:(cv::Mat) image blindMarkText:(NSString *) blindMarkText point:(cv::Point) point fontSize:(double)fontSize scalar:(cv::Scalar) scalar {
//    CvFont font;
//    cvInitFont(&font,CV_FONT_HERSHEY_COMPLEX, 0.5, 0.5, 1, 2, 8);
//     cout << image<<endl;
     putText(image, [blindMarkText UTF8String], point, CV_FONT_HERSHEY_DUPLEX, fontSize, scalar);

    return image;
}

- (cv::Mat)addMessageMatrixToOriginalMatRow:(cv::Mat) oriMat messageDic:(NSDictionary *)dataDic{
    
   
//     cout << oriMat<<endl;
    
    // NSString to ASCII
//    NSString *string = @"98";
//    NSInteger asciiCode = [string characterAtIndex:0]; //65
////
//     NSLog(@"%@",[NSString stringWithFormat:@"%ld",asciiCode]);
    //ASCII to NSString
//    int asciiCode = 57;
//    NSString *string =[NSString stringWithFormat:@"%c",asciiCode]; //A
//    NSLog(@"%@",string);
    /**对dataDic进行base64编码**/
    NSString *msgdata = [self base64EncodeString:[self convertToJSONData:dataDic]];
    if (!msgdata || msgdata.length <= 0) {
        NSLog(@"--------------------------message为空");
        return oriMat;
    }
    
    /**处理base64编码后String的length**/
    Mat cloneMat = oriMat.clone();
    NSMutableArray *messageCountArray = [NSMutableArray new];
    NSString *messageCountStr = [NSString stringWithFormat:@"%lu",(unsigned long)msgdata.length];
    NSMutableString *tmpString = [NSMutableString new];
    for (int o = 0;  o < messageCountStr.length; o ++) {
       
        if (o < 2) {
            NSString *str =   [messageCountStr substringWithRange:NSMakeRange(messageCountStr.length -1 - o, 1)];
            [messageCountArray addObject:str];
        } else {
            NSString *str =   [messageCountStr substringWithRange:NSMakeRange(o - 2, 1)];
            [tmpString appendString:str];
            if (o == messageCountStr.length - 1) {
                [messageCountArray addObject:tmpString];
                
            }
        }
    }
    
   NSMutableArray * getmessageCountArray = [NSMutableArray arrayWithArray:[[messageCountArray reverseObjectEnumerator] allObjects]];
    switch (getmessageCountArray.count) {
        case 0:
            [getmessageCountArray addObjectsFromArray:@[@255,@255,@255,@255]];
            break;
        case 1:
            [getmessageCountArray insertObject:@255 atIndex:0];
            [getmessageCountArray insertObject:@255 atIndex:1];
            [getmessageCountArray insertObject:@255 atIndex:3];
           
            break;
        case 2:
            [getmessageCountArray insertObject:@255 atIndex:0];
            [getmessageCountArray insertObject:@255 atIndex:3];
            break;
        case 3:
            [getmessageCountArray insertObject:@255 atIndex:3];
            break;
            
        default:
            break;
    }
    
    /**根据base64编码后String长度和Mat的矩阵长度计算添加的row数**/
    NSInteger getMsgRows = (msgdata.length + 4) / (cloneMat.cols*cloneMat.channels()/4*3) ;
    if ((msgdata.length  + 4 ) % (cloneMat.cols*cloneMat.channels()/4*3) != 0) {
        getMsgRows +=1;
    }

    /**添加的row数来遍历base64编码后String转成unichar遍历添加到矩阵**/
    NSString *getLastMsgData;
    NSMutableString *tmpStr = [NSMutableString stringWithFormat:@""];
    for (int i = 0; i < getMsgRows; i++) {
        NSInteger length = 0;
        length = cloneMat.cols*cloneMat.channels()/4*3;
        //如果msgdata总长度 - 上一次添加的string长度 大于 Mat的每row的长度时 说明一行不够填充全部数据需添加更多行
        if (msgdata.length - tmpStr.length > length) {
            getLastMsgData = [msgdata substringWithRange:NSMakeRange(i* length, length)];
            [tmpStr appendString:getLastMsgData];
        } else {
            //如果msgdata总长度 - 上一次添加的string长度 <= Mat的每row的长度时 说明这一行就能填充完数据
            getLastMsgData = [msgdata substringWithRange:NSMakeRange(i* length, msgdata.length - i * length)];
        }
        //创建新的Mat并填充该mat的数据
        Mat messageMat = Mat(1, cloneMat.cols, cloneMat.type(), {0,0,0,0});
        uchar* pxvecm = messageMat.ptr<uchar>(0);
        NSInteger count = cloneMat.cols*cloneMat.channels();
        int k = 0;
        for (int j = 0; j < count; j++)
        {
            NSInteger tmpIndex = j - (j+1)/4;
            if ( tmpIndex < getLastMsgData.length) {
                
                if ((j+1)%4 == 0) {
                    ////每四个一组，每组第四位
                    pxvecm[j] = 255;
                }else {
                    //每四个一组，每组前三位
                    pxvecm[j] = [getLastMsgData characterAtIndex:tmpIndex];
                    
                }
                
            } else {
                //下边代码只有char填充不满该行矩阵时候才走
                //把String的长度数值添加到最后一行的最后一个矩阵上的前三位
                if (i == getMsgRows-1 && j > count - 5) {
                    NSString *tmpStr = getmessageCountArray[k];
                    pxvecm[j] = tmpStr.integerValue ;
                    k ++;
                    
                } else {
                    //最后一行的矩阵有多余的时候填充为0
                    pxvecm[j] = 0;
                }
            }
            
        }
        //把新建的矩阵添加到cloneMat的最后一行
        cloneMat.push_back(messageMat);
        
    }
//    cout << cloneMat<<endl;

    return cloneMat;
   
//    Mat C = (Mat_<double>(3,3) << 0, -1, 0, -1, 5, -1, 0, -1, 0);
//    cout << "Total matrix:" << endl;
//    cout << C << endl;
//    
//    Mat A = (Mat_<double>(1,3) << 2, 3, 8);
//    
//    C.push_back(A);
////    Mat dsttemp = C.row(2);             //M为目的矩阵 n*m
////    A.copyTo(dsttemp);       //
////    cout << dsttemp<<endl;
//    cout << C<<endl;
    
}

- (void)removeMessageMatrixToOriginalMatRow:(cv::Mat)oriMat getRestoreData:(void(^)(NSDictionary *dataDic,cv::Mat restoreMat))successBlock {

//     cout << oriMat<<endl;
    /**创建**/
    Mat cloneMat = oriMat.clone();
    /**获取最后一行的最后一个矩阵并拿出要取出信息字符的数量**/
    Mat getLastRowMat = cloneMat.row(cloneMat.rows - 1);
    uchar* pxvect = getLastRowMat.ptr<uchar>(0);
    NSMutableString *countStr = [NSMutableString new];
    for (int i = 0; i< 4; i ++ ) {
        NSInteger integer =  pxvect[getLastRowMat.cols*getLastRowMat.channels()-4+i];
        if (integer != 255) {
            [countStr appendString:[NSString stringWithFormat:@"%lu",integer]];
        }
       
    }
     /**根据信息字符长度和Mat的矩阵长度计算添加的row数**/
    Mat matArray = Mat();
    NSInteger getMsgRows = (countStr.integerValue + 4 )/ (cloneMat.cols*cloneMat.channels()/4*3 );
    if ((countStr.integerValue + 4) % (cloneMat.cols*cloneMat.channels()/4*3) != 0) {
        getMsgRows +=1;
    }
   /**根据行数获取字符所在的矩阵并添加到新的Mat**/
    for (int i = (int)getMsgRows; i > 0 ; i --) {
        matArray.push_back(cloneMat.row(cloneMat.rows - i));
    }
    
    /**从字符矩阵获取到添加的信息char**/
    NSMutableString *lastString = [NSMutableString new];
    for (int i = 0; i < matArray.rows; i++) {
        uchar *pxvec = matArray.ptr(i) ;
        for (int j = 0; j < cloneMat.cols*cloneMat.channels(); j++)
        {
            
            NSInteger tmpInt = pxvec[j];
            //如果是0则跳出循环
            if (tmpInt == 0) {
                break;
            }
            //不是255说明是填充的char则取出
            if (tmpInt != 255) {
                NSString *tmpStr =  [NSString stringWithFormat:@"%c",pxvec[j]];
                [lastString appendString:tmpStr];
            }
            
        }
    }
     /**删除字符矩阵**/
    for (int i = 0; i< getMsgRows; i++) {
        cloneMat.pop_back();
    }
    
//    cout << cloneMat<<endl;
    NSLog(@"%@",lastString);
     /**对获取的总String进行base64进行解码**/
    NSString *dataStr =  [self base64DecodeString:lastString];
    NSLog(@"%@",dataStr);
    if (successBlock) {
        successBlock( [self dictionaryWithJsonString:dataStr], cloneMat);
    }
  
}

-(NSString *)base64ToMd5WithImage:(UIImage *)img path:(NSString *)path {
    
    NSData *data = nil;
    if (path) {
        data =  [NSData dataWithContentsOfFile:path];
    } else {
     data = UIImagePNGRepresentation(img);//836132
    }

 
    NSString *image64 = [data base64EncodedString];
    return [self MD5:image64];
//     return [self getMD5WithData:data];
}

- (NSString *)getImageMatrixMD5String:(cv::Mat)mat {
   
    NSMutableString *sb = [NSMutableString new];
   
    for (int i = 0; i < mat.rows; i++) {
        for (int j = 0; j < mat.cols; j++) {
            //                double[] d = mat.get(i, j);
            //                int v = (int)(d[0] + d[1] + d[2] + d[3]) / 4;
           NSInteger tmpInteger =  mat.at<cv::Vec4b>(i,j)[0];
           [sb appendFormat:@"%ld",(long)tmpInteger];
        }
        
    }
   NSString *md5Str = [self MD5:sb];
    return md5Str;
}

- (NSString *)MD5:(NSString *)mdStr
{
    const char *original_str = [mdStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

- (NSString*)getMD5WithData:(NSData *)data{
    const char* original_str = (const char *)[data bytes];
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    CC_MD5(original_str, (uint)strlen(original_str), digist);
    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [outPutStr appendFormat:@"%02x",digist[i]];//小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
    }
    
    //也可以定义一个字节数组来接收计算得到的MD5值
    //    Byte byte[16];
    //    CC_MD5(original_str, strlen(original_str), byte);
    //    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    //    for(int  i = 0; i<CC_MD5_DIGEST_LENGTH;i++){
    //        [outPutStr appendFormat:@"%02x",byte[i]];
    //    }
    //    [temp release];
    
    return [outPutStr lowercaseString];
    
}

-(NSString*)fileMD5:(NSString*)path


{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    if( handle== nil ) return @"ERROR GETTING FILE MD5"; // file didnt exist
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    
    BOOL done = NO;
    while(!done)
    {
        NSData* fileData = [handle readDataOfLength:256];
        //        CHUNK_SIZE
        CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
        if( [fileData length] == 0 ) done = YES;
     }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
         digest[0], digest[1],
         digest[2], digest[3],
         digest[4], digest[5],
         digest[6], digest[7],
         digest[8], digest[9],
         digest[10], digest[11],
         digest[12], digest[13],
         digest[14], digest[15]];
    return s;
}

-(NSString *)base64EncodeString:(NSString *)string

{
   //1.先把字符串转换为二进制数据
    NSString *data = [string base64EncodedString];
    
    return data;
    
}



//对base64编码后的字符串进行解码

-(NSString *)base64DecodeString:(NSString *)string

{
    //1.将base64编码后的字符串『解码』为二进制数据
    NSData *data = [[NSData alloc]initWithBase64EncodedString:string options:NSDataBase64Encoding64CharacterLineLength];
    //2.把二进制数据转换为字符串返回
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
}
//字典转Json字符串
- (NSString*)convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}
//JSON字符串转化为字典
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

-(void)savephotoToDocumentFile:(NSString *)pathImage {
    
    //此处首先指定了图片存取路径（默认写到应用程序沙盒 中）
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    //并给文件起个文件名
    NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"pathImage"];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    if (blHave) {
        NSLog(@"already have");
        [self deleteFile];
//        return ;
    }
    //此处的方法是将图片写到Documents文件中 如果写入成功会弹出一个警告框,提示图片保存成功
    NSString *strPathOld = [[NSBundle mainBundle] pathForResource:@"pin" ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:strPathOld];
//    [UIImagePNGRepresentation(self.imgView.image) writeToFile:imagePath atomically:YES];

    BOOL result = [data writeToFile:uniquePath atomically:YES];
    if (result) {
        NSLog(@"success");
    }else {
        NSLog(@"no success");
    }
    
}

// 删除沙盒里的文件
-(void)deleteFile {
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    //文件名
    NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"pin.png"];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    if (!blHave) {
        NSLog(@"no  have");
        return ;
    }else {
        NSLog(@" have");
        BOOL blDele= [fileManager removeItemAtPath:uniquePath error:nil];
        if (blDele) {
            NSLog(@"dele success");
        }else {
            NSLog(@"dele fail");
        }
        
    }
}

#pragma mark --- private
//分离多通道获取B通道
- (cv::Mat)splitSrc:(cv::Mat) image {
    //清空allPlanes
    if (!allPlanes.empty()) {
        allPlanes.clear();
    }
    //分离image通道到allPlanes
    //先优化
    Mat optimizeImage = [self optimizeImageDim:image];
    split(optimizeImage,allPlanes);
    Mat padded =  Mat();
    if (allPlanes.size()>1) {
        for (int i = 0; i < allPlanes.size();i++) {
            if (i == 0) {
                // optimize the dimension of the loaded image
                //分离之前优化，这里不需要优化
                  padded = allPlanes[i];
//                padded = [self optimizeImageDim:allPlanes[i]];
                break;
            }
        }
    } else {
        padded = [self optimizeImageDim:image];
    }
    return padded;
}

/**
 * 为加快傅里叶变换的速度，对要处理的图片尺寸进行优化
 *
 * @param image
 *            the {@link Mat} to optimize
 * @return the image whose dimensions have been optimized
 */
- (cv::Mat)optimizeImageDim:(cv::Mat)image {
    
    // init
    Mat padded =  Mat();
    // get the optimal rows size for dft
    int addPixelRows = getOptimalDFTSize(image.rows);
    // get the optimal cols size for dft
    int addPixelCols = getOptimalDFTSize(image.cols);
    // apply the optimal cols and rows size to the image
    copyMakeBorder(image, padded, 0, addPixelRows - image.rows, 0, addPixelCols - image.cols,
                   BORDER_CONSTANT, Scalar::all(0));
    
    return padded;
    
}

- (cv::Mat)createOptimizedMagnitude:(cv::Mat)complexImage {
    // init
    vector<Mat> newPlanes = {};
    Mat mag =  Mat();
    // split the comples image in two planes
    split(complexImage, newPlanes);
    // compute the magnitude
    magnitude(newPlanes[0], newPlanes[1], mag);
    
    // move to a logarithmic scale
    add(Mat::ones(mag.size(), CV_32F), mag, mag);
    log(mag, mag);
    // optionally reorder the 4 quadrants of the magnitude image
    [self shiftDFT:mag];
    // normalize the magnitude image for the visualization since both JavaFX
    // and OpenCV need images with value between 0 and 255
    // convert back to CV_8UC1
    mag.convertTo(mag, CV_8UC1);
    normalize(mag, mag, 0, 255, NORM_MINMAX, CV_8UC1);
    
    return mag;
}

- (void)shiftDFT:(cv::Mat)image {
    
    image = image(cv::Rect(0, 0, image.cols & (-2), image.rows & (-2)));
    
    int cx = image.cols / 2;
    int cy = image.rows / 2;
    
    Mat q0 = Mat(image, cv::Rect(0, 0, cx, cy));
    Mat q1 = Mat(image,  cv::Rect(cx, 0, cx, cy));
    Mat q2 =  Mat(image,  cv::Rect(0, cy, cx, cy));
    Mat q3 =  Mat(image,  cv::Rect(cx, cy, cx, cy));
    
    Mat tmp =  Mat();
    q0.copyTo(tmp);
    q3.copyTo(q0);
    tmp.copyTo(q3);
    
    q1.copyTo(tmp);
    q2.copyTo(q1);
    tmp.copyTo(q2);
    
}

- (UIImage *)addimageWithTitle:(NSString *)title fontSize:(CGFloat)fontSize image:(UIImage *)image rectX:(CGFloat )rectX rectY:(CGFloat )rectY

{
    
    //画布大小
    
    CGSize size=CGSizeMake(image.size.width,image.size.height);
    
    //创建一个基于位图的上下文
    
    UIGraphicsBeginImageContextWithOptions(size,NO,0.0);//opaque:NO  scale:0.0
    
    
    [image drawAtPoint:CGPointMake(0.0,0.0)];
    
    
    
    
    //文字居中显示在画布上
    
    NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    
    paragraphStyle.alignment=NSTextAlignmentCenter;//文字居中
    
    
    
    //计算文字所占的size,文字居中显示在画布上
    
    CGSize sizeText=[title boundingRectWithSize:image.size options:NSStringDrawingUsesLineFragmentOrigin
                     
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}context:nil].size;
    
    CGFloat width = image.size.width;
    
    CGFloat height = image.size.height;
    
    
    
    CGRect rect = CGRectMake(rectX > 0?rectX:(width-sizeText.width)/2, rectY> 0?rectY:(height-sizeText.height)/2, sizeText.width, sizeText.height);
    
    //绘制文字
    
    [title drawInRect:rect withAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:paragraphStyle}];
    
    
    
    //返回绘制的新图形
    
    UIImage *newImage= UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}


- (UIImage *)getProcessedFinalImageWithoriginalImage:(UIImage *)originalImg note:(NSString *)noteStr address:(NSString *)addressStr fillData:(NSDictionary *)messageDic{

    UIImage * getImage2 = [[OpenCVUtil share] imageWithImage:originalImg scaledToSize:CGSizeMake(originalImg.size.width/2, originalImg.size.height/2)];
    UIImage *getImage3 =  [[OpenCVUtil share] addimageWithTitle:noteStr fontSize:18.0f image:getImage2 rectX:0 rectY: 20];
    UIImage *getImage4 =   [[OpenCVUtil share] addimageWithTitle:addressStr fontSize:18.0f image:getImage3 rectX:0 rectY: getImage2.size.height - 50];
    //傅里叶打水印
    cv::Mat orignMat = [[OpenCVUtil share] cvMatFromUIImage:getImage4];//
    [[OpenCVUtil share] transformImageWithText:orignMat blindMarkText:@"PA" point:cv::Point(45,45) fontSize:0.8 scalar:CV_RGB(255,255,255)];
    cv::Mat dfMat = [[OpenCVUtil share] antitransformImage];
    //把打水印的图片添加信息
    NSMutableDictionary *mDic = [NSMutableDictionary new];
    if (messageDic) {
        [mDic addEntriesFromDictionary:messageDic];
    }
    [mDic setObject:[[OpenCVUtil share] getImageMatrixMD5String:dfMat] forKey:@"imageMD5"];
    
    cv::Mat matTmp = [[OpenCVUtil share] addMessageMatrixToOriginalMatRow:dfMat messageDic:mDic];
    UIImage *lastimage = [[OpenCVUtil share] UIImageFromCVMat:matTmp];
    return lastimage;
 
}




@end
