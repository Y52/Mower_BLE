//
//  GeneralsettingTimeViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/6.
//  Copyright © 2017年 yusz. All rights reserved.
//
#import "GeneralsettingTimeViewController.h"
#import "BluetoothDataManage.h"
#import "AppDelegate.h"
#import "GeneralsettingLanguageViewController.h"
#import "BaseNavigationViewController.h"
#import "Masonry.h"

@interface GeneralsettingTimeViewController ()

///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;


@property (strong, nonatomic)  UIDatePicker *datePickerView;
@property (strong, nonatomic)  UIDatePicker *timePickerView;

@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong,nonatomic) UIButton *okButton;


///@brife 设置时间的数据内容
@property (strong,nonatomic) NSDateComponents *dateComponents;
@property (strong,nonatomic) NSDateComponents *timeComponents;

@end

@implementation GeneralsettingTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    self.navigationItem.title = LocalString(@"Time setting");
    
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    
    [self viewLayoutSet];
    [self inquireTime];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveMowerTime:) name:@"recieveMowerTime" object:nil];
    [self.okButton addTarget:self action:@selector(setMowerTime) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveMowerTime" object:nil];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //设置割草机系统时间
    [self.datePickerView addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    [self.timePickerView addTarget:self action:@selector(timeChange:) forControlEvents:UIControlEventValueChanged];

    self.dateComponents = [[NSDateComponents alloc] init];
    self.timeComponents = [[NSDateComponents alloc] init];
    [self dateChange:self.datePickerView];
    [self timeChange:self.timePickerView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewLayoutSet{
    UIImage *image = [UIImage imageNamed:@"返回1"];
    [self addLeftBarButtonWithImage:image action:@selector(backAction)];
    
    _datePickerView = [[UIDatePicker alloc] init];
    _timePickerView = [[UIDatePicker alloc] init];
    _datePickerView.datePickerMode = UIDatePickerModeDate;
    _timePickerView.datePickerMode = UIDatePickerModeTime;
    
    //NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];//设置为英文显示
    //_datePickerView.locale = locale;
    //_timePickerView.locale = locale;
    
    _dateLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:17] textColor:[UIColor blackColor] text:LocalString(@"Date")];
    _timeLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:17] textColor:[UIColor blackColor] text:LocalString(@"Time")];
    _okButton = [UIButton buttonWithTitle:LocalString(@"OK") titleColor:[UIColor blackColor]];
    [_okButton setButtonStyle1];
    
    [self.view addSubview:_dateLabel];
    [self.view addSubview:_timeLabel];
    [self.view addSubview:_datePickerView];
    [self.view addSubview:_timePickerView];
    [self.view addSubview:_okButton];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, ScreenHeight * 0.066));
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.05 + 44 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(120, ScreenHeight * 0.066));
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.01 + 44 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    [_datePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.747, ScreenHeight * 0.25));
        make.top.equalTo(self.dateLabel.mas_bottom);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(120, ScreenHeight * 0.066));
        make.top.equalTo(self.datePickerView.mas_bottom);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_timePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.747, ScreenHeight * 0.25));
        make.top.equalTo(self.timeLabel.mas_bottom);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.747, ScreenHeight * 0.066));
        make.top.equalTo(self.timePickerView.mas_bottom);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

#pragma mark - inquire Mower Time

- (void)inquireTime{
    
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x12];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}

- (void)recieveMowerTime:(NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    NSNumber *year1 = dict[@"year1"];
    NSNumber *year2 = dict[@"year2"];
    NSNumber *month = dict[@"month"];
    NSNumber *day = dict[@"day"];
    NSNumber *hour = dict[@"hour"];
    NSNumber *minute = dict[@"minute"];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* comp = [[NSDateComponents alloc] init];
    comp.year = [year1 intValue] * 100 + [year2 intValue];
    comp.month = [month intValue];
    comp.day = [day intValue];
    comp.hour = [hour intValue];
    comp.minute = [minute intValue];
    //通过NSDateComponents所包含的时间字段的数值来恢复NSDateduixiang
    NSDate* date = [gregorian dateFromComponents:comp];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.datePickerView.date = date;
        self.timePickerView.date = date;
    });
}

#pragma mark - set mower time
- (void)dateChange:(UIDatePicker *)datePicker
{
    NSDate *theDate = datePicker.date;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    self.dateComponents = [calendar components:unitFlags fromDate:theDate];
    
}

- (void)timeChange:(UIDatePicker *)datePicker
{
    NSDate *theDate = datePicker.date;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
    NSInteger unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute;
    self.timeComponents = [calendar components:unitFlags fromDate:theDate];
}

- (void)setMowerTime{
    //NSLog(@"%ld",(long)self.timeComponents.hour);
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:self.dateComponents.year / 100]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:self.dateComponents.year % 100]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:self.dateComponents.month]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:self.dateComponents.day]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:self.timeComponents.hour]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:self.timeComponents.minute]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x02];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
