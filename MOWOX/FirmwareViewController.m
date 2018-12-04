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

@interface FirmwareViewController ()
///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;

@property (strong, nonatomic)  UIButton *okButton;
@property (strong, nonatomic)  ProgressView *progressView;
@property (strong, nonatomic)  UITextView *curVerTV;
@property (strong, nonatomic)  UILabel *tipLabel;

@property (strong, nonatomic)  UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic)  ASProgressPopUpView *progressViewNew;
@property (nonatomic) int packgeNum;
@end

@implementation FirmwareViewController
{
    NSString *dataName;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([BluetoothDataManage shareInstance].deviceType == 0) {
        dataName = @"DYM2206_42Motor_Vx.x.x_20xxXxXx.bin";
    }else if ([BluetoothDataManage shareInstance].deviceType == 1){
        dataName = @"DYM2206_35Motor_Vx.x.x_20xxXxXx.bin";
    }else if ([BluetoothDataManage shareInstance].deviceType == 2){
        dataName = @"DYM2205_35Motor_Vx.x.x_20xxXxXx.bin";
    }else{
        dataName = @"AutoMower";
    }
    
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
    self.navigationItem.title = LocalString(@"Update Robot's Firmware");
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    
    //获取bin文件的总包数并记录
    NSString *path = [[NSBundle mainBundle] pathForResource:dataName ofType:@"bin"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    long size = [data length];
    int packageNum = (int)size / 2048;
    _packgeNum = packageNum;
    if (![BluetoothDataManage shareInstance].updateFirmware_packageNum) {
        [BluetoothDataManage shareInstance].updateFirmware_packageNum = packageNum;
    }

    //ui设置
    [self viewLayoutSet];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFirmwareWeak) name:@"recieveUpdateFirmware" object:nil];
    
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
    UIImage *image = [UIImage imageNamed:@"返回1"];
    [self addLeftBarButtonWithImage:image action:@selector(backAction)];
    
    /**
     **进度条设置
     **/
    _progressViewNew = [[ASProgressPopUpView alloc] init];
    _progressViewNew.backgroundColor = [UIColor lightGrayColor];
    _progressViewNew.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
    _progressViewNew.popUpViewAnimatedColors = @[[UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
    _progressViewNew.delegate = self;
    _progressViewNew.dataSource = self;
    [self.view addSubview:_progressViewNew];
    
    //curVerTextView
    _curVerTV = [[UITextView alloc] init];
    _curVerTV.text = [NSString stringWithFormat:@"%@\n V%d.%d.%d\n%@\n V1.2.7\n",LocalString(@"Your robot's firmware version:"),[BluetoothDataManage shareInstance].version1,[BluetoothDataManage shareInstance].version2,[BluetoothDataManage shareInstance].version3,LocalString(@"Latest robot's firmware version:")];
    _curVerTV.font = [UIFont fontWithName:@"Arial" size:17];
    _curVerTV.backgroundColor = [UIColor clearColor];
    _curVerTV.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    _curVerTV.textAlignment = NSTextAlignmentCenter;
    [_curVerTV setEditable:NO];
    _curVerTV.scrollEnabled = NO;
    [self.view addSubview:_curVerTV];
    
    _tipLabel = [[UILabel alloc] init];
    _tipLabel.font = [UIFont systemFontOfSize:17.0];
    _tipLabel.text = LocalString(@"Please press Key \"2\"(Boot Mode,2-Update firmware) on the robot's keyboard to start.");
    _tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _tipLabel.numberOfLines = 0;
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_tipLabel];
    
    _okButton = [UIButton buttonWithTitle:LocalString(@"Update") titleColor:[UIColor blackColor]];
    [_okButton setButtonStyle1];
    [_okButton addTarget:self action:@selector(showUpdateView) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:_okButton];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _activityIndicatorView.backgroundColor = [UIColor grayColor];
    _activityIndicatorView.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicatorView];
    
    UIImageView *tipImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"updateFirmwareTip"]];
    [self.view addSubview:tipImage];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [_curVerTV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.18));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.05 + 64);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [_curVerTV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.18));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(ScreenHeight * 0.01 + 64);
        }];
    }
    [tipImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, ScreenHeight * 0.3));
        make.top.equalTo(self.curVerTV.mas_bottom);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, ScreenHeight * 0.15));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(tipImage.mas_bottom);
    }];
    [_progressViewNew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.82, 5.0));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.tipLabel.mas_bottom).offset(ScreenHeight * 0.1);
    }];
    [_activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
}

#pragma mark - progress view
/**
 **进度条的文字设置函数
 **/
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
/**
 **接收到割草机启动信号，唤醒发送固件数据主函数并使屏幕常亮
 **/
- (void)updateFirmwareWeak{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shaogujian" object:nil userInfo:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

/**
 **发送固件数据的主函数
 **/
- (void)updateFirmware:(NSNotification *)notification{
    
    NSDictionary *dict = [notification userInfo];
    NSString *result = dict[@"result"];
    if ([result isEqualToString:@"success"]) {
        [NSObject showHudTipStr:[NSString stringWithFormat:@"%d %@",[BluetoothDataManage shareInstance].progress_num,LocalString(@"success")]];
    }else if ([result isEqualToString:@"error"]){
        [NSObject showHudTipStr:[NSString stringWithFormat:@"%d %@",[BluetoothDataManage shareInstance].progress_num,LocalString(@"error,again")]];
    }
    _progressViewNew.progress = [BluetoothDataManage shareInstance].progress_num / (float)_packgeNum;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
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

/**
 **crc8检验
 **/
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

/**
 **更新固件成功
 **/
- (void)updateSuccese{
    //self.progressView.hidden = NO;
    //_tipLabel.text = LocalString(@"####Update Success####");
    //_tipLabel.textColor = [UIColor greenColor];
    [NSObject showHudTipStr:LocalString(@"update succese")];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    _progressViewNew.progress = 1.0;
    [BluetoothDataManage shareInstance].progress_num = 0;
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
