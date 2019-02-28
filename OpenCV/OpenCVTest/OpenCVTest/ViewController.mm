//
//  ViewController.m
//  OpenCVTest
//
//  Created by Miaoz on 2017/6/15.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import "ViewController.h"
#import "OpenUtil.h"
@interface ViewController ()
@property (strong, nonatomic)  UIImageView *imgView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self startMain];
    NSArray *aryPath=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *strDocPath=[aryPath objectAtIndex:0];
    NSLog(@"%@",strDocPath);
    _imgView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_imgView];
     cv::Mat dstImage = [[OpenUtil share] transformImageWithText];
//    UIImage *dstImg =[[OpenUtil share] testTest:dstImage];
   
    UIImage *dstImg = [[OpenUtil share] UIImageFromCVMat:dstImage];
    
    self.imgView.image =dstImg;
//    UIImage *image2 = dstImg;
//    NSString *path_document = NSHomeDirectory();
//    //设置一个图片的存储路径
//    NSString *imagePath = [path_document stringByAppendingString:@"/Documents/pic3.png"];
//    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
//    [UIImagePNGRepresentation(image2) writeToFile:imagePath atomically:YES];
    

//   self.imgView.image =  [[OpenUtil share] testTest];
//    [self corrosionPic];
}

-(void)corrosionPic
{
    UIImage* image=[UIImage imageNamed:@"lena.jpg"];
    cv::Mat srcImage = [[OpenUtil share] cvMatFromUIImage:image];
    
    cv::Mat element = getStructuringElement(cv::MORPH_RECT, cv::Size(15, 15));
    cv::Mat dstImage;
    cv::erode(srcImage, dstImage, element);
   
    UIImage *dstImg = [[OpenUtil share] UIImageFromCVMat:dstImage];
    
       self.imgView.image =dstImg;
    self.view.backgroundColor = [UIColor blackColor];
    
    //cv::Mat srcImage1 = cv::imread( "1.jpg", 1 );
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)kcvWatermarking:(IplImage*) img mask:(IplImage*) mask
//{
//    int w=img->width;
//    int h=img->height;
//    // 确保mask中只有黑白两种灰度值
//    cvThreshold(mask,mask,128,255,CV_THRESH_BINARY);
//    for(int i=0;i<h;++i)
//    {
//        for(int j=0;j<w;++j)
//        {
//            if(CV_IMAGE_ELEM(mask,uchar,i,j))
//            {
//                CV_IMAGE_ELEM(img,uchar,i,j)|=0x1;
//            }
//            else
//            {
//                CV_IMAGE_ELEM(img,uchar,i,j)&=0xfe;
//            }
//        }
//    }
//}
//
//- (void)kcvGetWatermarking:(IplImage*) img dst:(IplImage*) dst
//{
//    int w=img->width;
//    int h=img->height;
//    for(int i=0;i<h;++i)
//    {
//        for(int j=0;j<w;++j)
//        {
//            if(CV_IMAGE_ELEM(img,uchar,i,j)&0x1)
//            {
//                CV_IMAGE_ELEM(dst,uchar,i,j)=0;
//            }
//            else
//            {
//                CV_IMAGE_ELEM(dst,uchar,i,j)=255;
//            }
//        }
//    }
//}
//
//
//
//-(void)startMain {
//   
//    UIImage *image = [UIImage imageNamed:@"jpg"];
//    cv::Mat faceImage;
//    UIImageToMat(image, faceImage);
//    
////    IplImage* img = cvLoadImage("lena.jpg",0);
////    IplImage* mask= cvCreateImage(cvGetSize(img),8,1);
////    IplImage* dst=cvCreateImage(cvGetSize(img),8,1);
////    cvSetZero(mask);
//    CvFont font=cvFont(2);
//    char text[]="minmin, i love you!";
//    cvPutText(&faceImage,text,cvPoint(50,50),&font,CV_RGB(255,255,255));
//    cvNamedWindow("img");
//    cvNamedWindow("min");
//    cvShowImage("img",&faceImage);
//    cvShowImage("min",&faceImage);
//    // 执行水印
//    [self kcvWatermarking:faceImage mask:mask];
////    kcvWatermarking(img,mask);
//    cvNamedWindow("comp");
//    cvShowImage("comp",img);
//    // 获得水印
//    [self kcvGetWatermarking:img dst:dst];
////    kcvGetWatermarking(img,dst);
//    cvNamedWindow("watermarking");
//    cvShowImage("watermarking",dst);
//    cvWaitKey(0);
//    cvDestroyAllWindows();
//    cvReleaseImage(&img);
//    cvReleaseImage(&mask);
//    cvReleaseImage(&dst);
//
//}


@end
