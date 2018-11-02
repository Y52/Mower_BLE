//
//  NSString+Common.h
//  YSZfarm
//
//  Created by 杭州轨物科技有限公司 on 2018/1/25.
//  Copyright © 2018年 yusz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Common)
+ (Byte *)UInt8ByHexString:(NSString *)text;
+ (NSString *)fetchNewNodeString:(NSString *)sourceString;
@end
