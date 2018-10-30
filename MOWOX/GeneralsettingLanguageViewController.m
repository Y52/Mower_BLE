//
//  GeneralsettingLanguageViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/6.
//  Copyright © 2017年 yusz. All rights reserved.
//


#import "GeneralsettingLanguageViewController.h"
#import "BluetoothDataManage.h"
#import "AppDelegate.h"

@interface GeneralsettingLanguageViewController () <UIPickerViewDataSource,UIPickerViewDelegate>

///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;

@property (strong, nonatomic) UIPickerView *languagePicker;
@property (strong, nonatomic) UIButton *OKButton;

@property (nonatomic, strong) NSMutableArray  *languageArray;


@end

@implementation GeneralsettingLanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    self.navigationItem.title = LocalString(@"Language setting");
    
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    
    [self viewLayoutSet];
    [self inquireLanguage];
    
    [self.OKButton addTarget:self action:@selector(setLanguage) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveMowerLanguage:) name:@"recieveMowerLanguage" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveMowerLanguage" object:nil];
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
    
    _languagePicker = [[UIPickerView alloc] init];
    /*self.languageArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"English", nil),
                                                          NSLocalizedString(@"Polski", nil),NSLocalizedString(@"Dansk", nil),NSLocalizedString(@"Finnish", nil),NSLocalizedString(@"Czech", nil),NSLocalizedString(@"Hungarian", nil),NSLocalizedString(@"Slovenian", nil),NSLocalizedString(@"Polish", nil),NSLocalizedString(@"Russian", nil),NSLocalizedString(@"France", nil),NSLocalizedString(@"Japanese", nil)]];*/
    self.languageArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"English", nil),
                                                          NSLocalizedString(@"Dansk", nil),NSLocalizedString(@"Derman", nil),NSLocalizedString(@"Czech", nil),NSLocalizedString(@"Slovak", nil),NSLocalizedString(@"Polish", nil),NSLocalizedString(@"Hungarian", nil),NSLocalizedString(@"Russian", nil),NSLocalizedString(@"French", nil),]];
    self.languagePicker.dataSource = self;
    self.languagePicker.delegate = self;
    [self.languagePicker selectRow:0 inComponent:0 animated:YES];
    
    _OKButton = [UIButton buttonWithTitle:LocalString(@"OK") titleColor:[UIColor blackColor]];
    [_OKButton setButtonStyle1];
    [self.view addSubview:_OKButton];
    [self.view addSubview:_languagePicker];

    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [self.languagePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(ScreenHeight * 0.6);
            make.width.mas_equalTo(ScreenWidth);
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.05 + 44 + 64);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [self.languagePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(ScreenHeight * 0.6);
            make.width.mas_equalTo(ScreenWidth);
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.01 + 44 + 64);
        }];
    }

    
    [_OKButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.6, ScreenHeight * 0.066));
        make.top.equalTo(self.languagePicker.mas_bottom);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

#pragma mark - inquire Mower Language

- (void)inquireLanguage{
    
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x13];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}

- (void)recieveMowerLanguage:(NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    NSNumber *Language = dict[@"Language"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.languagePicker selectRow:[Language intValue] inComponent:0 animated:YES];
    });}

#pragma mark - buttonAction
- (void)setLanguage
{
    NSInteger row = [self.languagePicker selectedRowInComponent:0];
    if (row == 1) {
        row = 2;
    }
    
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:row]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x03];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
    
    
    /*NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString *language = langArr.firstObject;
    NSLog(@"模拟器语言切换之前：%@",language);
    
    // 切换语言
    NSArray *lanArrNwe = @[@"zh-Hans"];
    NSInteger row = [self.languagePicker selectedRowInComponent:0];
    switch (row) {
        case 0:
            lanArrNwe = @[@"en"];
            break;
            
        case 12:
            lanArrNwe = @[@"zh-Hans"];
            break;
            
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] setValue:lanArrNwe forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];*/
    
    
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component __TVOS_PROHIBITED {
    
    return 40;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return self.languageArray.count;
    
}

#pragma mark - UIPickerViewDelegate 
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return self.languageArray[row];
    
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
