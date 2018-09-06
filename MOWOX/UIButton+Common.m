//
//  UIButton+Common.m
//  MOWOX
//
//  Created by Mac on 2017/11/28.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "UIButton+Common.h"
#import "batteryButton.h"
#import "connectButton.h"

@implementation UIButton (Common)
+ (UIButton *)buttonWithTitle:(NSString *)title titleColor:(UIColor *)color{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitleColor:color forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    }
    
    [btn.titleLabel setMinimumScaleFactor:0.5];
    
    //CGFloat titleWidth = [title getWidthWithFont:btn.titleLabel.font constrainedToSize:CGSizeMake(kScreen_Width, 30)] +20;
    //btn.frame = CGRectMake(0, 0, titleWidth, 30);
    
    [btn setTitle:title forState:UIControlStateNormal];
    return btn;
}

+ (UIButton *)batteryButton:(NSString *)title batteryImage:(UIImage *)image{
    UIButton *btn = [[batteryButton alloc] init];
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    }
    [btn.titleLabel setMinimumScaleFactor:0.5];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateNormal];
    return btn;
}

+ (UIButton *)signalButton:(NSString *)title signalImage:(UIImage *)image{
    UIButton *btn = [[connectButton alloc] init];
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    }
    
    //[btn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [btn.titleLabel setMinimumScaleFactor:0.5];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateNormal];
    return btn;
}

- (void)setButtonStyle1{
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.5;
    self.layer.cornerRadius = ScreenHeight * 0.033;
}

- (void)setButtonStyleWithColor:(UIColor *)color Width:(float)width cornerRadius:(float)radius{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
    self.layer.cornerRadius = radius;
}


@end
