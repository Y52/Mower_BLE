//
//  batteryButton.m
//  MOWOX
//
//  Created by Mac on 2017/11/28.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "batteryButton.h"

@implementation batteryButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(contentRect.size.width * 0.182, (contentRect.size.height - 20) / 2, contentRect.size.width * 0.25, 20);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(contentRect.size.width * 0.5, 5, contentRect.size.width * 0.318, contentRect.size.height - 10);
}

@end
