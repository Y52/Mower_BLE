//
//  SecondarySettingViewController.m
//  MOWOX
//
//  Created by Mac on 2018/11/29.
//  Copyright © 2018 yusz. All rights reserved.
//

#import "SecondarySettingViewController.h"

@interface SecondarySettingViewController () <UITextFieldDelegate>

@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;

@property (strong, nonatomic) UILabel *secondareaLabel;
@property (strong, nonatomic) UILabel *Per2Label;
@property (strong, nonatomic) UILabel *Dis2Label;
@property (strong, nonatomic) UILabel *area2_perLabel;
@property (strong, nonatomic) UILabel *area2_disLabel;
@property (strong, nonatomic) UITextField *area2_perTF;
@property (strong, nonatomic) UITextField *area2_disTF;

@property (strong, nonatomic) UILabel *thirdareaLabel;
@property (strong, nonatomic) UILabel *Per3Label;
@property (strong, nonatomic) UILabel *Dis3Label;
@property (strong, nonatomic) UILabel *area3_perLabel;
@property (strong, nonatomic) UILabel *area3_disLabel;
@property (strong, nonatomic) UITextField *area3_perTF;
@property (strong, nonatomic) UITextField *area3_disTF;

@property (strong, nonatomic) UIButton *okButton;



@end

