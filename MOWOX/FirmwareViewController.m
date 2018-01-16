//
//  FirmwareViewController.m
//  MOWOX
//
//  Created by Mac on 2017/12/27.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "FirmwareViewController.h"
#import "ProgressView.h"
#import "ASProgressPopUpView.h"

#define dataName @"AutoMower"

@interface FirmwareViewController () <ASProgressPopUpViewDelegate,ASProgressPopUpViewDataSource>
///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;

@property (strong, nonatomic)  UIButton *okButton;
@property (strong, nonatomic)  UIButton *checkButton;
@property (strong, nonatomic)  ProgressView *progressView;
@property (strong, nonatomic)  UILabel *tipLabel;
@property (strong, nonatomic)  UILabel *latestVerLabel;
@property (strong, nonatomic)  UITextView *curVerTV;

@property (strong, nonatomic)  UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic)  ASProgressPopUpView *progressViewNew;
@property (nonatomic) int packgeNum;
@end

@implementation FirmwareViewController

static int version = 1.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    UIImage *backImage = [UIImage imageNamed:@"backgroundnew"];
    self.view.layer.contents = (id)backImage.CGImage;
    
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
    self.navigationItem.title = LocalString(@"Update Mower's Firmware");
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    
    //获取总包数来判断什么时候结束
    NSString *path = [[NSBundle mainBundle] pathForResource:dataName ofType:@"bin"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    long size = [data length];
    int packageNum = (int)size / 2048;
    _packgeNum = packageNum;
    if (![BluetoothDataManage shareInstance].updateFirmware_packageNum) {
        [BluetoothDataManage shareInstance].updateFirmware_packageNum = packageNum;
    }
    
    
    [self viewLayoutSet];
    
    //设置进度条总数
    //_progressView.packageNum = packageNum;
    //设置从第1包开始
    [BluetoothDataManage shareInstance].progress_num = 0;
    [self.progressViewNew showPopUpViewAnimated:YES];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [BluetoothDataManage shareInstance].updateFirmware_j = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFirmware:) name:@"shaogujian" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSuccese) name:@"updateSuccese" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFirmware) name:@"recieveUpdateFirmware" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"shaogujian" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateSuccese" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveUpdateFirmware" object:nil];
    [BluetoothDataManage shareInstance].updateFirmware_j = 0;
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
    _progressView = [[ProgressView alloc] init];
    _progressView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_progressView];
    //_progressView.hidden = YES;
    
    _progressViewNew = [[ASProgressPopUpView alloc] init];
    _progressViewNew.backgroundColor = [UIColor lightGrayColor];
    _progressViewNew.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
    _progressViewNew.popUpViewAnimatedColors = @[[UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
    _progressViewNew.delegate = self;
    _progressViewNew.dataSource = self;
    [self.view addSubview:_progressViewNew];
    
    _tipLabel = [[UILabel alloc] init];
    //_tipLabel.hidden = YES;
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.textColor = [UIColor redColor];
    _tipLabel.text = LocalString(@"####Waiting for signal####");
    [self.view addSubview:_tipLabel];
    
    _latestVerLabel = [[UILabel alloc] init];
    _latestVerLabel.backgroundColor = [UIColor clearColor];
    _latestVerLabel.textAlignment = NSTextAlignmentCenter;
    _latestVerLabel.text = LocalString(@"Latest Mower's Firmware version: V1.1");
    [self.view addSubview:_latestVerLabel];
    
    _curVerTV = [[UITextView alloc] init];
    _curVerTV.text = LocalString(@"your mower's firmware version: V1.0.\nyou can update it.");
    _curVerTV.font = [UIFont fontWithName:@"Arial" size:13];
    _curVerTV.backgroundColor = [UIColor clearColor];
    _curVerTV.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    _curVerTV.textAlignment = NSTextAlignmentCenter;
    _curVerTV.hidden = YES;
    [self.view addSubview:_curVerTV];
    
    _okButton = [UIButton buttonWithTitle:LocalString(@"Update") titleColor:[UIColor blackColor]];
    [_okButton setButtonStyle1];
    [_okButton addTarget:self action:@selector(showUpdateView) forControlEvents:UIControlEventTouchUpInside];
    _okButton.hidden = YES;
    [self.view addSubview:_okButton];
    
    _checkButton = [UIButton buttonWithTitle:LocalString(@"Check your mower's firmware version") titleColor:[UIColor blackColor]];
    [_checkButton setButtonStyle1];
    [_checkButton addTarget:self action:@selector(checkCurrentVersion) forControlEvents:UIControlEventAllTouchEvents];
    [self.view addSubview:_checkButton];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _activityIndicatorView.backgroundColor = [UIColor grayColor];
    _activityIndicatorView.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicatorView];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        /*[_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, ScreenWidth));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top);
        }];*/
        [_latestVerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, ScreenHeight * 0.066));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.05);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [_latestVerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, ScreenHeight * 0.066));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.01);
        }];
    }
    [_checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.latestVerLabel.mas_bottom).offset(ScreenHeight * 0.05);
    }];
    [_curVerTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.15));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.checkButton.mas_bottom).offset(ScreenHeight * 0.05);
    }];
    /*[_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.progressView.mas_bottom);
    }];*/
    [_okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.066));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.curVerTV.mas_bottom).offset(ScreenHeight * 0.1);
    }];
    [_progressViewNew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, 5.0));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.okButton.mas_bottom).offset(ScreenHeight * 0.1);
    }];
    [_activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
}

