//
//  UIFont+QH.m
//  QHLoanlib
//
//  Created by Miaoz on 2017/12/5.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import "UIFont+QH.h"

@implementation UIFont (QH)
+ (UIFont *)pingFangSCMediumWithSize:(CGFloat)size  {
    CGFloat phoneVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (phoneVersion >= 9.0) {
        return [UIFont fontWithName:@"PingFangSC-Medium" size:size];
    }
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)pingFangSCRegularWithSize:(CGFloat)size {
    CGFloat phoneVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (phoneVersion >= 9.0) {
        return [UIFont fontWithName:@"PingFangSC-Regular" size:size];
    }
    return [UIFont systemFontOfSize:size];
}
@end
