//
//  BluetoothDataManage.m
//  MOWOX
//
//  Created by Mac on 2017/10/31.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "BluetoothDataManage.h"
#import "AppDelegate.h"

///@brife 一条帧最大字节
#define QD_BLE_SEND_MAX_LEN 20

///@brife 可判断的数据帧类型数量
#define LEN 12

static BluetoothDataManage *sgetonInstanceData = nil;

@interface BluetoothDataManage ()

@property (strong, nonatomic)  AppDelegate *appDelegate;

@end

@implementation BluetoothDataManage

+ (instancetype)shareInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sgetonInstanceData = [[super allocWithZone:NULL] init];
    });
    return sgetonInstanceData;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [BluetoothDataManage shareInstance];
}

- (id)init
{
    self = [super init];
    if (self) {
        _bluetoothData = [[NSMutableArray alloc] init];
        _dataContent = [[NSMutableArray alloc] init];
        _receiveData = [[NSMutableArray alloc] init];
        _deviceType = 100;
        _version3 = 0;
        _version2 = 0;
        _version1 = 0;
        _pincode = 0;
    }
    return self;
}

- (void)setDataType:(UInt8)dataType{
    _dataType = [NSNumber numberWithUnsignedInteger:dataType];
}

- (void)setDataContent:(NSArray *)dataContent{
    if (_dataContent && ![dataContent containsObject:[NSNull null]]) {
        [_dataContent removeAllObjects];
        [_dataContent addObjectsFromArray:dataContent];
    }
}

#pragma mark - 帧数据组成
- (void)formData
{
    if (_dataContent && _dataType && _bluetoothData) {
        [_bluetoothData removeAllObjects];
        NSMutableArray *startByte = [[NSMutableArray alloc] init];
        NSMutableArray *timeStamp = [[NSMutableArray alloc] init];
        NSMutableArray *endByte = [[NSMutableArray alloc] init];
        
        [startByte addObject:[NSNumber numberWithUnsignedInteger:0x44]];
        [startByte addObject:[NSNumber numberWithUnsignedInteger:0x59]];
        [startByte addObject:[NSNumber numberWithUnsignedInteger:0x4d]];
        
        [timeStamp addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [timeStamp addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [timeStamp addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [timeStamp addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [timeStamp addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        [timeStamp addObject:[NSNumber numberWithUnsignedInteger:0x00]];
        
        NSNumber *otherRemark = [NSNumber numberWithUnsignedInteger:0x00];
        
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0x16]];
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0x06]];
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0x01]];
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0xFF]];
        [endByte addObject:[NSNumber numberWithUnsignedInteger:0x0a]];
        
        [_bluetoothData addObjectsFromArray:startByte];
        [_bluetoothData addObject:_dataType];
        [_bluetoothData addObjectsFromArray:_dataContent];
        [_bluetoothData addObjectsFromArray:timeStamp];
        [_bluetoothData addObject:otherRemark];
        [_bluetoothData addObjectsFromArray:endByte];
        
        
    }
}

- (void)sendBluetoothFrame
{
    [self formData];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (appDelegate.status == 0) {
        [[NetWork shareNetWork] mowerSendWithData:_bluetoothData];
    }else{
        if (_bluetoothData) {
            NSUInteger len = _bluetoothData.count;
            UInt8 sendBuffer[len];
            for (int i = 0; i < len; i++) {
                sendBuffer[i] = [[_bluetoothData objectAtIndex:i] unsignedCharValue];
            }
            NSData *sendData = [NSData dataWithBytes:sendBuffer length:len];
            NSLog(@"发送一条蓝牙帧： %@",sendData);
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            
            for (int i = 0; i < [sendData length]; i += QD_BLE_SEND_MAX_LEN) {
                
                // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
                if ((i + QD_BLE_SEND_MAX_LEN) < [sendData length]) {
                    NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, QD_BLE_SEND_MAX_LEN];
                    NSData *subData = [sendData subdataWithRange:NSRangeFromString(rangeStr)];
                    if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
                    {
                        [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
                    }
                    //根据接收模块的处理能力做相应延时
                    usleep(50 * 1000);
                }
                else {
                    NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([sendData length] - i)];
                    NSData *subData = [sendData subdataWithRange:NSRangeFromString(rangeStr)];
                    if (appDelegate.currentCharacteristic && appDelegate.currentPeripheral)
                    {
                        [appDelegate.currentPeripheral writeValue:subData forCharacteristic:appDelegate.currentCharacteristic type:CBCharacteristicWriteWithResponse];
                    }
                    usleep(50 * 1000);
                }
            }
            
        }
    }
}


