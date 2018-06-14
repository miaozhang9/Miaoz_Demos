//
//  QHAlertManager.m
//  QHLoanlib
//
//  Created by guopengwen on 2017/5/4.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import "QHAlertManager.h"

@implementation QHAlertManager

+ (instancetype)shareAlertManager {
    static QHAlertManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[QHAlertManager alloc] init];
    });
    return manager;
}

- (void)showAlertMessageWithMessage:(NSString *)message
{
    BOOL isLessIOS8 = [[UIDevice currentDevice].systemVersion floatValue] < 8.0;
    if (isLessIOS8) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [alertView show];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertController addAction:setAction];
        [alertController addAction:cancelAction];
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    }
    
}

- (void)showOkayAndCancelAlertMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"取消");
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:setAction];
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}

- (void)showAlertMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        dispatch_after(0.2, dispatch_get_main_queue(), ^{
           
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];//隐私设置
            
        });
//         [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"prefs:root=LOCATION_SERVICES"]];
//        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];

    [alertController addAction:setAction];
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}



@end
