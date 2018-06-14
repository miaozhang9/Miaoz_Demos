//
//  OCFTFaceDetector.h
//  OCFTFaceDetect
//
//  Created by PA on 2017/9/27.
//  Copyright © 2017年 Shanghai OneConnect Technology CO,LTD. All Rights Reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

extern NSString *const OCFTFaceDetectorActionTypes;//人脸识别的动作类型key（NSString：“1”:张嘴，“2”:摇头，“3”:张嘴或摇头随机）
extern NSString *const OCFTFaceDetectorOuputLocation;//是否输出定位信息：BOOL: true/false
extern NSString *const OCFTFaceResultLocationTimestamp;//获取定位的时间
extern NSString *const OCFTFaceResultLocationLatitude;//定位信息——纬度
extern NSString *const OCFTFaceResultLocationLongitude;//定位信息——经度

/*!
 * 检测失败类型
 */
typedef enum OCFTFaceDetectFailedType {
    
    OCFT_CAMERA_AUTH_FAIL = 300,        //相机权限获取失败
    OCFT_DISCONTINUIIY_ATTACK = 301,    //非连续性攻击（可理解为用户晃动过大）
    
} OCFTFaceDetectFailedType;


/**
 * 检测过程中的提示
 */
typedef enum OCFTFaceDetectOptimizationType {
    
    OCFT_NORMAL = 101,                        //正常
    OCFT_TOO_DARK = 102,                      //太暗
    OCFT_TOO_BRIGHT = 103,                    //太亮
    OCFT_TOO_CLOSE = 104,                     //太近
    OCFT_TOO_FAR = 105,                       //太远
    OCFT_TOO_FUZZY = 106,                     //太模糊
    OCFT_TOO_PARTIAL = 107,                   //偏转角度
    OCFT_NO_FACE = 108,                       //没人脸
    OCFT_MULTIPLE_FACE = 109,                 //多人脸
    OCFT_TOO_LEFT = 110,                      //太左
    OCFT_TOO_RIGHT = 111,                     //太右
    OCFT_TOO_UP  = 112,                       //太上
    OCFT_TOO_DOWN = 113,                      //太下
    OCFT_EYES_CLOSED                          //眼睛闭合
    
} OCFTFaceDetectOptimizationType;
/*!
 * 检测动作类型
 */
typedef enum OCFTFaceDetectActionType {
    
    OCFT_COLLECTFACE = 200,                   //采集正脸
    OCFT_MOUTH = 201,                         //张嘴提示
    OCFT_HEAD =  202                          //摇头提示
    
} OCFTFaceDetectActionType;


@interface OCFTFaceDetectionFrame : NSObject
@property (readonly) UIImage *originalImage;             /** 检测帧对应图片 */
@property (readonly) UIImage *headImage;                 /** 检测帧对应人脸图片 */
@property (readonly) NSDictionary *locationInfo;         /** 拍摄图片时所在的位置 */
@end

@interface OCFTSDKInfo : NSObject
@property (readonly) NSString *version;                  /** SDK版本号 **/
@end

@protocol OCFTFaceDetectProtocol <NSObject>
@required
-(void)onDetectionFailed:(OCFTFaceDetectFailedType)failedType;//识别失败回调
@required
-(void)onSuggestingOptimization:(OCFTFaceDetectOptimizationType)type;//辅助提示信息接口，主要包装一些附加功能（比如光线过亮／暗的提示），以便增强活体检测的质量
@required
-(void)onDetectionChangeAnimation:(OCFTFaceDetectActionType)type options:(NSDictionary*)options;//提示用户做活体动作（目前支持动嘴、摇头、或随机取其一，options字段目前送入nil，该字段作为后续的拓展字段）
@required
-(void)onDetectionSuccess:(OCFTFaceDetectionFrame *)faceInfo;
@optional
-(void)onStartDetection:(NSDictionary *)info;//表示已经开始活体检测info为预留字段，目前为nil

@end


@interface OCFTFaceDetector : NSObject
+(instancetype)getDetectorWithOptions:(NSDictionary*)options delegate:(id<OCFTFaceDetectProtocol>)delegate;//初始化SDK方法
+(OCFTSDKInfo *)getSDKInfo;//获取sdk信息
-(AVCaptureVideoPreviewLayer *)videoPreview;//获取视频展示界面
-(void)reset;//重置SDK状态
@end
