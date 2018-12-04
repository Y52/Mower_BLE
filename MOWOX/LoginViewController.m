//
//  LoginViewController.m
//  MOWOX
//
//  Created by Mac on 2017/10/30.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "LoginViewController.h"
#import "Masonry.h"
#import "AppDelegate.h"
#import "RDVViewController.h"
#import "ChangePasswordViewController.h"
#import "BlueTableViewController.h"
#import "LMPopInputPasswordView.h"
#import "QueryDeviceController.h"


@interface LoginViewController () <UITextFieldDelegate,LMPopInputPassViewDelegate>

@property (strong, nonatomic)  UITextField *passwordTextfield;
@property (strong, nonatomic)  UIButton *connButton;
@property (strong, nonatomic)  UILabel *passwordLimitLabel;
@property (strong, nonatomic)  UIButton *LoginButton;
@property (strong, nonatomic)  UIButton *changeButton;

@property (strong, nonatomic)  UILabel *resultLabel;
@property (strong, nonatomic)  LMPopInputPasswordView *popView;

@property (strong, nonatomic)  UILabel *bluetoothNameLabel;
@property (strong, nonatomic)  BluetoothDataManage *bluetoothDataManage;

@property (strong, nonatomic)  AppDelegate *appDelegate;
@end

@implementation LoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
#if RobotMower
    UIImage *backImage = [UIImage imageNamed:@"loginView"];
#elif MOWOXROBOT
    UIImage *backImage = [UIImage imageNamed:@"App_BG_2-2"];
    //self.view.alpha = 0.8;
#endif
    
    self.view.layer.contents = (id)backImage.CGImage;
    
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    self.appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    [self viewLayoutSet];
    //self.passwordTextfield.delegate = self;

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    [self.LoginButton addTarget:self action:@selector(connectMower) forControlEvents:UIControlEventTouchUpInside];
    [self.connButton addTarget:self action:@selector(showConnView) forControlEvents:UIControlEventTouchUpInside];
    [self.changeButton addTarget:self action:@selector(changeConnWay) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    
}

-(void)dealloc{
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewLayoutSet{
    _bluetoothNameLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:20.0f] textColor:[UIColor whiteColor] text:LocalString(@"Connect bluetooth")];
    _passwordTextfield = [UITextField textFieldWithPlaceholderText:LocalString(@"")];
    _passwordTextfield.textAlignment = NSTextAlignmentCenter;
    UIColor *color = [UIColor whiteColor];
    _passwordTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Input password" attributes:@{NSForegroundColorAttributeName: color}];
    _passwordTextfield.textColor = [UIColor whiteColor];
    _passwordLimitLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:10.f] textColor:[UIColor whiteColor] text:@"6-12 characters or numbers"];
    [_passwordLimitLabel setFont:[UIFont systemFontOfSize:10.0]];
    _connButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (_appDelegate.status == 1) {
        [_connButton setBackgroundImage:[UIImage imageNamed:@"蓝牙图标"] forState:UIControlStateNormal];
        _changeButton = [UIButton buttonWithTitle:LocalString(@"Change to Wi-Fi") titleColor:[UIColor whiteColor]];
        _bluetoothNameLabel.text = LocalString(@"Connect bluetooth");
    }else{
        [_connButton setBackgroundImage:[UIImage imageNamed:@"img_wifi"] forState:UIControlStateNormal];
        _changeButton = [UIButton buttonWithTitle:LocalString(@"Change to Bluetooth") titleColor:[UIColor whiteColor]];
        _bluetoothNameLabel.text = LocalString(@"Connect Wi-Fi");
    }
    _LoginButton = [UIButton buttonWithTitle:LocalString(@"Control the robot") titleColor:[UIColor whiteColor]];
    
    [_passwordTextfield setTextFieldStyle1];
    [_LoginButton setButtonStyle1];
    [_changeButton setButtonStyle1];
    
    [self.view addSubview:_bluetoothNameLabel];
    [self.view addSubview:_passwordTextfield];
    [self.view addSubview:_passwordLimitLabel];
    [self.view addSubview:_LoginButton];
    [self.view addSubview:_connButton];
    [self.view addSubview:_changeButton];
    
    [_bluetoothNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.6, ScreenHeight * 0.04));
        make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.15);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_connButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(84, 84));
        make.top.equalTo(self.bluetoothNameLabel.mas_bottom).offset(ScreenHeight * 0.08);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [self.LoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.connButton.mas_bottom).offset(ScreenHeight * 0.4);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.bottom.equalTo(self.LoginButton.mas_top).offset(- ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

#pragma mark - ViewController push and back
- (void)connectMower
{
    //测试用直接进入APP
//    RDVViewController *rdvView = [[RDVViewController alloc] init];
//    rdvView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    [self presentViewController:rdvView animated:YES completion:nil];
//    return;
    if (_appDelegate.currentPeripheral == nil && [[NetWork shareNetWork].mySocket isDisconnected]) {
        if (_appDelegate.status == 0) {
            [NSObject showHudTipStr:LocalString(@"Wi-Fi not connected")];
        }else{
            [NSObject showHudTipStr:LocalString(@"Bluetooth not connected")];
        }
    }else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults integerForKey:@"pincode"]) {
            [BluetoothDataManage shareInstance].pincode = (int)[defaults integerForKey:@"pincode"];
            NSMutableArray *dataContent = [[NSMutableArray alloc] init];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            
            [self.bluetoothDataManage setDataType:0x0c];
            [self.bluetoothDataManage setDataContent: dataContent];
            [self.bluetoothDataManage sendBluetoothFrame];
        }else{
            NSMutableArray *dataContent = [[NSMutableArray alloc] init];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            
            [self.bluetoothDataManage setDataType:0x0c];
            [self.bluetoothDataManage setDataContent: dataContent];
            [self.bluetoothDataManage sendBluetoothFrame];
        }

        _resultLabel = [[UILabel alloc] init];
        _popView = [[LMPopInputPasswordView alloc]init];
        _popView.frame = CGRectMake((self.view.frame.size.width - 250)*0.5, 50, 250, 150);
        _popView.delegate = self;
        [_popView pop];
    }
    /*
    RDVViewController *rdvView = [[RDVViewController alloc] init];
    rdvView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:rdvView animated:YES completion:nil];
     */
}

