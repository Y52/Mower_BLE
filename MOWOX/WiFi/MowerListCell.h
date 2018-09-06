//
//  MowerListCell.h
//  MOWOX
//
//  Created by 杭州轨物科技有限公司 on 2018/8/6.
//  Copyright © 2018年 yusz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WKJBatteryView;

@interface MowerListCell : UITableViewCell
@property (strong, nonatomic)  UIImageView *deviceImage;
@property (strong, nonatomic)  UILabel *deviceLabel;
@property (strong, nonatomic)  WKJBatteryView *battery;
@property (strong, nonatomic)  UILabel *batteryLabel;

- (void)setBatteryValue:(NSInteger)value;
- (void)setBatteryHidden;
@end
