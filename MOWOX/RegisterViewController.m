//
//  RegisterViewController.m
//  MOWOX
//
//  Created by 安建伟 on 2018/12/14.
//  Copyright © 2018 yusz. All rights reserved.
//

#import "RegisterViewController.h"
#import <GizWifiSDK/GizWifiSDK.h>

@interface RegisterViewController () <UITextFieldDelegate,GizWifiSDKDelegate>

@property (nonatomic, strong) UITextField *nameTF;
@property (nonatomic, strong) UITextField *emailTF;
@property (nonatomic, strong) UITextField *countryTF;
@property (nonatomic, strong) UISwitch *agreeSwitch;
@property (nonatomic, strong) UIButton *RegisterBtn;

@property (nonatomic, strong) UILabel *agreeLabel;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"loginView.png"]];
    [self setNavItem];
    _nameTF = [self nameTF];
    _emailTF = [self emailTF];
    _countryTF = [self countryTF];
    _RegisterBtn = [self RegisterBtn];
    _agreeSwitch = [self agreeSwitch];
    _agreeLabel = [self agreeLabel];
    [GizWifiSDK sharedInstance].delegate = self;
   
}

- (void)setNavItem{
    self.navigationItem.title = LocalString(@"Register");
}

- (UITextField *)nameTF{
    if (!_nameTF) {
        _nameTF = [[UITextField alloc] init];
        _nameTF.backgroundColor = [UIColor clearColor];
        _nameTF.font = [UIFont systemFontOfSize:16.f];
        _nameTF.textColor = [UIColor whiteColor];
        _nameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nameTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _nameTF.delegate = self;
        _nameTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _nameTF.borderStyle = UITextBorderStyleRoundedRect;
        [_nameTF addTarget:self action:@selector(textFieldTextChange) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_nameTF];
        [_nameTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(280/WScale, 40/HScale));
            make.top.equalTo(self.view.mas_top).offset(200/HScale);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
        
        _nameTF.layer.borderWidth = 1.0;
        _nameTF.layer.borderColor = [UIColor whiteColor].CGColor;
        _nameTF.layer.cornerRadius = 10.f/HScale;
        _nameTF.placeholder = LocalString(@"Name");
        [_nameTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        [_nameTF setValue:[UIFont boldSystemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];
    }
    return _nameTF;
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
            make.top.equalTo(self.nameTF.mas_bottom).offset(30/HScale);
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

- (UITextField *)countryTF{
    if (!_countryTF) {
        _countryTF = [[UITextField alloc] init];
        _countryTF.backgroundColor = [UIColor clearColor];
        _countryTF.font = [UIFont systemFontOfSize:16.f];
        _countryTF.textColor = [UIColor whiteColor];
        _countryTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _countryTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _countryTF.delegate = self;
        _countryTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _countryTF.borderStyle = UITextBorderStyleRoundedRect;
        [_countryTF addTarget:self action:@selector(textFieldTextChange) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_countryTF];
        [_countryTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(280/WScale, 40/HScale));
            make.top.equalTo(self.emailTF.mas_bottom).offset(30/HScale);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
        
        _countryTF.layer.borderWidth = 1.0;
        _countryTF.layer.borderColor = [UIColor whiteColor].CGColor;
        _countryTF.layer.cornerRadius = 10.f/HScale;
        _countryTF.placeholder = LocalString(@"Country");
        [_countryTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        [_countryTF setValue:[UIFont boldSystemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];
    }
    return _countryTF;
}

- (UISwitch *)agreeSwitch{
    if (!_agreeSwitch) {
        _agreeSwitch = [[UISwitch alloc]init];
        [_agreeSwitch setThumbTintColor:[UIColor whiteColor]];
        _agreeSwitch.layer.cornerRadius = 15.5f;
        _agreeSwitch.layer.masksToBounds = YES;
        [_agreeSwitch addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_agreeSwitch];
        [_agreeSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60/WScale, 30/HScale));
            make.left.equalTo(self.view.mas_left).offset(64/WScale);
            make.top.equalTo(self.countryTF.mas_bottom).offset(30/HScale);
        }];
    }
    return _agreeSwitch;
}

- (UILabel *)agreeLabel{
    if (!_agreeLabel) {
        _agreeLabel = [[UILabel alloc] init];
        _agreeLabel.font = [UIFont systemFontOfSize:20.f];
        _agreeLabel.backgroundColor = [UIColor clearColor];
        _agreeLabel.textColor = [UIColor whiteColor];
        _agreeLabel.textAlignment = NSTextAlignmentLeft;
        _agreeLabel.text = LocalString(@"I agree to the Terms of Use");
        [self.view addSubview:_agreeLabel];
        [_agreeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(300/WScale, 20/HScale));
            make.left.equalTo(self.agreeSwitch.mas_right).offset(15/WScale);
            make.top.equalTo(self.countryTF.mas_bottom).offset(30/HScale);
        }];
    }
    return _agreeLabel;
}

- (UIButton *)RegisterBtn{
    if (!_RegisterBtn) {
        _RegisterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_RegisterBtn setTitle:LocalString(@"Register") forState:UIControlStateNormal];
        [_RegisterBtn.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
        [_RegisterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_RegisterBtn setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:0.6]];
        [_RegisterBtn addTarget:self action:@selector(registerLogin) forControlEvents:UIControlEventTouchUpInside];
        _RegisterBtn.enabled = YES;
        [self.view addSubview:_RegisterBtn];
        [_RegisterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(280/WScale, 40/HScale));
            make.top.equalTo(self.agreeSwitch.mas_bottom).offset(30/HScale);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
        
        _RegisterBtn.layer.borderWidth = 1.0;
        _RegisterBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _RegisterBtn.layer.cornerRadius = 10.f/HScale;
        
        
    }
    return _RegisterBtn;
}

//监听文本框事件
- (void)textFieldTextChange{
    
    if (_emailTF.text.length >0 && _nameTF.text.length > 0 && _countryTF.text.length > 0){
        _RegisterBtn.enabled = YES;
    }else{
        _RegisterBtn.enabled = NO;
    }
}

// 实现回调
- (void)wifiSDK:(GizWifiSDK *)wifiSDK didRegisterUser:(NSError *)result uid:(NSString *)uid token:(NSString *)token {
    if(result.code == GIZ_SDK_SUCCESS) {
        // 注册成功
        NSLog(@"注册成功");
        
    } else {
        // 注册失败
        NSLog(@"注册失败");
    }
    
}

-(void)switchAction{
    
    NSLog(@"tt");
    
}

-(void)registerLogin{
    NSLog(@"aa");
    
    [[GizWifiSDK sharedInstance] registerUser:_nameTF.text password:_emailTF.text verifyCode:nil accountType:GizUserEmail];
 
}

@end