- (void)changeView{
    ChangePasswordViewController *changeVC = [[ChangePasswordViewController alloc] init];
    [self.navigationController pushViewController:changeVC animated:YES];
}

- (void)showConnView{
    if (_appDelegate.status == 1) {
        BlueTableViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BlueTableViewController"];
        NSLog(@"%@", self.storyboard);
        [self.navigationController pushViewController:detailVC animated:YES];
    }else{
        QueryDeviceController *wifiVC = [[QueryDeviceController alloc] init];
        [self.navigationController pushViewController:wifiVC animated:YES];
    }
}

- (IBAction)LoginViewControllerUnwindSegue:(UIStoryboardSegue *)unwindSegue {
    
}

#pragma mark ---LMPopInputPassViewDelegate
-(void)buttonClickedAtIndex:(NSUInteger)index withText:(NSString *)text
{
    NSLog(@"buttonIndex = %li password=%@",(long)index,text);
    if(index == 1){
        if(text.length == 0){
            NSLog(@"密码长度不正确Incorrect password length");
            [NSObject showHudTipStr:LocalString(@"Incorrect PIN code length")];
        }else if(text.length < 4){
            NSLog(@"密码长度不正确");
            [NSObject showHudTipStr:LocalString(@"Incorrect PIN code length")];
        }else{
            _resultLabel.text = text;
            if ([text intValue] == [BluetoothDataManage shareInstance].pincode) {
                [self setMowerTime];
                
                RDVViewController *rdvView = [[RDVViewController alloc] init];
                rdvView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentViewController:rdvView animated:YES completion:nil];
            }else{
                NSMutableArray *dataContent = [[NSMutableArray alloc] init];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                
                [self.bluetoothDataManage setDataType:0x0c];
                [self.bluetoothDataManage setDataContent: dataContent];
                [self.bluetoothDataManage sendBluetoothFrame];
                
                [NSObject showHudTipStr:LocalString(@"Incorrect PIN code")];
            }
            /*if ([_resultLabel.text isEqualToString:@"1234"]) {
                RDVViewController *rdvView = [[RDVViewController alloc] init];
                rdvView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentViewController:rdvView animated:YES completion:nil];
            }*/
        }
    }
}

-(void)deviceOrientationDidChange:(NSObject*)sender{
    UIDevice* device = [sender valueForKey:@"object"];
    if(device.orientation==UIInterfaceOrientationLandscapeLeft||device.orientation==UIInterfaceOrientationLandscapeRight)
    {
        _popView.frame = CGRectMake((self.view.frame.size.width - 250)*0.5, 50, 250, 150);
    }
    else if(device.orientation==UIInterfaceOrientationPortrait||device.orientation==UIInterfaceOrientationPortraitUpsideDown)
    {
        _popView.frame = CGRectMake((self.view.frame.size.width - 250)*0.5, 50, 250, 150);
    }
}

#pragma mark - change rootvc
- (void)changeConnWay{
    if (_appDelegate.status == 0) {
        _appDelegate.status = 1;
        [_connButton setBackgroundImage:[UIImage imageNamed:@"蓝牙图标"] forState:UIControlStateNormal];
        [_changeButton setTitle:LocalString(@"Change to Wi-Fi") forState:UIControlStateNormal];
        _bluetoothNameLabel.text = LocalString(@"Connect bluetooth");
    }else{
        _appDelegate.status = 0;
        [_connButton setBackgroundImage:[UIImage imageNamed:@"img_wifi"] forState:UIControlStateNormal];
        [_changeButton setTitle:LocalString(@"Change to Bluetooth") forState:UIControlStateNormal];

        _bluetoothNameLabel.text = LocalString(@"Connect Wi-Fi");
    }
}

- (void)setMowerTime{
    NSDate *date = [NSDate date];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];    //IOS 8 之后
    NSUInteger integer = NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *dataCom = [currentCalendar components:integer fromDate:date];
    
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[dataCom year] / 100]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[dataCom year] % 100]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[dataCom month]]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[dataCom day]]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[dataCom hour]]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[dataCom minute]]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x02];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}

@end
