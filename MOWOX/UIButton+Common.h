//
//  UIButton+Common.h
//  MOWOX
//
//  Created by Mac on 2017/11/28.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Common)

+ (UIButton *)buttonWithTitle:(NSString *)title titleColor:(UIColor *)color;
+ (UIButton *)batteryButton:(NSString *)title batteryImage:(UIImage *)image;
+ (UIButton *)signalButton:(NSString *)title signalImage:(UIImage *)image;
- (void)setButtonStyle1;
- (void)setButtonStyleWithColor:(UIColor *)color Width:(float)width cornerRadius:(float)radius;

@end
