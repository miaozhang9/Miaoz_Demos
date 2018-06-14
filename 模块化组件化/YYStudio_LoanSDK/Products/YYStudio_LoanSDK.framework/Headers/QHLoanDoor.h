//
//  QHLoanDoor.h
//  LoanLib
//
//  Created by yinxukun on 2016/12/16.
//  Copyright © 2016年 Miaoz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QHFaceCheckDelegate.h"

typedef NS_ENUM(NSUInteger, QHLoanDoorEnvironment) {
    QHLoanDoorEnvironment_stg, //测试环境
    QHLoanDoorEnvironment_prd, //预发布环境
    QHLoanDoorEnvironment_pdt, //生产环境
};

typedef NS_ENUM(NSUInteger, QHCoreWebViewEnum) {
    QHCoreWebView_UIWebView, //UIWebView
    QHCoreWebView_WKWebView, //WKWebView
};

typedef void(^CallBackBlcok) (BOOL isSuccess, NSError *error);

@interface QHLoanDoor : NSObject

@property (nonatomic, strong)QHFaceCheckDelegate *faceCheckDelegate;
@property (nonatomic, copy) void(^startLaunchFaceRecognition)(NSDictionary *dic);
@property (nonatomic, copy) void(^faceRecognitionComplete)(BOOL isSuccess, UIImage *oriImg, UIImage *faceImg, NSDictionary *);
/*传递信息*/
@property (nonatomic, strong)NSDictionary *dataInfo;
/*title大小*/
@property (nonatomic, assign) NSInteger barTitleFontSize;
//webview 内核
@property (nonatomic, assign) QHCoreWebViewEnum coreWebViewEnum;

+ (instancetype)share;
/**链式调用**/
//设置传递信息
- (QHLoanDoor *(^)(NSDictionary *))setDataInfo;
//设置导航条颜色
- (QHLoanDoor *(^)(NSString *))setBarColor;
//设置title颜色
- (QHLoanDoor *(^)(NSString *))setBarTitleColor;
//设置title字体大小
- (QHLoanDoor *(^)(NSInteger ))setBarTitleFontSize;
//设置backTitle
- (QHLoanDoor *(^)(NSString *))setBackBtnTitle;
//设置backTitle颜色
- (QHLoanDoor *(^)(NSString *))setBackBtnTitleColor;
//设置back图片
- (QHLoanDoor *(^)(UIImage *))setBackBtnImage;
//设置启动URL
- (QHLoanDoor *(^)(NSString *))setStartPageUrl;
//设置标示
- (QHLoanDoor *(^)(NSString *))setAgent;
//设置是否使用wkwebView内核 WK
- (QHLoanDoor *(^)(QHCoreWebViewEnum ))setCoreWebView;
//代理 如果使用QHLoanDoor启动的时候需要协议方法时需要传入
- (QHLoanDoor *(^)(id))setBasicDelegate;
//启动SDK
- (QHLoanDoor *(^)())start;




@property (nonatomic,copy)CallBackBlcok callBackBlcok;

//1.arg1 为图片base64 arg2 右为文字 身份证是正面
//2.arg1 左为文字  arg2 为图片base64 身份证是反面
//3.arg1 为空字符  arg2 是文字 则中间显示文字 一般是拍摄银行卡、其他卡片
//4.borderColor 边框颜色 传nil或者空字符时 显示默认
//5.takePhotoImageB64 拍摄按钮图片Base64 传nil或者空字符时 显示默认
- (void)invokCardCamera:(CGFloat)photoSize arg1:(NSString *)arg1 agr2:(NSString *)arg2 borderColor:(NSString *)borderColor takePhotoImageB64:(NSString *)takePhotoImageB64 viewController:(UIViewController *)vc completeBlock:(void(^)(UIImage *img, NSDictionary *errorInfo))completeBlock;

/**
 注册协议
 */
-(void)registerQHLoanSDKURLProtocol;
/**
 取消协议
 */
-(void)unRegisterQHLoanSDKURLProtocol;

/**改变页面横竖屏
 必须在project中配置横竖屏选项
竖屏UIInterfaceOrientationPortrait
横屏UIInterfaceOrientationLandscapeRight
 
 **/
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation;

/**transform当前页面角度来达到类似横竖屏
 竖屏UIInterfaceOrientationPortrait
 横屏UIInterfaceOrientationLandscapeRight
 **/
- (void)forceExecuteInterfaceOrientation:(UIInterfaceOrientation)orientation;
/**
 关闭SDK
 **/
- (void)closeAllPages:(void(^)(void))completion;

- (void)getCommandDelegate:(id)qhcommandDelegate  InvokedUrlCommand:(NSObject *)qhinvokedUrlCommand;
/*
 executeH5InfoAction接口配合使用通知H5的方法
 */
- (void)sendCallBackPluginResultDictionary:(NSDictionary *)resultDictionary resultStatus:(BOOL)isSuccess;
@end

