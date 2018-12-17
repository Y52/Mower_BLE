//
//  LoginViewController.m
//  MOWOX
//
//  Created by Mac on 2017/10/30.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import <GizWifiSDK/GizWifiSDK.h>
#import "MainViewController.h"

@interface LoginViewController () <UITextFieldDelegate,GizWifiSDKDelegate>

@property (nonatomic, strong) UITextField *emailTF;
@property (nonatomic, strong) UITextField *passwordTF;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *RegisterBtn;
@property (nonatomic, strong) UIButton *forgetPWBtn;

@end

@implementation LoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    //self.view.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"loginView.png"]];

    //_headerImage = [self headerImage];
    _emailTF = [self emailTF];
    _passwordTF = [self passwordTF];
    _loginBtn = [self loginBtn];
    _RegisterBtn = [self RegisterBtn];
    _forgetPWBtn = [self forgetPWBtn];

    [GizWifiSDK sharedInstance].delegate = self;
 
}

- (UITextField *)emailTF{
    if (!_emailTF) {
        _emailTF = [[UITextField alloc] init];
        _emailTF.backgroundColor = [UIColor clearColor];
        _emailTF.font = [UIFont systemFontOfSize:16.f];
        _emailTF.textColor = [UIColor whiteColor];
        _emailTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _emailTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _emailTF.delegate = self;
        _emailTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _emailTF.borderStyle = UITextBorderStyleRoundedRect;
        [_emailTF addTarget:self action:@selector(textFieldTextChange) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_emailTF];
        [_emailTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(280/WScale, 40/HScale));
            make.top.equalTo(self.view.mas_top).offset(200/HScale);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
        _emailTF.layer.borderWidth = 1.0;
        _emailTF.layer.borderColor = [UIColor whiteColor].CGColor;
        _emailTF.layer.cornerRadius = 10.f/HScale;
        _emailTF.placeholder = LocalString(@"e-mail");
        [_emailTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        [_emailTF setValue:[UIFont boldSystemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];
    }
    return _emailTF;
}
- (UITextField *)passwordTF{
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc] init];
        _passwordTF.backgroundColor = [UIColor clearColor];
        _passwordTF.font = [UIFont systemFontOfSize:15.f];
        _passwordTF.textColor = [UIColor whiteColor];
        _passwordTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _passwordTF.delegate = self;
        _passwordTF.secureTextEntry = YES;
        _passwordTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _passwordTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _passwordTF.borderStyle = UITextBorderStyleRoundedRect;
     
        [_passwordTF addTarget:self action:@selector(textFieldTextChange) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_passwordTF];
        [_passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(280/WScale, 40/HScale));
            make.top.equalTo(self.emailTF.mas_bottom).offset(30);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
        _passwordTF.layer.borderWidth = 1.0;
        _passwordTF.layer.borderColor = [UIColor whiteColor].CGColor;
        _passwordTF.layer.cornerRadius = 10.f/HScale;
        _passwordTF.placeholder = LocalString(@"password");
        [_passwordTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        [_passwordTF setValue:[UIFont boldSystemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];

    }
    return _passwordTF;
}
//监听文本框事件
- (void)textFieldTextChange{
    if (_emailTF.text.length >0 && _passwordTF.text.length > 0){
        [_loginBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        _loginBtn.enabled = YES;
    }else{
        [_loginBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        _loginBtn.enabled = NO;
    }
}
- (UIButton *)loginBtn{
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:LocalString(@"Sign In") forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginBtn setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:0.6]];
        [_loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        _loginBtn.enabled = YES;
        [self.view addSubview:_loginBtn];
        [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(280/WScale, 40/HScale));
            make.top.equalTo(self.passwordTF.mas_bottom).offset(30/HScale);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
        
        _loginBtn.layer.borderWidth = 1.0;
        _loginBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _loginBtn.layer.cornerRadius = 10.f/HScale;
        
       
    }
    return _loginBtn;
}
- (UIButton *)RegisterBtn{
    if (!_RegisterBtn) {
        _RegisterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_RegisterBtn setTitle:LocalString(@"Register") forState:UIControlStateNormal];
        [_RegisterBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        [_RegisterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_RegisterBtn addTarget:self action:@selector(registerLogin) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_RegisterBtn];
        [_RegisterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(54/WScale, 16/HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.loginBtn.mas_bottom).offset(50/HScale);
        }];
    }
    return _RegisterBtn;
}
- (UIButton *) forgetPWBtn{
    if (!_forgetPWBtn) {
        _forgetPWBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgetPWBtn setTitle:LocalString(@"Forget Password") forState:UIControlStateNormal];
        [_forgetPWBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_forgetPWBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        [_forgetPWBtn addTarget:self action:@selector(forgetPW) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_forgetPWBtn];
        [_forgetPWBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(120/WScale, 16/HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.RegisterBtn.mas_bottom).offset(30/HScale);
        }];
    }
    return _forgetPWBtn;
}

#pragma mark - uitextfield delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
    
}

#pragma mark - GizWifiSDK delegate
// 实现回调
- (void)wifiSDK:(GizWifiSDK *)wifiSDK didUserLogin:(NSError *)result uid:(NSString *)uid token:(NSString *)token {
    if(result.code == GIZ_SDK_SUCCESS) {
        // 登录成功
        NSLog(@"登录成功,%@", result);
//        MainViewController *VC = [[MainViewController alloc] init];
//        [self.navigationController pushViewController:VC animated:YES];
    } else {
        // 登录失败
        NSLog(@"登录失败,%@", result);
        
    }
    
}

#pragma mark - Actions
- (void)login{
    
    NSLog(@"saaaaaaas");
    [[GizWifiSDK sharedInstance] userLogin:_emailTF.text password:_passwordTF.text];
    MainViewController *VC = [[MainViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
    
}

- (void)registerLogin{
    RegisterViewController *VC = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}
- (void)forgetPW{
    NSLog(@"qq");
}


@end
