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

@end

@implementation InformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self viewLayoutSet];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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



@end
