//
//  ViewAlertsCell.h
//  MOWOX
//
//  Created by Mac on 2017/11/20.
//  Copyright © 2017年 yusz. All rights reserved.
//

#define kCellIdentifier_ViewAlerts @"ViewAlertsCell"

#import <UIKit/UIKit.h>

@interface ViewAlertsCell : UITableViewCell

@property (strong,nonatomic) UILabel *timeLabel;
@property (strong,nonatomic) UILabel *alertLabel;

@end