@implementation SecondarySettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    
    //解决navigationitem标题右偏移
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    long previousViewControllerIndex = [viewControllerArray indexOfObject:self] - 1;
    UIViewController *previous;
    if (previousViewControllerIndex >= 0) {
        previous = [viewControllerArray objectAtIndex:previousViewControllerIndex];
        previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithTitle:@""
                                                     style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:nil];
    }
    self.navigationItem.title = LocalString(@"Secondary area setting");
    //ui设置
    [self viewLayoutSet];

     self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    _area2_perTF.delegate = self;
    _area2_disTF.delegate = self;
    _area3_perTF.delegate = self;
    _area3_disTF.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveAeraMessage:) name:@"recieveAeraMessage" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveAeraMessage" object:nil];
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
 
    UIImageView *areaImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SecondaryAreaImage"]];
    [self.view addSubview:areaImage];
    
    [areaImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, ScreenHeight * 0.3));
        make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.65);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    _secondareaLabel = [[UILabel alloc] init];
    _secondareaLabel.font = [UIFont systemFontOfSize:17.0];
    _secondareaLabel.text = LocalString(@"Second area");
    _secondareaLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _secondareaLabel.numberOfLines = 0;
    _secondareaLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_secondareaLabel];
    
    _thirdareaLabel = [[UILabel alloc] init];
    _thirdareaLabel.font = [UIFont systemFontOfSize:17.0];
    _thirdareaLabel.text = LocalString(@"Third area");
    _thirdareaLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _thirdareaLabel.numberOfLines = 0;
    _thirdareaLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_thirdareaLabel];
    //2区
    _Per2Label = [UILabel labelWithFont:[UIFont systemFontOfSize:17] textColor:[UIColor blackColor] text:LocalString(@"Area2_Per : ____ %")];
    _area2_perLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:8] textColor:[UIColor blackColor] text:LocalString(@"(The proportion of the second area in relation with the entire surface)")];
    
    _Dis2Label = [UILabel labelWithFont:[UIFont systemFontOfSize:17] textColor:[UIColor blackColor] text:LocalString(@"Area2_Dis : ____ m")];
    _area2_disLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:8] textColor:[UIColor blackColor] text:LocalString(@"(The distance (in meters) that the robot needs to reach the second area)")];
    //3区
    _Per3Label = [UILabel labelWithFont:[UIFont systemFontOfSize:17] textColor:[UIColor blackColor] text:LocalString(@"Area3_Per : ____ %")];
    _area3_perLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:8] textColor:[UIColor blackColor] text:LocalString(@"(The proportion of the second area in relation with the entire surface)")];

    _Dis3Label = [UILabel labelWithFont:[UIFont systemFontOfSize:17] textColor:[UIColor blackColor] text:LocalString(@"Area3_Dis : ____ m")];
    _area3_disLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:8] textColor:[UIColor blackColor] text:LocalString(@"(The distance (in meters) that the robot needs to reach the second area)")];
    
    [_Per2Label setFont:[UIFont systemFontOfSize:17.0]];
    [_area2_perLabel setFont:[UIFont systemFontOfSize:8.0]];
    [_Dis2Label setFont:[UIFont systemFontOfSize:17.0]];
    [_area2_disLabel setFont:[UIFont systemFontOfSize:8.0]];
    _area2_perTF = [UITextField textFieldWithPlaceholderText:LocalString(@"number")];
    _area2_perTF.keyboardType = UIKeyboardTypeNumberPad;
    _area2_disTF = [UITextField textFieldWithPlaceholderText:LocalString(@"number")];
    _area2_disTF.keyboardType = UIKeyboardTypeNumberPad;
    
    [_Per3Label setFont:[UIFont systemFontOfSize:17.0]];
    [_area3_perLabel setFont:[UIFont systemFontOfSize:8.0]];
    [_Dis3Label setFont:[UIFont systemFontOfSize:17.0]];
    [_area3_disLabel setFont:[UIFont systemFontOfSize:8.0]];
    _area3_perTF = [UITextField textFieldWithPlaceholderText:LocalString(@"number")];
    _area3_perTF.keyboardType = UIKeyboardTypeNumberPad;
    _area3_disTF = [UITextField textFieldWithPlaceholderText:LocalString(@"number")];
    _area3_disTF.keyboardType = UIKeyboardTypeNumberPad;
    
    _okButton = [UIButton buttonWithTitle:LocalString(@"OK") titleColor:[UIColor blackColor]];
    _okButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [_okButton addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_Per2Label];
    [self.view addSubview:_area2_perLabel];
    [self.view addSubview:_area2_perTF];
    [self.view addSubview:_Dis2Label];
    [self.view addSubview:_area2_disLabel];
    [self.view addSubview:_area2_disTF];
    
    [self.view addSubview:_Per3Label];
    [self.view addSubview:_area3_perLabel];
    [self.view addSubview:_area3_perTF];
    [self.view addSubview:_Dis3Label];
    [self.view addSubview:_area3_disLabel];
    [self.view addSubview:_area3_disTF];
    
    [self.view addSubview:_okButton];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [_area2_perTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.15, ScreenHeight * 0.03));
            make.left.equalTo(self.view.mas_left).offset(ScreenWidth *0.54);
            make.centerY.equalTo(self.Per2Label.mas_centerY);
        }];
        [_area2_disTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.15, ScreenHeight * 0.03));
            make.left.equalTo(self.view.mas_left).offset(ScreenWidth *0.54);
            make.centerY.equalTo(self.Dis2Label.mas_centerY);
        }];
        
        [_area3_perTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.15, ScreenHeight * 0.03));
            make.left.equalTo(self.view.mas_left).offset(ScreenWidth *0.54);
            make.centerY.equalTo(self.Per3Label.mas_centerY);
        }];
        [_area3_disTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.15, ScreenHeight * 0.03));
            make.left.equalTo(self.view.mas_left).offset(ScreenWidth *0.54);
            make.centerY.equalTo(self.Dis3Label.mas_centerY);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [_area2_perTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.15, ScreenHeight * 0.03));
            make.left.equalTo(self.view.mas_left).offset(ScreenWidth *0.54);
            make.centerY.equalTo(_Per2Label.mas_centerY);
        }];
        [_area2_disTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.15, ScreenHeight * 0.03));
            make.left.equalTo(self.view.mas_left).offset(ScreenWidth *0.54);
            make.centerY.equalTo(_Dis2Label.mas_centerY);
        }];
        
        [_area3_perTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.15, ScreenHeight * 0.03));
            make.left.equalTo(self.view.mas_left).offset(ScreenWidth *0.54);
            make.centerY.equalTo(_Per3Label.mas_centerY);
        }];
        [_area3_disTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.15, ScreenHeight * 0.03));
            make.left.equalTo(self.view.mas_left).offset(ScreenWidth *0.54);
            make.centerY.equalTo(_Dis3Label.mas_centerY);
        }];
    }
    
    [_secondareaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.8, ScreenHeight * 0.03));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.15);
    }];
    [_thirdareaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.8, ScreenHeight * 0.03));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.area2_disLabel.mas_top).offset(ScreenHeight * 0.05);
    }];
    //2区
    [_Per2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.88, ScreenHeight * 0.03));
        make.top.equalTo(self.secondareaLabel.mas_bottom).offset(5);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_area2_perLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, ScreenHeight * 0.022));
        make.top.equalTo(self.Per2Label.mas_bottom).offset(ScreenHeight * 0.01);
        make.centerX.equalTo(self.view.mas_centerX);
    }];

    [_Dis2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.88, ScreenHeight * 0.03));
        make.top.equalTo(self.area2_perLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_area2_disLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, ScreenHeight * 0.022));
        make.top.equalTo(self.Dis2Label.mas_bottom).offset(ScreenHeight * 0.01);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    //3区
    [_Per3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.88, ScreenHeight * 0.03));
        make.top.equalTo(_thirdareaLabel.mas_bottom).offset(5);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_area3_perLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, ScreenHeight * 0.022));
        make.top.equalTo(self.Per3Label.mas_bottom).offset(ScreenHeight * 0.01);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [_Dis3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.88, ScreenHeight * 0.03));
        make.top.equalTo(self.area3_perLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_area3_disLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, ScreenHeight * 0.022));
        make.top.equalTo(self.Dis3Label.mas_bottom).offset(ScreenHeight * 0.01);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.6,ScreenHeight * 0.066));
        make.bottom.equalTo(areaImage.mas_top).offset(10/ScreenHeight);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

