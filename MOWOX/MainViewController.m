//
//  MainViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/2.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "MainViewController.h"
#import "BluetoothDataManage.h"
#import "BabyDefine.h"
#import "AppDelegate.h"
#import "MowerControlViewController.h"



@interface MainViewController ()

///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;

///@brife ui和功能各模块
@property (strong, nonatomic)  UILabel *onLawn;
@property (strong, nonatomic)  UILabel *onStation;
@property (strong, nonatomic)  UILabel *batteryCapacity;
@property (strong, nonatomic)  UIButton *GoToWorkButton;
@property (strong, nonatomic)  UIButton *BacktostationButton;
@property (strong, nonatomic)  UIButton *batteryButton;
@property (strong, nonatomic)  UIButton *signalButton;
@property (strong, nonatomic)  UIButton *mowerControlButton;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    
    [self viewLayoutSet];

    //查询割草机电量
    
    //[self acquireDate];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self inquireBatter];
    //添加蓝牙状态观察
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBatterDataAndSetButton:) name:@"getMowerData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectBluetooth:) name:@"disconnectBluetooth" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mowerControlView) name:@"settingVCBack" object:nil];
    
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(inquireBatter) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        //[_timer setFireDate:[NSDate distantFuture]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getMowerData" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"disconnectBluetooth" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"settingVCBack" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)viewLayoutSet{
    //self.navigationController.navigationBar.translucent = YES;
    
    self.navigationItem.title = LocalString(@"Robot status");
    
    UIImage *image = [UIImage imageNamed:@"返回1"];
    [self addLeftBarButtonWithImage:image action:@selector(backAction)];

    //判断蓝牙是否连接
    self.appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (_appDelegate.status == 0) {
        if ([[NetWork shareNetWork].mySocket isDisconnected]) {
            self.signalButton = [UIButton signalButton:LocalString(@"Wi-Fi disconnected") signalImage:[UIImage imageNamed:@"img_wifi"]];
            [_signalButton.layer setBackgroundColor:[UIColor redColor].CGColor];
            //[self.batteryButton setTitle:LocalString(@"---") forState:UIControlStateNormal];
            self.batteryButton = [UIButton buttonWithTitle:LocalString(@"---") titleColor:[UIColor blackColor]];
            [self.batteryButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        }else{
            self.signalButton = [UIButton signalButton:LocalString(@"Wi-Fi connected") signalImage:[UIImage imageNamed:@"img_wifi"]];
            [_signalButton.layer setBackgroundColor:[UIColor colorWithHexString:@"7DA86D"].CGColor];
            self.batteryButton = [UIButton batteryButton:LocalString(@"100%") batteryImage:[UIImage imageNamed:@"电量5-2"]];
        }
    }else{
        if (_appDelegate.currentPeripheral == nil) {
            //[self.signalButton setTitle:LocalString(@"Bluetooth disconnected") forState:UIControlStateNormal];
            self.signalButton = [UIButton signalButton:LocalString(@"Bluetooth disconnected") signalImage:[UIImage imageNamed:@"蓝牙连接"]];
            [_signalButton.layer setBackgroundColor:[UIColor redColor].CGColor];
            //[self.batteryButton setTitle:LocalString(@"---") forState:UIControlStateNormal];
            self.batteryButton = [UIButton buttonWithTitle:LocalString(@"---") titleColor:[UIColor blackColor]];
            [self.batteryButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        }else{
            //[self.signalButton setTitle:LocalString(@"Bluetooth connected") forState:UIControlStateNormal];
            self.signalButton = [UIButton signalButton:LocalString(@"Bluetooth connected") signalImage:[UIImage imageNamed:@"蓝牙连接"]];
            [_signalButton.layer setBackgroundColor:[UIColor colorWithHexString:@"7DA86D"].CGColor];
            self.batteryButton = [UIButton batteryButton:LocalString(@"100%") batteryImage:[UIImage imageNamed:@"电量5-2"]];
        }
    }
    
    
    _onLawn = [UILabel labelWithFont:[UIFont systemFontOfSize:13] textColor:[UIColor blackColor] text:LocalString(@"Robot on lawn")];
    _onStation = [UILabel labelWithFont:[UIFont systemFontOfSize:13] textColor:[UIColor blackColor] text:LocalString(@"Robot on station")];
    _batteryCapacity = [UILabel labelWithFont:[UIFont systemFontOfSize:13] textColor:[UIColor blackColor] text:LocalString(@"Battery capacity")];
    
    [_onLawn setLabelStyle1];
    [_onStation setLabelStyle1];
    [_batteryCapacity setLabelStyle1];
    
    _BacktostationButton = [UIButton buttonWithTitle:LocalString(@"Back to station") titleColor:[UIColor blackColor]];
    _GoToWorkButton = [UIButton buttonWithTitle:LocalString(@"Go to work") titleColor:[UIColor blackColor]];
    
    [_BacktostationButton.layer setBackgroundColor:[UIColor colorWithHexString:@"7DA86D"].CGColor];
    [_GoToWorkButton.layer setBackgroundColor:[UIColor colorWithHexString:@"7DA86D"].CGColor];
    
    _mowerControlButton = [UIButton buttonWithTitle:LocalString(@"Robot control") titleColor:[UIColor blackColor]];
    [_BacktostationButton setButtonStyle1];
    [_GoToWorkButton setButtonStyle1];
    [_batteryButton setButtonStyle1];
    [_signalButton setButtonStyle1];
    [_mowerControlButton setButtonStyle1];
    //_signalButton.userInteractionEnabled = NO;
    _batteryButton.userInteractionEnabled = NO;
    
    [_mowerControlButton addTarget:self action:@selector(mowerControlView) forControlEvents:UIControlEventTouchUpInside];
    [_BacktostationButton addTarget:self action:@selector(backToStation) forControlEvents:UIControlEventTouchUpInside];
    [_GoToWorkButton addTarget:self action:@selector(goToWork) forControlEvents:UIControlEventTouchUpInside];
    [_signalButton addTarget:self action:@selector(bluetoothControl) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_onLawn];
    [self.view addSubview:_onStation];
    [self.view addSubview:_batteryCapacity];
    [self.view addSubview:_BacktostationButton];
    [self.view addSubview:_GoToWorkButton];
    [self.view addSubview:_batteryButton];
    [self.view addSubview:_signalButton];
    [self.view addSubview:_mowerControlButton];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [_signalButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.025 + 44 + 64);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [_signalButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.01 + 44 + 64);
        }];
    }
    
    [_onLawn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.3653, ScreenHeight * 0.066));
        make.top.equalTo(self.signalButton.mas_bottom).offset(ScreenHeight * 0.125);
        make.right.equalTo(self.view.mas_centerX).offset(- ScreenWidth * 0.0507);
    }];
    [_onStation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.3653, ScreenHeight * 0.066));
        make.top.equalTo(self.onLawn.mas_bottom).offset(ScreenHeight * 0.05);
        make.left.equalTo(self.onLawn.mas_left);
    }];
    [_batteryCapacity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.3653, ScreenHeight * 0.066));
        make.top.equalTo(self.onStation.mas_bottom).offset(ScreenHeight * 0.05);
        make.left.equalTo(self.onLawn.mas_left);
    }];
    [_BacktostationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.3653, ScreenHeight * 0.066));
        make.left.equalTo(self.view.mas_centerX).offset(ScreenWidth * 0.0507);
        make.centerY.equalTo(self.onLawn.mas_centerY);
    }];
    [_GoToWorkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.3653, ScreenHeight * 0.066));
        make.left.equalTo(self.view.mas_centerX).offset(ScreenWidth * 0.0507);
        make.centerY.equalTo(self.onStation.mas_centerY);
    }];
    [_batteryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.3653, ScreenHeight * 0.066));
        make.left.equalTo(self.view.mas_centerX).offset(ScreenWidth * 0.0507);
        make.centerY.equalTo(self.batteryCapacity.mas_centerY);
    }];
    
    [_mowerControlButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.batteryCapacity.mas_bottom).offset(ScreenHeight * 0.1);
    }];
}

