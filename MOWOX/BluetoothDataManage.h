//
//  BluetoothDataManage.h
//  MOWOX
//
//  Created by Mac on 2017/10/31.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    otherFrame,
    readBattery,
    getAlerts,
    getMowerTime,
    getMowerLanguage,
    getWorkingTime1,
    getWorkingTime2,
    getMowerSetting,
    updateFirmware,
    getPinCode,
    setPincodeResponse,
    getAeraMessage
}FrameType;
static dispatch_queue_t queue;

@interface BluetoothDataManage : NSObject

///@brife 烧固件用的j
@property (nonatomic) int updateFirmware_j;//bin文件每个包传送的第一个字节位置
@property (nonatomic) int updateFirmware_packageNum;//bin文件包的数量，用来判断是否是最后一个包了，防止溢出
@property (nonatomic) int progress_num;//判断当前是第几个包，用来显示进度条

///@brife 帧数据组成内容
@property (nonatomic,strong,readonly) NSMutableArray *bluetoothData;
@property (nonatomic,strong,readonly) NSNumber *dataType;
@property (nonatomic,strong,readonly) NSMutableArray *dataContent;

///@brife 接收的数据帧
@property (nonatomic,strong,readonly) NSMutableArray *receiveData;
@property (nonatomic,assign)FrameType frameType;

///@brife 接收到的pin码
@property (nonatomic) int pincode;

///@brife 收到的版本信息
@property (nonatomic) int deviceType;
@property (nonatomic) int version1;
@property (nonatomic) int version2;
@property (nonatomic) int version3;
//@接收值第五位返回的pin值
@property (nonatomic) int sectionvalve;
//@获取分区信息1d
@property (nonatomic) int getAeraMessage;

+ (instancetype)shareInstance;

- (void)setDataType:(UInt8)dataType;

- (void)setDataContent:(NSArray *)dataContent;

- (void)sendBluetoothFrame;

- (void)handleData:(NSArray *)data;

@end
