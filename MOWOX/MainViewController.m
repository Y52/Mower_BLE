//
//  MainViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/2.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "MainViewController.h"
#import "AddlandroidViewController.h"

@interface MainViewController ()

///@brife ui和功能各模块
@property (strong, nonatomic)  UILabel *deviceLabel;
@property (strong, nonatomic)  UIButton *landroidButton;
@property (strong, nonatomic)  UIButton *addButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavItem];
    [self deviceLabel];
    [self landroidButton];
    [self addButton];
    
}

- (void)setNavItem{
    self.navigationItem.title = LocalString(@"Welcome");
}

- (UILabel *)deviceLabel{
    if (!_deviceLabel) {
        _deviceLabel = [[UILabel alloc] init];
        _deviceLabel.font = [UIFont systemFontOfSize:18.f];
        _deviceLabel.backgroundColor = [UIColor clearColor];
        _deviceLabel.textColor = [UIColor whiteColor];
        _deviceLabel.textAlignment = NSTextAlignmentLeft;
        _deviceLabel.text = LocalString(@"Please select a device or add a new one");
        [self.view addSubview:_deviceLabel];
        [_deviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(300/WScale, 20/HScale));
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(80/HScale);
        }];
    }
    return _deviceLabel;
}

- (UIButton *)landroidButton{
    if (!_landroidButton) {
        _landroidButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_landroidButton setTitle:LocalString(@"landroid S") forState:UIControlStateNormal];
        [_landroidButton.titleLabel setFont:[UIFont systemFontOfSize:24.f]];
        [_landroidButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_landroidButton setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:0.6]];
        [_landroidButton addTarget:self action:@selector(landroid) forControlEvents:UIControlEventTouchUpInside];
        _landroidButton.enabled = YES;
        [self.view addSubview:_landroidButton];
        [_landroidButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(280/WScale, 40/HScale));
            make.top.equalTo(self.deviceLabel.mas_bottom).offset(30/HScale);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
        
        _landroidButton.layer.borderWidth = 1.0;
        _landroidButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _landroidButton.layer.cornerRadius = 10.f/HScale;
        
        
    }
    return _landroidButton;
}

- (UIButton *)addButton{
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setTitle:LocalString(@"➕") forState:UIControlStateNormal];
        [_addButton.titleLabel setFont:[UIFont systemFontOfSize:24.f]];
        [_addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addButton setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:0.6]];
        [_addButton addTarget:self action:@selector(addlandroid) forControlEvents:UIControlEventTouchUpInside];
        _addButton.enabled = YES;
        [self.view addSubview:_addButton];
        [_addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(280/WScale, 40/HScale));
            make.top.equalTo(self.landroidButton.mas_bottom).offset(400/HScale);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
        
        _addButton.layer.borderWidth = 1.0;
        _addButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _addButton.layer.cornerRadius = 10.f/HScale;
        
        
    }
    return _addButton;
}

- (void)addlandroid{
    
    AddlandroidViewController *VC = [[AddlandroidViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//
//- (void)backAction{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

@end