#pragma mark - inquire battery energy

- (void)inquireBatter{
    
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    
    [self.bluetoothDataManage setDataType:0x00];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}

#pragma mark - acquire battery energy
- (void)getBatterDataAndSetButton:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    
    //电量设置
    NSNumber *batterData = dict[@"batterData"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_batteryButton setTitle:[NSString stringWithFormat:@"%ld%%",(long)batterData.integerValue] forState:UIControlStateNormal];
        if (batterData.integerValue <= 20) {
            
            [_batteryButton setImage:[UIImage imageNamed:@"电量1-2"] forState:UIControlStateNormal];
            
        }else if (batterData.integerValue <= 40){
            
            [_batteryButton setImage:[UIImage imageNamed:@"电量2-2"] forState:UIControlStateNormal];
            
        }else if (batterData.integerValue <= 60){
            
            [_batteryButton setImage:[UIImage imageNamed:@"电量3-2"] forState:UIControlStateNormal];
            
        }else if (batterData.integerValue <=80){
            
            [_batteryButton setImage:[UIImage imageNamed:@"电量4-2"] forState:UIControlStateNormal];
            
        }else{
            
            [_batteryButton setImage:[UIImage imageNamed:@"电量5-2"] forState:UIControlStateNormal];
            
        }
        
        //按钮设置
        NSNumber *mowerState = dict[@"mowerState"];
        if (mowerState.integerValue == 1) {
            [self.onStation.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
            [self.onLawn.layer setBackgroundColor:[UIColor clearColor].CGColor];
            /*[self.GoToWorkButton.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
             [self.BacktostationButton.layer setBackgroundColor:[UIColor clearColor].CGColor];
             self.BacktostationButton.enabled = NO;
             self.GoToWorkButton.enabled = YES;*/
        }else{
            [self.onLawn.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
            [self.onStation.layer setBackgroundColor:[UIColor clearColor].CGColor];
            /*[self.BacktostationButton.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
             [self.GoToWorkButton.layer setBackgroundColor:[UIColor clearColor].CGColor];
             self.BacktostationButton.enabled = YES;
             self.GoToWorkButton.enabled = NO;*/
        }
    });
    
}

