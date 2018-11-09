//
//  MowerControlViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/29.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "MowerControlViewController.h"
#import "BluetoothDataManage.h"
#import "SettingViewController.h"

@interface MowerControlViewController ()
///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;

@property (strong, nonatomic)  UIButton *startButton;
@property (strong, nonatomic)  UIButton *stopButton;
@property (strong, nonatomic)  UIButton *alertsButton;
@property (strong, nonatomic)  UIButton *settingButton;

@end

@implementation MowerControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
        
    //解决navigationitem标题右偏移
//    NSArray *viewControllerArray = [self.navigationController viewControllers];
//    long previousViewControllerIndex = [viewControllerArray indexOfObject:self] - 1;
//    UIViewController *previous;
//    if (previousViewControllerIndex >= 0) {
//        previous = [viewControllerArray objectAtIndex:previousViewControllerIndex];
//        previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
//                                                     initWithTitle:@""
//                                                     style:UIBarButtonItemStylePlain
//                                                     target:self
//                                                     action:nil];
//    }
    self.navigationItem.title = LocalString(@"Robot Control");
    
    
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    
    [self viewLayoutSet];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.settingButton addTarget:self action:@selector(goSettingView) forControlEvents:UIControlEventTouchUpInside];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewLayoutSet{
    
    UIImage *image = [UIImage imageNamed:@"返回1"];
    [self addLeftBarButtonWithImage:image action:@selector(backAction)];
    
    _startButton = [UIButton buttonWithTitle:LocalString(@"Start") titleColor:[UIColor blackColor]];
    _stopButton = [UIButton buttonWithTitle:LocalString(@"Stop") titleColor:[UIColor blackColor]];
    _alertsButton = [UIButton buttonWithTitle:LocalString(@"Alerts") titleColor:[UIColor blackColor]];
    _settingButton = [UIButton buttonWithTitle:LocalString(@"Setting") titleColor:[UIColor blackColor]];
    [_startButton setButtonStyle1];
    [_stopButton setButtonStyle1];
    [_alertsButton setButtonStyle1];
    [_settingButton setButtonStyle1];
    [self.view addSubview:_startButton];
    [self.view addSubview:_stopButton];
    [self.view addSubview:_alertsButton];
    [self.view addSubview:_settingButton];
    
    [_startButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [_stopButton addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [_alertsButton addTarget:self action:@selector(alert) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [_startButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.1 + 44 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [_startButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.02 + 44 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    
    [_stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.startButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_alertsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.stopButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.alertsButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

#pragma mark - mower control
- (void)viewAlert
{
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x61];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}

- (void)start
{
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
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
}

- (void)stop
{
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x01]];
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
}

- (void)alert
{

}

- (void)goSettingView{
    //self.rdv_tabBarController.selectedIndex = 2;
    SettingViewController *setVC = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:setVC animated:YES];
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
