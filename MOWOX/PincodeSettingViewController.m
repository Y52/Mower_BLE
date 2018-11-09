//
//  PincodeSettingViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/6.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "PincodeSettingViewController.h"
#import "BluetoothDataManage.h"
#import "AppDelegate.h"
#import "Masonry.h"

@interface PincodeSettingViewController () <UITextFieldDelegate>

///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;

@property (strong, nonatomic) UILabel *numberLabel1;
@property (strong, nonatomic) UILabel *numberLabel2;
@property (strong, nonatomic) UILabel *numberLabel3;
@property (strong, nonatomic) UIButton *okButton;

@property (strong, nonatomic) UITextField *inputOldPinCodeTextField;
@property (strong, nonatomic) UITextField *inputNewPinCodeTextField;
@property (strong, nonatomic) UITextField *repeatNewPinCodeTextField;

@property (readonly, nonatomic) CGFloat backupY;

@end

@implementation PincodeSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];

    self.navigationItem.title = LocalString(@"PIN code setting");
    
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    
    [self viewLayoutSet];
    [self.okButton addTarget:self action:@selector(setPinCode) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewLayoutSet{
    UIImage *image = [UIImage imageNamed:@"返回1"];
    [self addLeftBarButtonWithImage:image action:@selector(backAction)];
    
    _numberLabel1 = [UILabel labelWithFont:[UIFont systemFontOfSize:10] textColor:[UIColor blackColor] text:LocalString(@"4 numbers")];
    _numberLabel2 = [UILabel labelWithFont:[UIFont systemFontOfSize:10] textColor:[UIColor blackColor] text:LocalString(@"4 numbers")];
    _numberLabel3 = [UILabel labelWithFont:[UIFont systemFontOfSize:10] textColor:[UIColor blackColor] text:LocalString(@"4 numbers")];
    [_numberLabel1 setFont:[UIFont systemFontOfSize:10.0]];
    [_numberLabel2 setFont:[UIFont systemFontOfSize:10.0]];
    [_numberLabel3 setFont:[UIFont systemFontOfSize:10.0]];
    
    _inputOldPinCodeTextField = [UITextField textFieldWithPlaceholderText:LocalString(@"Input old PIN code")];
    _inputNewPinCodeTextField = [UITextField textFieldWithPlaceholderText:LocalString(@"Input new PIN code")];
    _repeatNewPinCodeTextField = [UITextField textFieldWithPlaceholderText:LocalString(@"Repeat new PIN code")];
    _inputNewPinCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _inputOldPinCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _repeatNewPinCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_inputOldPinCodeTextField setTextFieldStyle1];
    [_inputNewPinCodeTextField setTextFieldStyle1];
    [_repeatNewPinCodeTextField setTextFieldStyle1];
    
    _okButton = [UIButton buttonWithTitle:LocalString(@"OK") titleColor:[UIColor blackColor]];
    [_okButton setButtonStyle1];
    
    [self.view addSubview:_numberLabel1];
    [self.view addSubview:_numberLabel2];
    [self.view addSubview:_numberLabel3];
    [self.view addSubview:_inputOldPinCodeTextField];
    [self.view addSubview:_inputNewPinCodeTextField];
    [self.view addSubview:_repeatNewPinCodeTextField];
    [self.view addSubview:_okButton];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [_inputOldPinCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.1 + 44 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [_inputOldPinCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.02 + 44 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    
    [_numberLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.4, ScreenHeight * 0.022));
        make.top.equalTo(self.inputOldPinCodeTextField.mas_bottom).offset(ScreenHeight * 0.01);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_inputNewPinCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.numberLabel1.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_numberLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.4, ScreenHeight * 0.022));
        make.top.equalTo(self.inputNewPinCodeTextField.mas_bottom).offset(ScreenHeight * 0.01);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_repeatNewPinCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.top.equalTo(self.numberLabel2.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_numberLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.4, ScreenHeight * 0.022));
        make.top.equalTo(self.repeatNewPinCodeTextField.mas_bottom).offset(ScreenHeight * 0.01);
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
    [self.inputOldPinCodeTextField resignFirstResponder];
    [self.inputNewPinCodeTextField resignFirstResponder];
    [self.repeatNewPinCodeTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField*) textField
{
    [textField resignFirstResponder];
    return YES;
}

//-(void)keyboardWillShow:(NSNotification *)notification{
//    //键盘最后的frame
//    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGFloat height = keyboardFrame.size.height;
//    //需要移动的距离
//    CGFloat rects = (ScreenHeight - _okButton.frame.origin.y - _okButton.frame.size.height) - height;
//
//    if (rects <= 0) {
//        [UIView animateWithDuration:0.3 animations:^{
//            CGRect frame = self.view.frame;
//            if (_backupY == 0) {
//                _backupY = self.view.frame.origin.y;
//            }
//            frame.origin.y = rects;
//            self.view.frame = frame;
//        }];
//    }
//}
//-(void)keyboardWillHide:(NSNotification *)notification{
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect frame = self.view.frame;
//        frame.origin.y = _backupY;
//        self.view.frame = frame;
//    }];
//}

#pragma mark - bluetooth manager

- (void)setPinCode
{
    if (self.inputOldPinCodeTextField.text.length != 4 || self.inputNewPinCodeTextField.text.length != 4 || self.repeatNewPinCodeTextField.text.length != 4) {
        [NSObject showHudTipStr:LocalString(@"PinCode restrictions 4 digits")];
    }else if ([self.inputOldPinCodeTextField.text intValue] != [BluetoothDataManage shareInstance].pincode){
        [NSObject showHudTipStr:LocalString(@"OldPinCode ERROR")];
    }else if (![self.inputNewPinCodeTextField.text isEqualToString:self.repeatNewPinCodeTextField.text])
    {
        [NSObject showHudTipStr:LocalString(@"Two input is inconsistent")];
    }else{
        NSMutableArray *dataContent = [[NSMutableArray alloc] init];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:[self.inputOldPinCodeTextField.text characterAtIndex:0] - 48]];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:[self.inputOldPinCodeTextField.text characterAtIndex:1] - 48]];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:[self.inputOldPinCodeTextField.text characterAtIndex:2] - 48]];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:[self.inputOldPinCodeTextField.text characterAtIndex:3] - 48]];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:[self.inputNewPinCodeTextField.text characterAtIndex:0] - 48]];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:[self.inputNewPinCodeTextField.text characterAtIndex:1] - 48]];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:[self.inputNewPinCodeTextField.text characterAtIndex:2] - 48]];
        [dataContent addObject:[NSNumber numberWithUnsignedInteger:[self.inputNewPinCodeTextField.text characterAtIndex:3] - 48]];
        
        [self.bluetoothDataManage setDataType:0x06];
        [self.bluetoothDataManage setDataContent: dataContent];
        [self.bluetoothDataManage sendBluetoothFrame];
    }
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
