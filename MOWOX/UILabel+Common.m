//
//  UILabel+Common.m
//  MOWOX
//
//  Created by Mac on 2017/11/28.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "UILabel+Common.h"

@implementation UILabel (Common)
+ (instancetype)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor{
    UILabel *label = [self new];
    //label.font = font;
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [label setFont:font];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [label setFont:font];
    }
    label.textColor = textColor;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

+ (instancetype)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor text:(NSString *)text{
    UILabel *label = [self new];
    //label.font = font;
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [label setFont:font];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [label setFont:font];
    }
    label.textColor = textColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
    return label;
}

- (void)setLabelStyle1{
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.5;
    self.layer.cornerRadius = ScreenHeight * 0.033;
}

@end
