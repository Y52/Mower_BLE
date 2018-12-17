//
//  AddlandroidViewController.m
//  MOWOX
//
//  Created by 安建伟 on 2018/12/17.
//  Copyright © 2018 yusz. All rights reserved.
//

#import "AddlandroidViewController.h"

@interface AddlandroidViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *landroidNameTF;
@property (nonatomic, strong) UITextField *landroidNumberTF;
@property (nonatomic, strong) UIButton *nextBtn;

@end

@implementation AddlandroidViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavItem];
    [self landroidNameTF];
    [self landroidNumberTF];
    [self nextBtn];
    
}

- (void)setNavItem{
    self.navigationItem.title = LocalString(@"Addlandroid");
}

- (UITextField *)landroidNameTF{
    if (!_landroidNameTF) {
        _landroidNameTF = [[UITextField alloc] init];
        _landroidNameTF.backgroundColor = [UIColor clearColor];
        _landroidNameTF.font = [UIFont systemFontOfSize:16.f];
        _landroidNameTF.textColor = [UIColor whiteColor];
        _landroidNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _landroidNameTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _landroidNameTF.delegate = self;
        _landroidNameTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _landroidNameTF.borderStyle = UITextBorderStyleRoundedRect;
        [_landroidNameTF addTarget:self action:@selector(textFieldTextChange) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_landroidNameTF];
        [_landroidNameTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(280/WScale, 40/HScale));
            make.top.equalTo(self.view.mas_top).offset(100/HScale);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
        _landroidNameTF.layer.borderWidth = 1.0;
        _landroidNameTF.layer.borderColor = [UIColor whiteColor].CGColor;
        _landroidNameTF.layer.cornerRadius = 10.f/HScale;
        //_landroidNameTF.placeholder = LocalString(@"Serial number");
        [_landroidNameTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        [_landroidNameTF setValue:[UIFont boldSystemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];
    }
    return _landroidNameTF;
}

- (UITextField *)landroidNumberTF{
    if (!_landroidNumberTF) {
        _landroidNumberTF = [[UITextField alloc] init];
        _landroidNumberTF.backgroundColor = [UIColor clearColor];
        _landroidNumberTF.font = [UIFont systemFontOfSize:15.f];
        _landroidNumberTF.textColor = [UIColor whiteColor];
        _landroidNumberTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _landroidNumberTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _landroidNumberTF.delegate = self;
        _landroidNumberTF.secureTextEntry = YES;
        _landroidNumberTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _landroidNumberTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _landroidNumberTF.borderStyle = UITextBorderStyleRoundedRect;
        
        [_landroidNumberTF addTarget:self action:@selector(textFieldTextChange) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_landroidNumberTF];
        [_landroidNumberTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(280/WScale, 40/HScale));
            make.top.equalTo(self.landroidNameTF.mas_bottom).offset(30);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
        _landroidNumberTF.layer.borderWidth = 1.0;
        _landroidNumberTF.layer.borderColor = [UIColor whiteColor].CGColor;
        _landroidNumberTF.layer.cornerRadius = 10.f/HScale;
        _landroidNumberTF.placeholder = LocalString(@"Serial number");
        [_landroidNumberTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        [_landroidNumberTF setValue:[UIFont boldSystemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];
        
    }
    return _landroidNumberTF;
}

- (UIButton *)nextBtn{
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setTitle:LocalString(@"Next") forState:UIControlStateNormal];
        [_nextBtn.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextBtn setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:0.6]];
        [_nextBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
        _nextBtn.enabled = YES;
        [self.view addSubview:_nextBtn];
        [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(280/WScale, 40/HScale));
            make.top.equalTo(self.landroidNumberTF.mas_bottom).offset(30/HScale);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
        
        _nextBtn.layer.borderWidth = 1.0;
        _nextBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _nextBtn.layer.cornerRadius = 10.f/HScale;
        
        
    }
    return _nextBtn;
}



@end