#pragma mark - progress view
- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress
{
    NSString *s;
    if (progress < 0.2) {
        s = @"Just starting";
    } else if (progress > 0.4 && progress < 0.6) {
        s = @"About halfway";
    } else if (progress > 0.75 && progress < 1.0) {
        s = @"Nearly there";
    } else if (progress >= 1.0) {
        s = @"Complete";
    }
    return s;
}

- (NSArray *)allStringsForProgressView:(ASProgressPopUpView *)progressView;
{
    return @[@"Just starting", @"About halfway", @"Nearly there", @"Complete"];
}

#pragma mark - bluetooth control
- (void)checkCurrentVersion{
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x19];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
    [_activityIndicatorView startAnimating];
    _checkButton.enabled = NO;
    [self.progressViewNew showPopUpViewAnimated:YES];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        usleep(2000 * 1000);
        if (weakSelf.activityIndicatorView.isAnimating == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.activityIndicatorView stopAnimating];
                weakSelf.checkButton.enabled = YES;
                [NSObject showHudTipStr:LocalString(@"check firmware timeout")];
            });
        }
    });
}

- (void)receiveFirmwareVersion{
    
    [_activityIndicatorView stopAnimating];
    _curVerTV.hidden = NO;
    _okButton.hidden = NO;
}
/*- (void)MowerSetting{
 dispatch_async(dispatch_get_global_queue(0, 0), ^{
 
 NSString *path = [[NSBundle mainBundle] pathForResource:@"AutoMower1" ofType:@"bin"];
 
 AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
 
 NSData *data = [NSData dataWithContentsOfFile:path];
 
 long size = [data length];
 int packageNum = (int)size / 2048 + 1;
 UInt8 sendBuffer[5];
 sendBuffer[0] = [[NSNumber numberWithUnsignedInteger:0x23] unsignedCharValue];
 sendBuffer[1] = [[NSNumber numberWithUnsignedInteger:packageNum] unsignedCharValue];
 sendBuffer[2] = [[NSNumber numberWithUnsignedInteger:0x23] unsignedCharValue];
 sendBuffer[3] = [[NSNumber numberWithUnsignedInteger:0x00] unsignedCharValue];
 sendBuffer[4] = [[NSNumber numberWithUnsignedInteger:0x08] unsignedCharValue];
 
 
 
 
 for (int j = 0; j < [data length]; j += 2048) {
 if ((j + 2048) < [data length]) {
 NSString *rangePac = [NSString stringWithFormat:@"%i,%i", j, 2048];
 NSData *subPac = [data subdataWithRange:NSRangeFromString(rangePac)];
 packageNum--;
 sendBuffer[1] = [[NSNumber numberWithUnsignedInteger:packageNum] unsignedCharValue];
 
 NSData *sendPacHead = [NSData dataWithBytes:sendBuffer length:5];
 NSLog(@"发送一条蓝牙帧： %@",sendPacHead);
 if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
 {
 [appDelegate.currentPeripheral writeValue:sendPacHead forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
 }
 usleep(50 * 1000);
 
 for (int i = 0; i < [subPac length]; i += 20) {
 
 // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
 if ((i + 20) < [subPac length]) {
 NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, 20];
 NSData *subData = [subPac subdataWithRange:NSRangeFromString(rangeStr)];
 NSLog(@"发送一条蓝牙帧： %@",subData);
 if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
 {
 [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
 }
 //根据接收模块的处理能力做相应延时
 usleep(50 * 1000);
 }
 else {
 NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([subPac length] - i)];
 NSData *subData = [subPac subdataWithRange:NSRangeFromString(rangeStr)];
 NSLog(@"发送一条蓝牙帧： %@",subData);
 if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
 {
 [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
 }
 usleep(50 * 1000);
 }
 }
 
 uint8_t crc8 = [self crc8:subPac];
 NSLog(@"%d",crc8);
 UInt8 sendCRCbuff[1];
 sendCRCbuff[0] = [[NSNumber numberWithUnsignedInteger:crc8] unsignedCharValue];
 NSData *sendCRC8 = [NSData dataWithBytes:sendCRCbuff length:1];
 NSLog(@"发送一条蓝牙帧： %@",sendCRC8);
 if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
 {
 [appDelegate.currentPeripheral writeValue:sendCRC8 forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
 }
 usleep(5000 * 1000);
 }else {
 NSString *rangePac = [NSString stringWithFormat:@"%i,%i", j, (int)([data length] - j)];
 NSData *subPac = [data subdataWithRange:NSRangeFromString(rangePac)];
 packageNum--;
 sendBuffer[1] = [[NSNumber numberWithUnsignedInteger:packageNum] unsignedCharValue];
 
 sendBuffer[3] = [[NSNumber numberWithUnsignedInteger:(int)([data length] - j) % 256] unsignedCharValue];
 sendBuffer[4] = [[NSNumber numberWithUnsignedInteger:(int)([data length] - j) / 256] unsignedCharValue];
 NSData *sendPacHead = [NSData dataWithBytes:sendBuffer length:5];
 NSLog(@"发送一条蓝牙帧： %@",sendPacHead);
 if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
 {
 [appDelegate.currentPeripheral writeValue:sendPacHead forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
 }
 usleep(50 * 1000);
 
 for (int i = 0; i < [subPac length]; i += 20) {
 
 // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
 if ((i + 20) < [subPac length]) {
 NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, 20];
 NSData *subData = [subPac subdataWithRange:NSRangeFromString(rangeStr)];
 NSLog(@"发送一条蓝牙帧： %@",subData);
 if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
 {
 [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
 }
 //根据接收模块的处理能力做相应延时
 usleep(50 * 1000);
 }
 else {
 NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([subPac length] - i)];
 NSData *subData = [subPac subdataWithRange:NSRangeFromString(rangeStr)];
 NSLog(@"发送一条蓝牙帧： %@",subData);
 if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
 {
 [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
 }
 usleep(50 * 1000);
 }
 }
 
 uint8_t crc8 = [self crc8:subPac];
 NSLog(@"%d",crc8);
 UInt8 sendCRCbuff[1];
 sendCRCbuff[0] = [[NSNumber numberWithUnsignedInteger:crc8] unsignedCharValue];
 NSData *sendCRC8 = [NSData dataWithBytes:sendCRCbuff length:1];
 NSLog(@"发送一条蓝牙帧： %@",sendCRC8);
 if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
 {
 [appDelegate.currentPeripheral writeValue:sendCRC8 forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
 }
 
 }
 
 }
 });
 
 }*/
