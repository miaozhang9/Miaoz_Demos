//
//  QHNavigationbar.h
//  LoanLib
//
//  Created by guopengwen on 16/12/19.
//  Copyright © 2016年 Miaoz. All rights reserved.
//

#import "QHPlugin.h"

@interface QHNavigationbarPlugin : QHPlugin
+ (instancetype)share;
// 设置 Navigationbar 的title
- (void)setNaviBarTitle:(QHInvokedUrlCommand*)command;

// 设置是否现实 Navigationbar
- (void)showNavigationBar:(QHInvokedUrlCommand*)command;

// 设置Title颜色
-(void)setNavibarTitleColor:(QHInvokedUrlCommand*)command;

// 设置导航条颜色
-(void)setNaviBarColor:(QHInvokedUrlCommand*)command;

//设置返回按钮颜色
-(void)setNaviLeftBarButtonItemColor:(QHInvokedUrlCommand*)command;

//打开新的h5页面
-(void)openNewPageWithUrl:(QHInvokedUrlCommand*)command;

//关闭打开的所有页面
-(void)closeAllPage:(QHInvokedUrlCommand*)command;

//宿主调起登录页面
-(void)openLaunchLoginPage:(QHInvokedUrlCommand*)command;
//打开新的Native页面
- (void)openNewPageWithParams:(QHInvokedUrlCommand*)command;
//返回按钮  true 是显示  false 是隐藏
-(void)mulFunctionTlBack:(QHInvokedUrlCommand*)command;
//控制返回键
-(void)setNativeBackControl:(QHInvokedUrlCommand*)command;
@end
