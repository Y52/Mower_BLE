//
//  MowerListCell.m
//  MOWOX
//
//  Created by 杭州轨物科技有限公司 on 2018/8/6.
//  Copyright © 2018年 yusz. All rights reserved.
//

#import "MowerListCell.h"
//#import "WKJBatteryView.h"

#define viewWidth self.contentView.frame.size.width
#define viewHeight self.contentView.frame.size.height

@implementation MowerListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!self.deviceImage) {
            _deviceImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, (viewHeight - 30)/2, 30, 30)];
            [self.contentView addSubview:_deviceImage];
        }
        if (!self.deviceLabel) {
            _deviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, (viewHeight - 21)/2, 120, 21)];
            _deviceLabel.font = [UIFont systemFontOfSize:16.f];
            _deviceLabel.backgroundColor = [UIColor clearColor];
            _deviceLabel.textColor = [UIColor blackColor];
            _deviceLabel.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_deviceLabel];
        }
//        if (!self.battery) {
//            _battery = [[WKJBatteryView alloc] initWithFrame:CGRectMake(170, (viewHeight - 20)/2, 50, 20)];
//            [self.contentView addSubview:_battery];
//        }
//        if (!self.batteryLabel) {
//            _batteryLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, (viewHeight - 21)/2, 80, 21)];
//            _batteryLabel.font = [UIFont systemFontOfSize:16.f];
//            _batteryLabel.backgroundColor = [UIColor clearColor];
//            _batteryLabel.textColor = [UIColor blackColor];
//            _batteryLabel.textAlignment = NSTextAlignmentLeft;
//            [self.contentView addSubview:_batteryLabel];
//        }
    }
    return self;
}

//- (void)setBatteryValue:(NSInteger)value{
//    [_battery setBatteryValue:value];
//}
//
//- (void)setBatteryHidden{
//    _battery.hidden = YES;
//}
@end
