//
//  ViewAlertsCell.m
//  MOWOX
//
//  Created by Mac on 2017/11/20.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "ViewAlertsCell.h"

@interface ViewAlertsCell ()



@end

@implementation ViewAlertsCell

static CGFloat padding_height = 45;
static CGFloat padding_left = 30.0;
static CGFloat padding_between_content = 15.0;
static CGFloat target_height = 45.0;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!self.timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding_left , 15, ScreenWidth - padding_left, 15)];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            _timeLabel.backgroundColor = [UIColor clearColor];
            _timeLabel.textColor = [UIColor blackColor];
            _timeLabel.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_timeLabel];
        }
        if (!self.alertLabel) {
            _alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding_left, 15 + 15 + padding_between_content, ScreenWidth - padding_left, 15)];
            _alertLabel.font = [UIFont systemFontOfSize:12];
            _alertLabel.backgroundColor = [UIColor clearColor];
            _alertLabel.textColor = [UIColor blackColor];
            _alertLabel.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_alertLabel];
        }
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
