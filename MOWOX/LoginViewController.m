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


@interface LoginViewController () <UITextFieldDelegate,LMPopInputPassViewDelegate>

@property (strong, nonatomic)  UITextField *passwordTextfield;
@property (strong, nonatomic)  UIButton *bluetoothButton;
@property (strong, nonatomic)  UIButton *changePasswordButton;
@property (strong, nonatomic)  UILabel *passwordLimitLabel;
@property (strong, nonatomic)  UIButton *LoginButton;

@property (strong, nonatomic)  UILabel *resultLabel;
@property (strong, nonatomic)  LMPopInputPasswordView *popView;

@property (strong, nonatomic)  UILabel *bluetoothNameLabel;
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;

@property (strong, nonatomic) AppDelegate *appDelegate;
@end

@implementation LoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *backImage = [UIImage imageNamed:@"loginView"];
    self.view.layer.contents = (id)backImage.CGImage;
    
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
    [self.changePasswordButton addTarget:self action:@selector(changeView) forControlEvents:UIControlEventTouchUpInside];
    [self.bluetoothButton addTarget:self action:@selector(bluetoothConnect) forControlEvents:UIControlEventTouchUpInside];
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
    _bluetoothNameLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:20.0f] textColor:[UIColor whiteColor] text:LocalString(@"Connected bluetooth")];
    _passwordTextfield = [UITextField textFieldWithPlaceholderText:LocalString(@"")];
    _passwordTextfield.textAlignment = NSTextAlignmentCenter;
    UIColor *color = [UIColor whiteColor];
    _passwordTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Input password" attributes:@{NSForegroundColorAttributeName: color}];
    _passwordTextfield.textColor = [UIColor whiteColor];
    _passwordLimitLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:10.f] textColor:[UIColor whiteColor] text:@"6-12 characters or numbers"];
    [_passwordLimitLabel setFont:[UIFont systemFontOfSize:10.0]];
    _changePasswordButton = [UIButton buttonWithTitle:LocalString(@"Change Password") titleColor:[UIColor whiteColor]];
    _bluetoothButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_bluetoothButton setBackgroundImage:[UIImage imageNamed:@"蓝牙图标"] forState:UIControlStateNormal];
    _LoginButton = [UIButton buttonWithTitle:LocalString(@"Control the mower") titleColor:[UIColor whiteColor]];
    
    [_passwordTextfield setTextFieldStyle1];
    [_changePasswordButton setButtonStyle1];
    [_LoginButton setButtonStyle1];
    
    [self.view addSubview:_bluetoothNameLabel];
    [self.view addSubview:_passwordTextfield];
    [self.view addSubview:_passwordLimitLabel];
    [self.view addSubview:_changePasswordButton];
    [self.view addSubview:_LoginButton];
    [self.view addSubview:_bluetoothButton];
    
    [_bluetoothNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.6, ScreenHeight * 0.04));
        make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.15);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_bluetoothButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(84, 84));
        make.top.equalTo(self.bluetoothNameLabel.mas_bottom).offset(ScreenHeight * 0.08);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    /*[self.passwordTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.bluetoothButton.mas_bottom).offset(ScreenHeight * 0.08);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_passwordLimitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.4, ScreenHeight * 0.022));
        make.top.equalTo(self.passwordTextfield.mas_bottom).offset(ScreenHeight * 0.01);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [self.changePasswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.passwordLimitLabel.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];*/
    [self.LoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.bluetoothButton.mas_bottom).offset(ScreenHeight * 0.4);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

#pragma mark - resign keyboard control

/****
 - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.passwordTextfield resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField*) textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)keyboardWillShow:(NSNotification *)notification{
    //键盘最后的frame
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    //需要移动的距离
    CGFloat rects = (ScreenHeight * 0.31 - 84) - height;
    
    if (rects <= 0) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y = rects;
            self.view.frame = frame;
        }];
    }
}
-(void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0.0;
        self.view.frame = frame;
    }];
}
****/
#pragma mark - ViewController push and back
- (void)connectMower
{
    self.appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (_appDelegate.currentPeripheral == nil) {
        [NSObject showHudTipStr:@"Bluetooth is not connected"];
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
        
        _resultLabel = [[UILabel alloc] init];
        _popView = [[LMPopInputPasswordView alloc]init];
        _popView.frame = CGRectMake((self.view.frame.size.width - 250)*0.5, 50, 250, 150);
        _popView.delegate = self;
        [_popView pop];
    }
}

- (void)changeView{
    ChangePasswordViewController *changeVC = [[ChangePasswordViewController alloc] init];
    [self.navigationController pushViewController:changeVC animated:YES];
}

- (void)bluetoothConnect{
    BlueTableViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BlueTableViewController"];
    NSLog(@"%@", self.storyboard);
    [self.navigationController pushViewController:detailVC animated:YES];
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
            [NSObject showHudTipStr:LocalString(@"Incorrect password length")];
        }else if(text.length < 4){
            NSLog(@"密码长度不正确");
            [NSObject showHudTipStr:LocalString(@"Incorrect password length")];
        }else{
            _resultLabel.text = text;
            if ([text intValue] == [BluetoothDataManage shareInstance].pincode) {
                RDVViewController *rdvView = [[RDVViewController alloc] init];
                rdvView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentViewController:rdvView animated:YES completion:nil];
            }else{
                [NSObject showHudTipStr:LocalString(@"Incorrect password")];
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

@end
