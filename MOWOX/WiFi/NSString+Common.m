//
//  NSString+Common.m
//  YSZfarm
//
//  Created by 杭州轨物科技有限公司 on 2018/1/25.
//  Copyright © 2018年 yusz. All rights reserved.
//

#import "NSString+Common.h"


@implementation NSString (Common)

+ (NSString *)HexByTextFieldDecemal:(NSString *)text{
    NSScanner *scanner = [NSScanner scannerWithString:text];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    int number;
    [scanner scanInt:&number];
    NSLog(@"%x",number);
    NSString *addressString = [NSString stringWithFormat:@"%04x",number];
    
    return addressString;
}

+ (Byte *)UInt8ByHexString:(NSString *)text{
    NSMutableData *data = [NSMutableData data];
    for (int i = 0; i < text.length; i += 2) {
        NSString *hexText = [text substringWithRange:NSMakeRange(i, 2)];
        NSScanner *scanner = [NSScanner scannerWithString:hexText];
        unsigned charValue;
        [scanner scanHexInt:&charValue];
        [data appendBytes:&charValue length:1];
    }
    Byte *byte = (Byte *)[data bytes];
    return byte;
}

+ (NSString *)fetchNewNodeString:(NSString *)sourceString
{
    if([sourceString rangeOfString:@"MAC"].location != NSNotFound && [sourceString rangeOfString:@"PASS"].location != NSNotFound)
    {
        //NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:2];
        NSArray *strarray = [sourceString componentsSeparatedByString:@":"];
        if (strarray.count == 3) {
            //NSString *mac = strarray[1];
            NSString *mac = [[strarray[1] substringFromIndex:0] substringToIndex:8];
            //[tempArray addObject:type];
            //[tempArray addObject:mac];
            return  mac;
        }
        else {
            return nil;
        }
    }
    else
    {
        return nil;
        
    }
}

@end
