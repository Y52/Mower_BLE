//
//  InformationViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/6.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "InformationViewController.h"
#import "BluetoothDataManage.h"

@interface InformationViewController ()

///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;
@property (nonatomic, strong) UILabel *label3;

@end

@implementation InformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    self.label1 = [self label1];
    self.label2 = [self label2];
    self.label3 = [self label3];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getVersion) name:@"getMowerData" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self viewLayoutSet];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getMowerData" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewLayoutSet{
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [_infoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 380));
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.01 + 44 + 64);
            make.left.equalTo(self.view.mas_left);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [_infoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 380));
            make.top.equalTo(self.view.mas_top).offset((ScreenHeight - 44 * 2 - 380) / 2);
            make.left.equalTo(self.view.mas_left);
        }];
    }
    
}

#pragma mark - Lazy load
- (UILabel *)label1{
    if (!_label1) {
        _label1 = [[UILabel alloc] init];
        _label1.font = [UIFont systemFontOfSize:17.f];
        _label1.backgroundColor = [UIColor clearColor];
        _label1.textColor = [UIColor blackColor];
        _label1.textAlignment = NSTextAlignmentLeft;
        _label1.text = LocalString(@"Robot Connect");
        [self.view addSubview:_label1];
        
        [_label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(300/WScale, 21/HScale));
            make.left.equalTo(self.view.mas_left).offset(30/HScale);
            make.top.equalTo(self.view.mas_top).offset((64 + 50)/HScale);
        }];
    }
    return _label1;
}

- (UILabel *)label2{
    if (!_label2) {
        _label2 = [[UILabel alloc] init];
        _label2.font = [UIFont systemFontOfSize:17.f];
        _label2.backgroundColor = [UIColor clearColor];
        _label2.textColor = [UIColor blackColor];
        _label2.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_label2];
        _label2.text = [NSString stringWithFormat:@"App software version: V1.2.13 for iOS"];
        
        [_label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(300/WScale, 21/HScale));
            make.left.equalTo(self.view.mas_left).offset(30/HScale);
            make.top.equalTo(self.label1.mas_bottom).offset(30/HScale);
        }];
    }
    return _label2;
}

- (UILabel *)label3{
    if (!_label3) {
        _label3 = [[UILabel alloc] init];
        _label3.font = [UIFont systemFontOfSize:17.f];
        _label3.backgroundColor = [UIColor clearColor];
        _label3.textColor = [UIColor blackColor];
        _label3.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_label3];
        _label3.text = [NSString stringWithFormat:@"Robot software version: V%d.%d.%d",_bluetoothDataManage.version1,_bluetoothDataManage.version2,_bluetoothDataManage.version3];
        
        [_label3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(300/WScale, 21/HScale));
            make.left.equalTo(self.view.mas_left).offset(30/HScale);
            make.top.equalTo(self.label2.mas_bottom).offset(30/HScale);
        }];
    }
    return _label3;
}

- (void)getVersion{
    _label3.text = [NSString stringWithFormat:@"Robot software version: V%d.%d.%d",_bluetoothDataManage.version1,_bluetoothDataManage.version2,_bluetoothDataManage.version3];
}
@end
