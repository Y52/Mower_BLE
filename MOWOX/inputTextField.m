//
//  inputTextField.m
//  MOWOX
//
//  Created by Mac on 2017/12/4.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "inputTextField.h"

@implementation inputTextField

//控制文本所在的的位置，左右缩 10
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 0 );
}

//控制编辑文本时所在的位置，左右缩 10
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 0 );
}

@end
