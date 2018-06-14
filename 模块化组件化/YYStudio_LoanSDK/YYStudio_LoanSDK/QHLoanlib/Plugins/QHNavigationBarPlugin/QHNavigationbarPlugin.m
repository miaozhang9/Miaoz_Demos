//
//  QHNavigationbar.m
//  LoanLib
//
//  Created by guopengwen on 16/12/19.
//  Copyright © 2016年 Miaoz. All rights reserved.
//

#import "QHNavigationbarPlugin.h"
#import "UIColor+QH.h"
#import "QHViewController.h"
#import "QHLoanDoorBundle.h"
#import "UIColor+QH.h"
#import "UIFont+QH.h"
#import "QHLoanDoor.h"
@interface QHNavigationbarPlugin ()

@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSString *callbackId;
@property (nonatomic, strong) NSDictionary *pickedContactDictionary;

@end

@implementation QHNavigationbarPlugin
static QHNavigationbarPlugin *plugin;

+ (instancetype)share{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        plugin = [[self alloc] init];
    });
    return plugin;
}

- (void)setNaviBarTitle:(QHInvokedUrlCommand*)command
{
    _callbackId = command.callbackId;
    NSString *title = [command argumentAtIndex:0 withDefault:[NSNull null]];
    self.viewController.navigationItem.title = title;
    
}

- (void)showNavigationBar:(QHInvokedUrlCommand*)command
{
    _callbackId = command.callbackId;
    BOOL isShow = [[command argumentAtIndex:0 withDefault:[NSNull null]] boolValue];
    UINavigationController *naviVC = self.viewController.navigationController;
    [naviVC setNavigationBarHidden:!isShow animated:YES];
    
    
}

-(void)setNavibarTitleColor:(QHInvokedUrlCommand*)command
{
    _callbackId = command.callbackId;
    NSString *color = [command argumentAtIndex:0 withDefault:[NSNull null]];
   
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.viewController.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor qh_colorWithHexString:color]};
        self.viewController.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor qh_colorWithHexString:color],NSFontAttributeName:[UIFont pingFangSCRegularWithSize:[QHLoanDoor share].barTitleFontSize?[QHLoanDoor share].barTitleFontSize:20]};
        
        
        //,NSFontAttributeName:[UIFontboldSystemFontOfSize:17]

    });
    
}


- (void)lightNavigationBarStyle {
    
    self.viewController.navigationController.navigationBar.barStyle = UIBarStyleDefault;
     UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
//    self.viewController.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor qh_colorWithHexString:@"#4A4A4A"], NSFontAttributeName:[UIFont pingFangSCRegularWithSize:20]};
//    [self.viewController.navigationController.navigationBar setBarTintColor:[UIColor qh_colorWithHexString:@"#ffffff"]];
//    [self.viewController.navigationController.navigationBar setTintColor:[UIColor qh_colorWithHexString:@"#4A4A4A"]];
    self.viewController.navigationController.navigationBar.translucent = NO;
    self.viewController.navigationController.navigationBar.tintColor = [UIColor qh_colorWithHexString:@"#292c35"];
}

- (void)blackNavigationBarStyle {
    self.viewController.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
//    self.viewController.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor qh_colorWithHexString:@"#FFFFFF"], NSFontAttributeName:[UIFont pingFangSCRegularWithSize:20]};
//    [self.viewController.navigationController.navigationBar setBarTintColor:[UIColor qh_colorWithHexString:@"#4a4a4a"]];
//    [self.viewController.navigationController.navigationBar setTintColor:[UIColor qh_colorWithHexString:@"#FFFFFF"]];
    self.viewController.navigationController.navigationBar.translucent = NO;
     self.viewController.navigationController.navigationBar.tintColor = [UIColor qh_colorWithHexString:@"#ffffff"];
    
}


