//
//  UILabel+Common.h
//  MOWOX
//
//  Created by Mac on 2017/11/28.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Common)
+ (instancetype)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor;
+ (instancetype)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor text:(NSString *)text;
- (void)setLabelStyle1;

@end
