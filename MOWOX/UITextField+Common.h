//
//  UITextField+Common.h
//  MOWOX
//
//  Created by Mac on 2017/11/30.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Common)

+ (UITextField *)textFieldWithPlaceholderText:(NSString *)text;
+ (UITextField *)worktimeTextFieldWithPlaceholder:(NSString *)text;
- (void)setTextFieldStyle1;

@end