#pragma mark - recieveAeraMessage

- (void)recieveAeraMessage:(NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    NSNumber *Apresent = dict[@"Apresent"];
    NSNumber *AdistanceHungred = dict[@"AdistanceHungred"];
    NSNumber *AdistanceTen = dict[@"AdistanceTen"];
    NSNumber *AdistanceOne = dict[@"AdistanceOne"];
    NSNumber *Bpresent = dict[@"Bpresent"];
    NSNumber *BdistanceHungred = dict[@"BdistanceHungred"];
    NSNumber *BdistanceTen = dict[@"BdistanceTen"];
    NSNumber *BdistanceOne = dict[@"BdistanceOne"];
    dispatch_async(dispatch_get_main_queue(), ^{
        int Adistance,Apre,Bdistance,Bpre;
        Adistance = [AdistanceHungred intValue] * 100 + [AdistanceTen intValue] * 10 + [AdistanceOne intValue];
        Apre = [Apresent intValue];
        Bdistance = [BdistanceHungred intValue] * 100 + [BdistanceTen intValue] * 10 + [BdistanceOne intValue];
        Bpre = [Bpresent intValue];
        _area2_perTF.text = [NSString stringWithFormat:@"%d",Apre];
        _area2_disTF.text = [NSString stringWithFormat:@"%d",Adistance];
        _area3_perTF.text = [NSString stringWithFormat:@"%d",Bpre];
        _area3_disTF.text = [NSString stringWithFormat:@"%d",Bdistance];
    });
    
}
#pragma mark -UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_area2_perTF resignFirstResponder];
    [_area2_disTF resignFirstResponder];
    [_area3_perTF resignFirstResponder];
    [_area3_disTF resignFirstResponder];
    return YES;
}

#pragma mark - bluetooth control


- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)ok{
    NSLog(@"发送数据成功");
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[_area2_perTF.text integerValue]]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[_area2_disTF.text integerValue]/100]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[_area2_disTF.text integerValue]%100/10]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[_area2_disTF.text integerValue]%100%10]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[_area3_perTF.text integerValue]]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[_area3_disTF.text integerValue]/100]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[_area3_disTF.text integerValue]%100/10]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[_area3_disTF.text integerValue]%100%10]];
    
    [self.bluetoothDataManage setDataType:0x0d];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}

@end