- (void)updateFirmware{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shaogujian" object:nil userInfo:nil];
    _tipLabel.hidden = NO;
    _tipLabel.textColor = [UIColor redColor];
    _tipLabel.text = LocalString(@"####Updating,No Hurry####");
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)updateFirmware:(NSNotification *)notification{
    
    /*if (self.progressView.hidden == YES) {
        self.progressView.hidden = NO;
    }*/
    NSDictionary *dict = [notification userInfo];
    NSString *result = dict[@"result"];
    if ([result isEqualToString:@"success"]) {
        [NSObject showHudTipStr:[NSString stringWithFormat:@"%d success",[BluetoothDataManage shareInstance].progress_num]];
    }else if ([result isEqualToString:@"error"]){
        [NSObject showHudTipStr:[NSString stringWithFormat:@"%d error,again",[BluetoothDataManage shareInstance].progress_num]];
    }
    _progressViewNew.progress = [BluetoothDataManage shareInstance].progress_num / (float)_packgeNum;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *path = [[NSBundle mainBundle] pathForResource:dataName ofType:@"bin"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        
        UInt8 sendBuffer[5];
        sendBuffer[0] = [[NSNumber numberWithUnsignedInteger:0x23] unsignedCharValue];
        sendBuffer[1] = [[NSNumber numberWithUnsignedInteger:[BluetoothDataManage shareInstance].updateFirmware_packageNum] unsignedCharValue];
        sendBuffer[2] = [[NSNumber numberWithUnsignedInteger:0x23] unsignedCharValue];
        sendBuffer[3] = [[NSNumber numberWithUnsignedInteger:0x00] unsignedCharValue];
        sendBuffer[4] = [[NSNumber numberWithUnsignedInteger:0x08] unsignedCharValue];
        
        int j = [BluetoothDataManage shareInstance].updateFirmware_j;
        
        if ((j + 2048) < [data length]) {
            NSString *rangePac = [NSString stringWithFormat:@"%i,%i", j, 2048];
            NSData *subPac = [data subdataWithRange:NSRangeFromString(rangePac)];
            sendBuffer[1] = [[NSNumber numberWithUnsignedInteger:[BluetoothDataManage shareInstance].updateFirmware_packageNum] unsignedCharValue];
            
            NSData *sendPacHead = [NSData dataWithBytes:sendBuffer length:5];
            NSLog(@"发送一条蓝牙帧： %@",sendPacHead);
            if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
            {
                [appDelegate.currentPeripheral writeValue:sendPacHead forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
            }
            usleep(10 * 1000);
            
            for (int i = 0; i < [subPac length]; i += 20) {
                
                // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
                if ((i + 20) < [subPac length]) {
                    NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, 20];
                    NSData *subData = [subPac subdataWithRange:NSRangeFromString(rangeStr)];
                    NSLog(@"发送一条蓝牙帧： %@",subData);
                    if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
                    {
                        [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
                    }
                    //根据接收模块的处理能力做相应延时
                    usleep(10 * 1000);
                }
                else {
                    NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([subPac length] - i)];
                    NSData *subData = [subPac subdataWithRange:NSRangeFromString(rangeStr)];
                    NSLog(@"发送一条蓝牙帧： %@",subData);
                    if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
                    {
                        [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
                    }
                    usleep(10 * 1000);
                }
            }
            
            uint8_t crc8 = [self crc8:subPac];
            NSLog(@"%d",crc8);
            UInt8 sendCRCbuff[1];
            sendCRCbuff[0] = [[NSNumber numberWithUnsignedInteger:crc8] unsignedCharValue];
            NSData *sendCRC8 = [NSData dataWithBytes:sendCRCbuff length:1];
            NSLog(@"发送一条蓝牙帧： %@",sendCRC8);
            if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
            {
                [appDelegate.currentPeripheral writeValue:sendCRC8 forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
            }
            
        }else if(j != [data length]){
            //不接收
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"shaogujian" object:nil];
            
            NSString *rangePac = [NSString stringWithFormat:@"%i,%i", j, (int)([data length] - j)];
            NSData *subPac = [data subdataWithRange:NSRangeFromString(rangePac)];
            sendBuffer[1] = [[NSNumber numberWithUnsignedInteger:0] unsignedCharValue];
            
            sendBuffer[3] = [[NSNumber numberWithUnsignedInteger:(int)([data length] - j) % 256] unsignedCharValue];
            sendBuffer[4] = [[NSNumber numberWithUnsignedInteger:(int)([data length] - j) / 256] unsignedCharValue];
            NSData *sendPacHead = [NSData dataWithBytes:sendBuffer length:5];
            NSLog(@"发送一条蓝牙帧： %@",sendPacHead);
            if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
            {
                [appDelegate.currentPeripheral writeValue:sendPacHead forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
            }
            usleep(10 * 1000);
            
            for (int i = 0; i < [subPac length]; i += 20) {
                
                // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
                if ((i + 20) < [subPac length]) {
                    NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, 20];
                    NSData *subData = [subPac subdataWithRange:NSRangeFromString(rangeStr)];
                    NSLog(@"发送一条蓝牙帧： %@",subData);
                    if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
                    {
                        [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
                    }
                    //根据接收模块的处理能力做相应延时
                    usleep(10 * 1000);
                }
                else {
                    NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([subPac length] - i)];
                    NSData *subData = [subPac subdataWithRange:NSRangeFromString(rangeStr)];
                    NSLog(@"发送一条蓝牙帧： %@",subData);
                    if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
                    {
                        [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
                    }
                    usleep(10 * 1000);
                }
            }
            
            uint8_t crc8 = [self crc8:subPac];
            NSLog(@"%d",crc8);
            UInt8 sendCRCbuff[1];
            sendCRCbuff[0] = [[NSNumber numberWithUnsignedInteger:crc8] unsignedCharValue];
            NSData *sendCRC8 = [NSData dataWithBytes:sendCRCbuff length:1];
            NSLog(@"发送一条蓝牙帧： %@",sendCRC8);
            if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
            {
                [appDelegate.currentPeripheral writeValue:sendCRC8 forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
            }
            
        }
        
        
    });
    
}

- (uint8_t)crc8:(NSData *)data
{
    uint8_t crc=0;
    crc = 0;
    
    uint8_t byteArray[[data length]];
    [data getBytes:&byteArray];
    
    for (int i = 0; i < [data length]; i++) {
        Byte byte = byteArray[i];
        crc ^= byte;
        for(int j = 0;j < 8;j++)
        {
            if(crc & 0x01)
            {
                crc = (crc >> 1) ^ 0x8C;
            }else crc >>= 1;
        }
    }
    return crc;
}

- (void)updateSuccese{
    self.progressView.hidden = NO;
    _tipLabel.text = LocalString(@"####Update Success####");
    _tipLabel.textColor = [UIColor greenColor];
    [NSObject showHudTipStr:@"update succese"];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    _progressViewNew.progress = 1.0;
    [BluetoothDataManage shareInstance].progress_num = 0;
}

@end
