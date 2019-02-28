//
//  GREditImageViewController.h
//  OpenCViOSTest
//
//  Created by Miaoz on 2017/6/30.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GREditImageViewController : UIViewController
+ (instancetype)new  NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame address:(NSString *)address
NS_DESIGNATED_INITIALIZER;

@end
