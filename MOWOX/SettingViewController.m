//
//  SettingViewController.m
//  MOWOX
//
//  Created by Mac on 2017/10/30.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "SettingViewController.h"
#import "BluetoothDataManage.h"
#import "GeneralsettingLanguageViewController.h"
#import "GeneralsettingTimeViewController.h"
#import "WorkTimeSettingViewController.h"
#import "PincodeSettingViewController.h"
#import "MowerSettingViewController.h"
#import "FirmwareViewController.h"

@interface SettingViewController ()

///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;


@property (strong, nonatomic)  UIButton *LanguageButton;
@property (strong, nonatomic)  UIButton *TimeButton;
@property (strong, nonatomic)  UIButton *WorktimeButton;
@property (strong, nonatomic)  UIButton *PinButton;
@property (strong, nonatomic)  UIButton *mowerButton;
@property (strong, nonatomic)  UIButton *updateButton;

@end

@implementation SettingViewController

static int version1 = 1;
static int version2 = 2;
static int version3 = 13;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = LocalString(@"Setting");
    
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    
    [self viewLayoutSet];
    if (version1 > [BluetoothDataManage shareInstance].version1) {
        _updateButton.hidden = NO;
    }
    if(version1 == [BluetoothDataManage shareInstance].version1 && version2 > [BluetoothDataManage shareInstance].version2){
        _updateButton.hidden = NO;
    }
    if (version1 == [BluetoothDataManage shareInstance].version1 && version2 == [BluetoothDataManage shareInstance].version2 && version3 > [BluetoothDataManage shareInstance].version3){
        _updateButton.hidden = NO;
    }
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (appDelegate.status == 0) {
        _updateButton.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewLayoutSet
{
    if (self.rdv_tabBarController.selectedIndex == 2) {
        UIImage *image = [UIImage imageNamed:@"返回1"];
        [self addLeftBarButtonWithImage:image action:@selector(backAction)];
    }else if (self.rdv_tabBarController.selectedIndex == 1){
        UIImage *image = [UIImage imageNamed:@"返回1"];
        [self addLeftBarButtonWithImage:image action:@selector(backAction1)];
    }
    
    _LanguageButton = [UIButton buttonWithTitle:LocalString(@"Language setting") titleColor:[UIColor blackColor]];
    _TimeButton = [UIButton buttonWithTitle:LocalString(@"Time setting") titleColor:[UIColor blackColor]];
    _WorktimeButton = [UIButton buttonWithTitle:LocalString(@"Working time setting") titleColor:[UIColor blackColor]];
    _PinButton = [UIButton buttonWithTitle:LocalString(@"Pin setting") titleColor:[UIColor blackColor]];
    _mowerButton = [UIButton buttonWithTitle:LocalString(@"Mower setting") titleColor:[UIColor blackColor]];
    _updateButton = [UIButton buttonWithTitle:LocalString(@"Update Mower's Firmware") titleColor:[UIColor blackColor]];
    _updateButton.hidden = YES;
    [_LanguageButton setButtonStyle1];
    [_TimeButton setButtonStyle1];
    [_WorktimeButton setButtonStyle1];
    [_PinButton setButtonStyle1];
    [_mowerButton setButtonStyle1];
    [_updateButton setButtonStyle1];
    [_LanguageButton addTarget:self action:@selector(languageSet) forControlEvents:UIControlEventTouchUpInside];
    [_TimeButton addTarget:self action:@selector(timeSet) forControlEvents:UIControlEventTouchUpInside];
    [_WorktimeButton addTarget:self action:@selector(worktimeSet) forControlEvents:UIControlEventTouchUpInside];
    [_PinButton addTarget:self action:@selector(pinSet) forControlEvents:UIControlEventTouchUpInside];
    [_mowerButton addTarget:self action:@selector(mowerSet) forControlEvents:UIControlEventTouchUpInside];
    [_updateButton addTarget:self action:@selector(updateWare) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_LanguageButton];
    [self.view addSubview:_TimeButton];
    [self.view addSubview:_WorktimeButton];
    [self.view addSubview:_PinButton];
    [self.view addSubview:_mowerButton];
    [self.view addSubview:_updateButton];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [_LanguageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.05 + 44 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [_LanguageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.01 + 44 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }

    [_TimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.LanguageButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_WorktimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.TimeButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_mowerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.WorktimeButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_PinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.mowerButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_updateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.PinButton.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];

}


#pragma mark - ViewController
- (void)languageSet{
    GeneralsettingLanguageViewController *VC = [[GeneralsettingLanguageViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)timeSet{
    GeneralsettingTimeViewController *VC = [[GeneralsettingTimeViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)worktimeSet{
    WorkTimeSettingViewController *VC = [[WorkTimeSettingViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)pinSet{
    PincodeSettingViewController *VC = [[PincodeSettingViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)mowerSet{
    MowerSettingViewController *VC = [[MowerSettingViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)backAction{
    self.rdv_tabBarController.selectedIndex = 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingVCBack" object:nil userInfo:nil];
}

- (void)backAction1{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateWare{
    FirmwareViewController *VC = [[FirmwareViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

@end
