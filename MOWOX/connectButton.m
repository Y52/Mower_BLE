//
//  connectButton.m
//  MOWOX
//
//  Created by Mac on 2017/11/28.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "connectButton.h"

@implementation connectButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(contentRect.size.width * 0.182, (contentRect.size.height - 30) / 2, 20, 30);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(contentRect.size.width * 0.182 + 20, 0, contentRect.size.width * 0.8 - 20, contentRect.size.height);
}
@end