-(void)setNaviBarColor:(QHInvokedUrlCommand*)command
{
    
    _callbackId = command.callbackId;
     NSString *color = [command argumentAtIndex:0 withDefault:[NSNull null]];
     QHViewController *vc = (QHViewController *)self.viewController;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.viewController.navigationController.navigationBar.barTintColor = [UIColor qh_colorWithHexString:color];
        
        UIImage * bImage = nil;
        if([color isEqualToString:@"#ffffff"]) {
              [self lightNavigationBarStyle];
           
            bImage = [UIImage imageNamed:@"BarArrowLeftGray" inBundle:[QHLoanDoorBundle bundle] compatibleWithTraitCollection:nil];
            
            [vc.backBtn setImage:bImage forState: UIControlStateNormal];
          
        } else {
             [self blackNavigationBarStyle];
            
            bImage = [UIImage imageNamed:@"BarArrowLeftWhite" inBundle:[QHLoanDoorBundle bundle] compatibleWithTraitCollection:nil];
            
            [vc.backBtn setImage:bImage forState: UIControlStateNormal];
           
        }
    });
    
}

-(void)setNaviLeftBarButtonItemColor:(QHInvokedUrlCommand*)command {
    _callbackId = command.callbackId;
     NSString *color = [command argumentAtIndex:0 withDefault:[NSNull null]];
//    self.viewController.navigationController.navigationBar.tintColor = [UIColor qh_colorWithHexString:color];
    dispatch_async(dispatch_get_main_queue(), ^{
         [(QHViewController *)self.viewController setBackBtnTitleColor:color backImg:@""];
    });
   
}

-(void)openNewPageWithUrl:(QHInvokedUrlCommand*)command
{
    _callbackId = command.callbackId;
    NSString *url = [command argumentAtIndex:0 withDefault:[NSNull null]];
    QHViewController *vc = (QHViewController *)self.viewController;
    if (vc.basicDelegate && [vc.basicDelegate respondsToSelector:@selector(openNewPageWithUrl:)]) {
        BOOL isSuccess = [vc.basicDelegate openNewPageWithUrl:url];
        QHPluginResult *result = [QHPluginResult resultWithStatus:QHCommandStatus_OK messageAsBool:isSuccess];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

-(void)closeAllPage:(QHInvokedUrlCommand*)command
{
    _callbackId = command.callbackId;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.viewController.presentingViewController)
        {
            [self.viewController dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [self.viewController.navigationController popToRootViewControllerAnimated:YES];
        }
    });
    
}

-(void)openLaunchLoginPage:(QHInvokedUrlCommand*)command
{
     _callbackId = command.callbackId;
    QHViewController *vc = (QHViewController *)self.viewController;
    if (vc.basicDelegate && [vc.basicDelegate respondsToSelector:@selector(openLaunchLoginPage)]) {
        [vc.basicDelegate openLaunchLoginPage];
    }
}

- (void)openNewPageWithParams:(QHInvokedUrlCommand*)command
{

    _callbackId = command.callbackId;
    id params = [command argumentAtIndex:0 withDefault:[NSNull null]];
   
    QHViewController *vc = (QHViewController *)self.viewController;
    if (vc.basicDelegate && [vc.basicDelegate respondsToSelector:@selector(openNewPageWithParams:)]) {
        [vc.basicDelegate openNewPageWithParams:params];
//        QHPluginResult *result = [QHPluginResult resultWithStatus:QHCommandStatus_OK messageAsBool:isSuccess];
//        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }

}

-(void)mulFunctionTlBack:(QHInvokedUrlCommand*)command {
     BOOL isVisible = [[command argumentAtIndex:0 withDefault:[NSNull null]] boolValue];
    QHViewController *vc = (QHViewController *)self.viewController;
    if (isVisible) {
        vc.backBtn.hidden = NO;
    } else {
        vc.backBtn.hidden = YES;
    }
}

- (void)setNativeBackControl:(QHInvokedUrlCommand*)command  {
  NSString *control = [command argumentAtIndex:0 withDefault:[NSNull null]];
  QHViewController *vc = (QHViewController *)self.viewController;
  vc.nativeBackControl = control;
}

@end
                           
