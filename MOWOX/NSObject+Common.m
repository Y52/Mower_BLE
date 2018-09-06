//
//  NSObject+Common.m
//  MOWOX
//
//  Created by Mac on 2017/11/18.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "NSObject+Common.h"

@implementation NSObject (Common)
static dispatch_queue_t queue;

+ (void)showHudTipStr:(NSString *)tipStr{
    if (tipStr && tipStr.length > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.font = [UIFont boldSystemFontOfSize:15.0];
        hud.label.text = tipStr;
        hud.margin = 15.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:1.0];
    }
}

+ (void)showHudTipStr2:(NSString *)tipStr{
    if (tipStr && tipStr.length > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.square = YES;
        hud.label.text = tipStr;
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:2.0];

    }
}

+ (void)showHudTipStr3:(NSString *)tipStr{
    if (tipStr && tipStr.length > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.font = [UIFont boldSystemFontOfSize:15.0];
        hud.label.text = tipStr;
        hud.margin = 15.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:3.0];
        
    }
}

- (UInt8)getCS:(NSArray *)data{
    UInt8 csTemp = 0x00;
    for (int i = 0; i < [data count]; i++)
    {
        csTemp += [data[i] unsignedCharValue];
    }
    return csTemp;
}

@end
