//
//  QHBasicProtocol.h
//  QHLoanlib
//
//  Created by Miaoz on 2017/5/23.
//  Copyright © 2017年 Miaoz. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol QHBasicProtocol <NSObject>
//得到用户账户信息
-(NSDictionary *)getAgentUserInfo;
//跳转new的h5Page
-(BOOL)openNewPageWithUrl:(NSString *)url;
//打开调起登录
-(void)openLaunchLoginPage;
//跳转new的Page params传递参数
-(void)openNewPageWithParams:(NSDictionary *)params;
//得到H5信息操作 多功能接口 可以返回信息给H5
-(NSDictionary *)executeH5InfoAction:(NSDictionary *)info;

@end