- (void)disconnectBluetooth:(NSNotification *)nsnotification
{
    //[self.signalButton setBackgroundImage:[UIImage imageNamed:@"蓝牙断开"] forState:UIControlStateNormal];
    if (_appDelegate.status == 1) {
        [self.signalButton setTitle:LocalString(@"Bluetooth disconnected") forState:UIControlStateNormal];
        [_signalButton.layer setBackgroundColor:[UIColor redColor].CGColor];
    }
}

#pragma mark - 当前时间处理

- (void)acquireDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *DateTime = [formatter stringFromDate:date];
    NSString *DateFull = [NSString stringWithFormat:@"%@ ,%@",DateTime,[self getTheTimeBucket]];
    //NSLog(@"%@",DateFull);
    //self.timeLabel.text = DateFull;
}

-(NSString *)getTheTimeBucket
{
    //    NSDate * currentDate = [self getNowDateFromatAnDate:[NSDate date]];
    
    NSDate * currentDate = [NSDate date];
    if ([currentDate compare:[self getCustomDateWithHour:0]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:9]] == NSOrderedAscending)
    {
        return NSLocalizedString(@"早上好", nil);
    }
    else if ([currentDate compare:[self getCustomDateWithHour:9]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:11]] == NSOrderedAscending)
    {
        return NSLocalizedString(@"上午好", nil);
    }
    else if ([currentDate compare:[self getCustomDateWithHour:11]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:13]] == NSOrderedAscending)
    {
        return NSLocalizedString(@"中午好", nil);
    }
    else if ([currentDate compare:[self getCustomDateWithHour:13]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:18]] == NSOrderedAscending)
    {
        return NSLocalizedString(@"下午好", nil);
    }
    else
    {
        return NSLocalizedString(@"晚上好", nil);
    }
}

