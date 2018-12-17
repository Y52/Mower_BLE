//
//  NetWork.m
//  MOWOX
//
//  Created by 杭州轨物科技有限公司 on 2018/8/3.
//  Copyright © 2018年 yusz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@class DeviceModel;

typedef enum{
    readReplyFrame,
    commandFrame,
    otherFrameType
}FrameType68;

///@接收到的温度帧数量和查询温度帧数量
static int recvCount = 0;
static int sendCount = 0;

///@读取数据数量版本
static NSInteger tempCountVer = 1000;

@interface NetWork : NSObject <GCDAsyncSocketDelegate>

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_semaphore_t signal;

///@brief 连接上的网关
@property (nonatomic, strong) DeviceModel *connectedGateway;
@property (nonatomic) BOOL isReconnect;

@property (nonatomic, strong) GCDAsyncSocket *mySocket;
///@brief 接收数据
//@property (nonatomic, strong) NSMutableArray *recivedData68;
///@brief 帧类型
@property (nonatomic, assign) FrameType68 frame68Type;

@property(nonatomic) UInt8 mowerNodeAddrH;
@property(nonatomic) UInt8 mowerNodeAddrL;
@property (nonatomic ,strong) NSMutableArray *NodeFrame;//查询到的节点帧，清空则重新查询

///@brief 计时器和计时总数
@property (nonatomic, strong) NSTimer *myTimer;
///@brief 计时器数据,app中所有计时都以秒为单位
@property (nonatomic, assign) int timerValue;



///@brief 单例模式
+ (instancetype)shareNetWork;

///@brief 发送数据
- (void)send:(NSMutableArray *)msg withTag:(NSUInteger)tag;

///@brief 连接
- (BOOL)connectToHost:(NSString*)host onPort:(uint16_t)port error:(NSError **)errPtr;

- (void)mowerFirmwareWithData:(NSData *)sendData;

- (void)mowerSendWithData:(NSMutableArray *)mowerData;
@end