#pragma mark - 处理接收数据
- (void)handleData:(NSArray *)data
{
    /**
     **用于固件更新
     **/
    if (![self frameIsRight:data]) {
        //烧固件时判断校验成功or失败
        UInt8 front1 = 0;
        UInt8 front2 = 0;
        UInt8 front3 = 0;
        UInt8 front4 = 0;
        UInt8 front5 = 0;
        UInt8 front6 = 0;
        if (data != nil && data.count >= 6) {
            front1 = [data[0] unsignedCharValue];
            front2 = [data[1] unsignedCharValue];
            front3 = [data[2] unsignedCharValue];
            front4 = [data[3] unsignedCharValue];
            front5 = [data[4] unsignedCharValue];
            front6 = [data[5] unsignedCharValue];
            if (front1 == 69 && front2 == 79 && front3 == 82 && front4 == 82 && front5 == 79 && front6 == 82){
                NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
                NSString *result = @"error";
                [dataDic setObject:result forKey:@"result"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shaogujian" object:nil userInfo:dataDic];
            }
        }else if (data.count >= 2)
        {
            front1 = [data[0] unsignedCharValue];
            front2 = [data[1] unsignedCharValue];
            if (front1 == 79 && front2 == 75 && self.updateFirmware_packageNum != 0) {
                if (!self.updateFirmware_j) {
                    self.updateFirmware_j = 0;
                }
                if (!self.progress_num) {
                    self.progress_num = 0;
                }
                self.updateFirmware_j += 2048;
                self.updateFirmware_packageNum--;
                
                NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
                NSString *result = @"success";
                [dataDic setObject:result forKey:@"result"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"progressNumber" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shaogujian" object:nil userInfo:dataDic];
                self.progress_num++;
            }
            if (front1 == 255 && front2 == 255){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSuccese" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"progressNumber" object:nil userInfo:nil];
            }
        }
        return;
    }
    
    /**
     **对割草机的所有功能响应
     **/
    if (_receiveData) {
        [_receiveData removeAllObjects];
        [_receiveData addObjectsFromArray:data];
        self.frameType = [self checkOutType:data];//判断数据类型
        if (self.frameType == otherFrame) {
            
            NSLog(@"接收到未知的数据帧");
            
        }else if (self.frameType == readBattery){
            NSLog(@"接收到readBattery");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *batterData = _receiveData[4];
            NSNumber *CPUTemperature = _receiveData[5];
            NSNumber *batterTemperature = _receiveData[6];
            NSNumber *mowerState = _receiveData[7];
            NSNumber *deviceType = _receiveData[8];
            NSNumber *version1 = _receiveData[9];
            NSNumber *version2 = _receiveData[10];
            NSNumber *version3 = _receiveData[11];
            _deviceType = [deviceType intValue];
            _version1 = [version1 intValue];
            _version2 = [version2 intValue];
            _version3 = [version3 intValue];
            [dataDic setObject:batterData forKey:@"batterData"];
            [dataDic setObject:CPUTemperature forKey:@"CPUTemperature"];
            [dataDic setObject:batterTemperature forKey:@"batterTemperature"];
            [dataDic setObject:mowerState forKey:@"mowerState"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getMowerData" object:nil userInfo:dataDic];
        }else if (self.frameType == getAlerts){
            NSLog(@"接收到getAlerts");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *year1 = _receiveData[4];
            NSNumber *year2 = _receiveData[5];
            NSNumber *month = _receiveData[6];
            NSNumber *day = _receiveData[7];
            NSNumber *hour = _receiveData[8];
            NSNumber *minute = _receiveData[9];
            NSNumber *row = _receiveData[10];
            NSNumber *alertsType = _receiveData[11];
            NSString *dateLabel = [[NSString alloc] initWithFormat:@"%d%d-%d-%d %d:%d",[year1 intValue],[year2 intValue],[month intValue],[day intValue],[hour intValue],[minute intValue]];
            [dataDic setObject:dateLabel forKey:@"dateLabel"];
            [dataDic setObject:row forKey:@"row"];
            [dataDic setObject:alertsType forKey:@"alertsType"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveAlertsContent" object:nil userInfo:dataDic];
        }else if (self.frameType == getMowerTime){
            NSLog(@"接收到getMowerTime");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *year1 = _receiveData[4];
            NSNumber *year2 = _receiveData[5];
            NSNumber *month = _receiveData[6];
            NSNumber *day = _receiveData[7];
            NSNumber *hour = _receiveData[8];
            NSNumber *minute = _receiveData[9];
            [dataDic setObject:year1 forKey:@"year1"];
            [dataDic setObject:year2 forKey:@"year2"];
            [dataDic setObject:month forKey:@"month"];
            [dataDic setObject:day forKey:@"day"];
            [dataDic setObject:hour forKey:@"hour"];
            [dataDic setObject:minute forKey:@"minute"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveMowerTime" object:nil userInfo:dataDic];
        }else if (self.frameType == getMowerLanguage){
            NSLog(@"接收到getMowerLanguage");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *Language = _receiveData[4];
            [dataDic setObject:Language forKey:@"Language"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveMowerLanguage" object:nil userInfo:dataDic];
        }else if (self.frameType == getWorkingTime1){
            NSLog(@"接收到getWorkingTime1");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *monStart = _receiveData[4];
            NSNumber *monWork = _receiveData[5];
            NSNumber *tueStart = _receiveData[6];
            NSNumber *tueWork = _receiveData[7];
            NSNumber *wedStart = _receiveData[8];
            NSNumber *wedWork = _receiveData[9];
            NSNumber *thuStart = _receiveData[10];
            NSNumber *thuWork = _receiveData[11];
            [dataDic setObject:monStart forKey:@"monStart"];
            [dataDic setObject:monWork forKey:@"monWork"];
            [dataDic setObject:tueStart forKey:@"tueStart"];
            [dataDic setObject:tueWork forKey:@"tueWork"];
            [dataDic setObject:wedStart forKey:@"wedStart"];
            [dataDic setObject:wedWork forKey:@"wedWork"];
            [dataDic setObject:thuStart forKey:@"thuStart"];
            [dataDic setObject:thuWork forKey:@"thuWork"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveWorkingTime1" object:nil userInfo:dataDic];
        }else if (self.frameType == getWorkingTime2){
            NSLog(@"接收到getWorkingTime2");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *friStart = _receiveData[4];
            NSNumber *friWork = _receiveData[5];
            NSNumber *satStart = _receiveData[6];
            NSNumber *satWork = _receiveData[7];
            NSNumber *sunStart = _receiveData[8];
            NSNumber *sunWork = _receiveData[9];
            [dataDic setObject:friStart forKey:@"friStart"];
            [dataDic setObject:friWork forKey:@"friWork"];
            [dataDic setObject:satStart forKey:@"satStart"];
            [dataDic setObject:satWork forKey:@"satWork"];
            [dataDic setObject:sunStart forKey:@"sunStart"];
            [dataDic setObject:sunWork forKey:@"sunWork"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveWorkingTime2" object:nil userInfo:dataDic];
        }else if (self.frameType == getMowerSetting){
            NSLog(@"接收到getMowerSetting");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *rain = _receiveData[4];
            NSNumber *boundary = _receiveData[5];
            [dataDic setObject:rain forKey:@"rain"];
            [dataDic setObject:boundary forKey:@"boundary"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveMowerSetting" object:nil userInfo:dataDic];
        }else if (self.frameType == updateFirmware){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveUpdateFirmware" object:nil userInfo:nil];
        }else if (self.frameType == getPinCode){
            NSNumber *thousand = _receiveData[4];
            NSNumber *hungred = _receiveData[5];
            NSNumber *ten = _receiveData[6];
            NSNumber *one = _receiveData[7];
            _pincode = [thousand intValue] * 1000 +[hungred intValue] * 100 + [ten intValue] * 10 + [one intValue];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:_pincode forKey:@"pincode"];
            [defaults synchronize];
            _sectionvalve = (int)_receiveData[8];
            
        }else if (self.frameType == setPincodeResponse){
            if ([_receiveData[0] intValue] == 1) {
                [NSObject showHudTipStr:LocalString(@"Set pincode wrong")];
            }else{
                NSNumber *thousand = _receiveData[4];
                NSNumber *hungred = _receiveData[5];
                NSNumber *ten = _receiveData[6];
                NSNumber *one = _receiveData[7];
                _pincode = [thousand intValue] * 1000 +[hungred intValue] * 100 + [ten intValue] * 10 + [one intValue];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:_pincode forKey:@"pincode"];
                [defaults synchronize];
            }
        }else if (self.frameType == getAeraMessage){
            NSLog(@"接收到getAeraMessage");
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSNumber *Apresent = _receiveData[4];
            NSNumber *AdistanceHungred = _receiveData[5];
            NSNumber *AdistanceTen = _receiveData[6];
            NSNumber *AdistanceOne = _receiveData[7];
            NSNumber *Bpresent = _receiveData[8];
            NSNumber *BdistanceHungred = _receiveData[9];
            NSNumber *BdistanceTen = _receiveData[10];
            NSNumber *BdistanceOne = _receiveData[11];
            [dataDic setObject:Apresent forKey:@"Apresent"];
            [dataDic setObject:AdistanceHungred forKey:@"AdistanceHungred"];
            [dataDic setObject:AdistanceTen forKey:@"AdistanceTen"];
            [dataDic setObject:AdistanceOne forKey:@"AdistanceOne"];
            [dataDic setObject:Bpresent forKey:@"Bpresent"];
            [dataDic setObject:BdistanceHungred forKey:@"BdistanceHungred"];
            [dataDic setObject:BdistanceTen forKey:@"BdistanceTen"];
            [dataDic setObject:BdistanceOne forKey:@"BdistanceOne"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveAeraMessage" object:nil userInfo:dataDic];
        }
    }
}

- (BOOL)frameIsRight:(NSArray *)data
{
    if (data != nil && ![data isKindOfClass:[NSNull class]] && data.count >= 3) {
        UInt8 front1 = [data[0] unsignedCharValue];
        UInt8 front2 = [data[1] unsignedCharValue];
        UInt8 front3 = [data[2] unsignedCharValue];
        
        if (front1 != 0x44 || front2 != 0x59 || front3 != 0x4d) {
            return NO;
        }
    }else{
        return NO;
    }
    
    return YES;
}

- (FrameType)checkOutType:(NSArray *)data
{
    unsigned char dataType;
    
    unsigned char type[LEN]= {
        0x80,0x82,0x83,0x84,0x85,0x87,0x89,0x8a,0x8c,0x86,0x8d
    };
    
    dataType = [data[3] unsignedIntegerValue];
    NSLog(@"%d", dataType);
    
    FrameType returnVal = otherFrame;
    
    for (int i = 0; i < LEN; i++) {
        if (dataType == type[i]) {
            switch (i) {
                case 0:
                    returnVal = readBattery;
                    break;
                    
                case 1:
                    returnVal = getMowerTime;
                    break;
                    
                case 2:
                    returnVal = getMowerLanguage;
                    break;
                    
                case 3:
                    returnVal = getWorkingTime1;
                    break;
                    
                case 4:
                    returnVal = getWorkingTime2;
                    break;
                    
                case 5:
                    returnVal = getAlerts;
                    break;
                
                case 6:
                    returnVal = getMowerSetting;
                    break;
                
                case 7:
                    returnVal = updateFirmware;
                    break;
                case 8:
                    returnVal = getPinCode;
                    break;
                
                case 9:
                    returnVal = setPincodeResponse;
                    break;
                    
                case 10:
                    returnVal = getAeraMessage;
                    break;
                default:
                    returnVal = otherFrame;
                    break;
            }
        }
    }
    return returnVal;
}

@end
