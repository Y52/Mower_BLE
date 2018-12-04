//
//  ChangePasswordViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/6.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Masonry.h"
#import "AppDelegate.h"

@interface ChangePasswordViewController () <UITextFieldDelegate>

@property (strong, nonatomic)  UITextField *inputOldPasswordTextField;
@property (strong, nonatomic)  UITextField *inputNewPasswordTextField;
@property (strong, nonatomic)  UITextField *repeatNewPasswordTextField;
@property (strong, nonatomic)  UILabel *numberLabel1;
@property (strong, nonatomic)  UILabel *numberLabel2;
@property (strong, nonatomic)  UILabel *numberLabel3;
@property (strong, nonatomic)  UIButton *okButton;

@property (readonly, nonatomic) CGFloat backupY;
@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage *backImage = [UIImage imageNamed:@"backgroundnew"];
    self.view.layer.contents = (id)backImage.CGImage;
    
    self.navigationItem.title = LocalString(@"Change password");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self viewLayoutSet];
    
    //[self.okButton addTarget:self action:@selector(changePassword) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)viewLayoutSet{
    _numberLabel1 = [UILabel labelWithFont:[UIFont systemFontOfSize:10] textColor:[UIColor blackColor] text:LocalString(@"6-12 characters or numbers")];
    _numberLabel2 = [UILabel labelWithFont:[UIFont systemFontOfSize:10] textColor:[UIColor blackColor] text:LocalString(@"6-12 characters or numbers")];
    _numberLabel3 = [UILabel labelWithFont:[UIFont systemFontOfSize:10] textColor:[UIColor blackColor] text:LocalString(@"6-12 characters or numbers")];
    [_numberLabel1 setFont:[UIFont systemFontOfSize:10.0]];
    [_numberLabel2 setFont:[UIFont systemFontOfSize:10.0]];
    [_numberLabel3 setFont:[UIFont systemFontOfSize:10.0]];
    
    _inputOldPasswordTextField = [UITextField textFieldWithPlaceholderText:LocalString(@"Input Old Password")];
    _inputNewPasswordTextField = [UITextField textFieldWithPlaceholderText:LocalString(@"Input New Password")];
    _repeatNewPasswordTextField = [UITextField textFieldWithPlaceholderText:LocalString(@"Repeat New Password")];
    //_inputNewPasswordTextField.keyboardType = UIKeyboardTypeNumberPad;
    //_inputOldPasswordTextField.keyboardType = UIKeyboardTypeNumberPad;
    //_repeatNewPasswordTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_inputOldPasswordTextField setTextFieldStyle1];
    [_inputNewPasswordTextField setTextFieldStyle1];
    [_repeatNewPasswordTextField setTextFieldStyle1];
    
    _okButton = [UIButton buttonWithTitle:LocalString(@"OK") titleColor:[UIColor blackColor]];
    [_okButton setButtonStyle1];
    [_okButton addTarget:self action:@selector(setPassword) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_numberLabel1];
    [self.view addSubview:_numberLabel2];
    [self.view addSubview:_numberLabel3];
    [self.view addSubview:_inputOldPasswordTextField];
    [self.view addSubview:_inputNewPasswordTextField];
    [self.view addSubview:_repeatNewPasswordTextField];
    [self.view addSubview:_okButton];
    
    [_inputOldPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.15 + 44);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_numberLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.4, ScreenHeight * 0.022));
        make.top.equalTo(self.inputOldPasswordTextField.mas_bottom).offset(ScreenHeight * 0.01);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_inputNewPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.numberLabel1.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_numberLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.4, ScreenHeight * 0.022));
        make.top.equalTo(self.inputNewPasswordTextField.mas_bottom).offset(ScreenHeight * 0.01);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_repeatNewPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.numberLabel2.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_numberLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.4, ScreenHeight * 0.022));
        make.top.equalTo(self.repeatNewPasswordTextField.mas_bottom).offset(ScreenHeight * 0.01);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.6, ScreenHeight * 0.066));
        make.top.equalTo(self.numberLabel3.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];

}
#pragma mark - resign keyboard control

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.inputOldPasswordTextField resignFirstResponder];
    [self.inputNewPasswordTextField resignFirstResponder];
    [self.repeatNewPasswordTextField resignFirstResponder];
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
    CGFloat rects = (ScreenHeight - _okButton.frame.origin.y - _okButton.frame.size.height) - height;
    
    if (rects <= 0) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.view.frame;
            if (_backupY == 0) {
                _backupY = self.view.frame.origin.y;
            }
            frame.origin.y = rects;
            self.view.frame = frame;
        }];
    }
}
-(void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = _backupY;
        self.view.frame = frame;
    }];
}

#pragma mark - bluetooth manager

- (void)setPassword
{
    if (!(self.inputOldPasswordTextField.text.length <= 12 && self.inputOldPasswordTextField.text.length >= 6 && self.inputNewPasswordTextField.text.length <= 12 && self.inputNewPasswordTextField.text.length >= 6 && self.repeatNewPasswordTextField.text.length <= 12 && self.repeatNewPasswordTextField.text.length >= 6)) {
        [NSObject showHudTipStr:@"密码长度为6-12个字符或数字"];
    }else if (![self.inputNewPasswordTextField.text isEqualToString:self.repeatNewPasswordTextField.text])
    {
        [NSObject showHudTipStr:@"两次输入不一致"];
    }else{

    }
}


@end
