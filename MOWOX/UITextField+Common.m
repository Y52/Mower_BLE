//
//  UITextField+Common.m
//  MOWOX
//
//  Created by Mac on 2017/11/30.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "UITextField+Common.h"
#import "inputTextField.h"

@implementation UITextField (Common)
+ (UITextField *)textFieldWithPlaceholderText:(NSString *)text
{
    UITextField *textField = [[inputTextField alloc] init];
    textField.placeholder = text;
    [textField setFont:[UIFont boldSystemFontOfSize:17]];
    textField.font = [UIFont systemFontOfSize:17.0f];
    textField.textColor = [UIColor blackColor];
    textField.adjustsFontSizeToFitWidth = YES;
    textField.minimumFontSize = 13.0;
    textField.text = NSTextAlignmentLeft;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    return  textField;
}

+ (UITextField *)worktimeTextFieldWithPlaceholder:(NSString *)text
{
    UITextField *textField = [[inputTextField alloc] init];
    textField.placeholder = text;
    [textField setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
    [textField setFont:[UIFont boldSystemFontOfSize:20]];
    textField.font = [UIFont systemFontOfSize:20.0f];
    textField.textColor = [UIColor blackColor];
    textField.adjustsFontSizeToFitWidth = YES;
    textField.minimumFontSize = 13.0;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.tintColor = [UIColor clearColor];
    return  textField;
}

- (void)setTextFieldStyle1{
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.5;
    self.layer.cornerRadius = ScreenHeight * 0.033;
}

@end
