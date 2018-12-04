//
//  WorktimeCell.m
//  MOWOX
//
//  Created by Mac on 2017/12/11.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "WorktimeCell.h"
#define viewWidth self.contentView.frame.size.width
#define viewHeight self.contentView.frame.size.height

@interface WorktimeCell () <UITextFieldDelegate>
@end

@implementation WorktimeCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(done) name:@"done" object:nil];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_weekLabel) {
            _weekLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:15.0] textColor:[UIColor blackColor]];
            _weekLabel.frame = CGRectMake(0, 15, ScreenWidth / 3.0, viewHeight - 30);
            [self.contentView addSubview:self.weekLabel];
        }
        /*if (!_timeBtn) {
            _timeBtn = [UIButton buttonWithTitle:@"00:00" titleColor:[UIColor blackColor]];
            _timeBtn.frame = CGRectMake(ScreenWidth / 3.0, 15, ScreenWidth / 3.0, viewHeight - 30);
            [_timeBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
            [self.contentView addSubview:self.timeBtn];
        }
        if (!_hoursBtn) {
            _hoursBtn = [UIButton buttonWithTitle:@"22.0h" titleColor:[UIColor blackColor]];
            _hoursBtn.frame = CGRectMake(ScreenWidth / 3.0 * 2.0, 15, ScreenWidth / 3.0, viewHeight - 30);
            [_hoursBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
            [self.contentView addSubview:self.hoursBtn];
        }*/
        if (!_timeTF) {
            _timeTF = [UITextField worktimeTextFieldWithPlaceholder:@"AM 0:00;"];
            _timeTF.frame = CGRectMake(ScreenWidth / 3.0, 5, ScreenWidth / 3.0, viewHeight - 10);
            _timeTF.font = [UIFont systemFontOfSize:15.0];
            [_timeTF addTarget:self action:@selector(pushTag) forControlEvents:UIControlEventTouchUpInside];
            _timeTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            [self.contentView addSubview:self.timeTF];
        }
        if (!_hoursTF) {
            _hoursTF = [UITextField worktimeTextFieldWithPlaceholder:@"0 Hours"];
            _hoursTF.frame = CGRectMake(ScreenWidth / 3.0 * 2.0, 5, ScreenWidth / 3.0, viewHeight - 10);
            _hoursTF.font = [UIFont systemFontOfSize:15.0];
            [_hoursTF addTarget:self action:@selector(pushTag) forControlEvents:UIControlEventTouchUpInside];
            _hoursTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            [self.contentView addSubview:self.hoursTF];
        }
    }
    return self;
}

- (void)done {
    [_hoursTF resignFirstResponder];
    [_timeTF resignFirstResponder];
}

- (void)pushTag{
    
}

- (BOOL)textFieldShouldReturn:(UITextField*) textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