- (NSDate *)getCustomDateWithHour:(NSInteger)hour
{
    //获取当前时间
    NSDate * destinationDateNow = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentComps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    currentComps = [currentCalendar components:unitFlags fromDate:destinationDateNow];
    
    //设置当前的时间点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [resultCalendar dateFromComponents:resultComps];
}

- (void)bluetoothControl{
    if (_appDelegate.status == 1) {
        if ([_signalButton.titleLabel.text isEqualToString:@"Bluetooth disconnected"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectBluetooth1" object:nil userInfo:nil];
            [self.signalButton setTitle:LocalString(@"Bluetooth disconnected") forState:UIControlStateNormal];
            [_signalButton.layer setBackgroundColor:[UIColor redColor].CGColor];
        }
    }else{
        if ([_signalButton.titleLabel.text isEqualToString:@"Wi-Fi disconnected"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else{
            if ([[NetWork shareNetWork].mySocket isConnected]) {
                [[NetWork shareNetWork].mySocket disconnect];
            }
            [self.signalButton setTitle:LocalString(@"Wi-Fi disconnected") forState:UIControlStateNormal];
            [_signalButton.layer setBackgroundColor:[UIColor redColor].CGColor];
        }
    }
    
}

#pragma mark - Control Mower
- (void)goToWork
{
    if (_appDelegate.status == 0 && [[NetWork shareNetWork].mySocket isDisconnected]) {
        [NSObject showHudTipStr:NSLocalizedString(@"Wi-Fi not connected", nil)];
        return;
    }
    if (_appDelegate.currentPeripheral == nil && _appDelegate.status == 1) {
        [NSObject showHudTipStr:NSLocalizedString(@"Bluetooth not connected", nil)];
        return;
    }
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x02]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x01];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
    
    /*[self.onLawn.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
     [self.BacktostationButton.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
     [self.onStation.layer setBackgroundColor:[UIColor clearColor].CGColor];
     [self.GoToWorkButton.layer setBackgroundColor:[UIColor clearColor].CGColor];
     self.BacktostationButton.enabled = YES;
     self.GoToWorkButton.enabled = NO;*/
}

- (void)backToStation
{
    if (_appDelegate.status == 0 && [[NetWork shareNetWork].mySocket isDisconnected]) {
        [NSObject showHudTipStr:NSLocalizedString(@"Wi-Fi not connected", nil)];
        return;
    }
    if (_appDelegate.currentPeripheral == nil && _appDelegate.status == 1) {
        [NSObject showHudTipStr:NSLocalizedString(@"Bluetooth not connected", nil)];
        return;
    }
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x03]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x01];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
    
    /*[self.onStation.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
     [self.GoToWorkButton.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
     [self.onLawn.layer setBackgroundColor:[UIColor clearColor].CGColor];
     [self.BacktostationButton.layer setBackgroundColor:[UIColor clearColor].CGColor];
     self.BacktostationButton.enabled = NO;
     self.GoToWorkButton.enabled = YES;*/
}

#pragma mark - ViewController
- (IBAction)MainViewControllerUnwindSegue:(UIStoryboardSegue *)unwindSegue {
    if ([unwindSegue.identifier isEqualToString:@"FromSettingToMain"]) {
        
    }
}

- (void)mowerControlView{
    if (_appDelegate.status == 0 && [[NetWork shareNetWork].mySocket isDisconnected]) {
        [NSObject showHudTipStr:NSLocalizedString(@"Wi-Fi not connected", nil)];
        return;
    }
    if (_appDelegate.currentPeripheral == nil && _appDelegate.status == 1) {
        [NSObject showHudTipStr:NSLocalizedString(@"Bluetooth not connected", nil)];
        return;
    }
    MowerControlViewController *VC = [[MowerControlViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
