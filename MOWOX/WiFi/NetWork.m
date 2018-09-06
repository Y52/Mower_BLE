//
//  NetWork.m
//  MOWOX
//
//  Created by 杭州轨物科技有限公司 on 2018/8/3.
//  Copyright © 2018年 yusz. All rights reserved.
//

#import "NetWork.h"
#import "NSString+Common.h"


///@brife 可判断的数据帧类型数量
#define LEN 8

///@brife 一次最大读取温度
#define maxTempCount 20

static NetWork *_netWork = nil;
static UInt8 frameCount;

@implementation NetWork

+ (instancetype)shareNetWork{
    if (_netWork == nil) {
        _netWork = [[self alloc] init];
    }
    return _netWork;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
        if (_netWork == nil) {
            _netWork = [super allocWithZone:zone];
        }
    });
    
    return _netWork;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        dispatch_queue_t queue = dispatch_queue_create("netQueue", DISPATCH_QUEUE_SERIAL);
        if (!_mySocket) {
            _mySocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
        }
        if (!_recivedData68) {
            _recivedData68 = [[NSMutableArray alloc] init];
        }
        _myTimer = [self myTimer];
        _queue = dispatch_queue_create("com.thingcom.queue", DISPATCH_QUEUE_SERIAL);
        if (!_signal) {
            _signal = dispatch_semaphore_create(0);
        }
        _NodeFrame = [[NSMutableArray alloc] init];
        frameCount = 0;
    }
    return self;
}

#pragma mark - Lazy load
- (NSTimer *)myTimer{
    if (!_myTimer) {
        _myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTemp) userInfo:nil repeats:YES];
        [_myTimer setFireDate:[NSDate distantFuture]];
    }
    return _myTimer;
}

#pragma mark - Tcp Delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接成功");
    if (!_isReconnect) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject showHudTipStr:LocalString(@"连接成功")];
        });
    }
    frameCount = 0;
    [_mySocket readDataWithTimeout:-1 tag:1];
    [_mySocket readDataWithTimeout:-1 tag:1];
    [_mySocket readDataWithTimeout:-1 tag:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"连接失败");
    if (_isReconnect) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject showHudTipStr:LocalString(@"连接新网关")];
        });
        _isReconnect = NO;
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject showHudTipStr:LocalString(@"连接已断开")];
            _connectedGateway = nil;
        });
    }

    [_myTimer setFireDate:[NSDate distantFuture]];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"接收到消息%@",data);
    NSLog(@"socket成功收到帧, tag: %ld", tag);
    [self checkOutFrame:data];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //NSLog(@"发送了一条帧");
    frameCount++;
}

#pragma mark - Actions
//tcp connect
- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError *__autoreleasing *)errPtr{
    if (![_mySocket isDisconnected]) {
        NSLog(@"主动断开");
        [_mySocket disconnect];
        _connectedGateway = nil;
    }
    return [_mySocket connectToHost:host onPort:port error:errPtr];
}

//帧的发送
- (void)send:(NSMutableArray *)msg withTag:(NSUInteger)tag
{
    @synchronized(self) {
        //NSLog(@"%D",[self.mySocket isDisconnected]);
        if (![self.mySocket isDisconnected])
        {
            NSUInteger len = msg.count;
            UInt8 sendBuffer[len];
            for (int i = 0; i < len; i++)
            {
                sendBuffer[i] = [[msg objectAtIndex:i] unsignedCharValue];
            }
            
            NSData *sendData = [NSData dataWithBytes:sendBuffer length:len];
            NSLog(@"发送一条帧： %@",sendData);
            if (tag == 100) {
                [self.mySocket writeData:sendData withTimeout:-1 tag:1];
                [_mySocket readDataWithTimeout:-1 tag:1];
            }else if(tag == 101){
                //查节点
                [self.mySocket writeData:sendData withTimeout:-1 tag:1];
                [_mySocket readDataWithTimeout:-1 tag:1];
            }else if (tag == 102){
                //查湿度计电量
                [self.mySocket writeData:sendData withTimeout:-1 tag:1];
                [_mySocket readDataWithTimeout:-1 tag:1];
            }else if(tag == 103){
                //查水阀
                [self.mySocket writeData:sendData withTimeout:-1 tag:2];
                [_mySocket readDataWithTimeout:-1 tag:1];
            }else if (tag == 104){
                //设置开关
                [self.mySocket writeData:sendData withTimeout:-1 tag:1];
                [_mySocket readDataWithTimeout:-1 tag:1];
            }else if (tag == 105){
                //读写水阀工作时间
                [self.mySocket writeData:sendData withTimeout:-1 tag:1];
                [_mySocket readDataWithTimeout:-1 tag:1];
            }else if (tag == 106){
                //查湿度计对应水阀的报警工作时间
                [self.mySocket writeData:sendData withTimeout:-1 tag:1];
                [_mySocket readDataWithTimeout:-1 tag:1];
            }else if (tag == 107){
                //添加节点
                [self.mySocket writeData:sendData withTimeout:-1 tag:1];
                [_mySocket readDataWithTimeout:-1 tag:1];
            }else if (tag == 108){
                //设置系统时间
                [self.mySocket writeData:sendData withTimeout:-1 tag:1];
                [_mySocket readDataWithTimeout:-1 tag:1];
            }
            
            [NSThread sleepForTimeInterval:0.6];
            
        }
        else
        {
            NSLog(@"Socket未连接");
        }
    }
}

- (void)inquireNode{
    if (_NodeFrame.count != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getNode" object:nil userInfo:@{@"dataArr":_NodeFrame}];
        return;
    }
    NSMutableArray *getMowerNode = [[NSMutableArray alloc ] init];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:0x09]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:0x04]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:0x45]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:getMowerNode]]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [getMowerNode addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:getMowerNode withTag:101];
    });
}

- (void)inquireMoistureBatteryAndHumidity:(int)NodeAddrH low:(int)NodeAddrL{
    NSMutableArray *getMoisBat = [[NSMutableArray alloc ] init];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:NodeAddrH]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:NodeAddrL]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x04]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0xF0]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x11]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x04]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:getMoisBat]]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:getMoisBat withTag:102];
    });
}

- (void)inquireMoistureReleValveWorktimelow:(int)NodeAddrL{
    NSMutableArray *getMoisBat = [[NSMutableArray alloc ] init];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0xF1]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:NodeAddrL]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x04]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0xF0]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x10]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x08]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:getMoisBat]]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:getMoisBat withTag:106];
    });
}

- (void)setMoistureReleValveWorktimelow:(int)NodeAddrL withTime:(int)time{
    NSMutableArray *getMoisBat = [[NSMutableArray alloc ] init];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0xF1]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:NodeAddrL]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0xF0]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x10]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x08]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:time]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:getMoisBat]]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:getMoisBat withTag:106];
    });
}


- (void)setMoistureHumidityLimit:(int)NodeAddrH low:(int)NodeAddrL limit:(int)limit{
    NSMutableArray *getMoisBat = [[NSMutableArray alloc ] init];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:NodeAddrH]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:NodeAddrL]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0xF0]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x11]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x03]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:limit]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:getMoisBat]]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [getMoisBat addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:getMoisBat withTag:102];
    });
}


- (void)inquireValveBatteryAndStatus:(int)NodeAddrH low:(int)NodeAddrL{
    NSMutableArray *getVavle = [[NSMutableArray alloc ] init];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:NodeAddrH]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:NodeAddrL]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:0x04]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:0xF0]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:0x10]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:0x06]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:getVavle]]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [getVavle addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:getVavle withTag:103];
    });
}

- (void)inquireValveWorktime:(int)NodeAddrH low:(int)NodeAddrL{
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:NodeAddrH]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:NodeAddrL]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x04]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0xF0]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x10]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x07]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:dataContent]]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:dataContent withTag:105];
    });
}

- (void)setValveWorktime:(int)NodeAddrH low:(int)NodeAddrL data:(NSArray *)dataArr{
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:NodeAddrH]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:NodeAddrL]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x19]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0xF0]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x10]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x07]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [dataContent addObjectsFromArray:dataArr];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:dataContent]]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:dataContent withTag:105];
    });
}

- (void)setValveStatus:(int)NodeAddrH low:(int)NodeAddrL status:(int)status{
    NSMutableArray *setVavle = [[NSMutableArray alloc ] init];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:NodeAddrH]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:NodeAddrL]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0xF0]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x10]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:status]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:setVavle]]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:setVavle withTag:104];
    });
}

- (void)setValveStartWorktime:(int)NodeAddrH low:(int)NodeAddrL worktime:(int)worktime{
    NSMutableArray *setVavle = [[NSMutableArray alloc ] init];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x05]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:NodeAddrH]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:NodeAddrL]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x06]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0xF0]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x10]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x0a]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:worktime/100]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:worktime%100]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:setVavle]]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [setVavle addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:setVavle withTag:104];
    });
}

- (void)mowerSendWithData:(NSMutableArray *)mowerData{
    NSMutableArray *packMower68 = [[NSMutableArray alloc ] init];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:_mowerNodeAddrH]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:_mowerNodeAddrL]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:mowerData.count]];
    [packMower68 addObjectsFromArray:mowerData];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:packMower68]]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:packMower68 withTag:100];
    });
}

- (void)mowerFirmwareWithData:(NSData *)sendData{
    NSMutableArray *packMower68 = [[NSMutableArray alloc ] init];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:_mowerNodeAddrH]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:_mowerNodeAddrL]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    
    NSMutableArray *dataArray = [NSMutableArray new];
    NSData *recvBuffer = [NSData dataWithData:sendData];
    NSUInteger recvLen = [recvBuffer length];
    UInt8 *recv = (UInt8 *)[recvBuffer bytes];
    //把接收到的数据存放在recvData数组中
    NSUInteger j = 0;
    while (j < recvLen) {
        [dataArray addObject:[NSNumber numberWithUnsignedChar:recv[j]]];
        j++;
    }
    
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:dataArray.count]];
    [packMower68 addObjectsFromArray:dataArray];
    
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:packMower68]]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [packMower68 addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    
    dispatch_async(_queue, ^{
        [self send:packMower68 withTag:100];
    });
    
}

- (void)addNodeWithMac:(NSString *)Mac{
    Byte *byte = [NSString UInt8ByHexString:Mac];
    
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x09]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x08]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x02]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x13]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:byte[3]]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:byte[0]]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:byte[1]]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:byte[2]]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:dataContent]]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:dataContent withTag:107];
    });
}

- (void)deleteNodeWithMac:(int)NodeAddrH low:(int)NodeAddrL{
    
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x09]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x08]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x02]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x92]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:NodeAddrL]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:NodeAddrH]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:NodeAddrH]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:NodeAddrH]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:dataContent]]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:dataContent withTag:107];
    });
}

- (void)setSystemClock{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekday fromDate:now];
    
    NSInteger year= [components year];
    NSInteger month= [components month];
    NSInteger day= [components day];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger second = [components second];
    NSInteger weekday = [components weekday];
    NSLog(@"%ld",(long)weekday);
    UInt8 week = 0b00000001;
    while (weekday > 1) {
        week = week << 1;
        weekday--;
    }
    
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x68]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x09]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:frameCount]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x0B]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x80]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x10]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:year % 2000]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:month]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:day]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:hour]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:minute]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:second]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:week]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:dataContent]]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x16]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x0D]];
    [dataContent addObject:[NSNumber numberWithUnsignedChar:0x0A]];
    dispatch_async(_queue, ^{
        [self send:dataContent withTag:108];
    });
}
#pragma mark - Frame68 接收处理
- (void)checkOutFrame:(NSData *)data{
    //把读到的数据复制一份
    NSData *recvBuffer = [NSData dataWithData:data];
    NSUInteger recvLen = [recvBuffer length];
    //NSLog(@"%lu",(unsigned long)recvLen);
    UInt8 *recv = (UInt8 *)[recvBuffer bytes];
    if (recvLen > 1000) {
        return;
    }
    //把接收到的数据存放在recvData数组中
    NSMutableArray *recvData = [[NSMutableArray alloc] init];
    NSUInteger j = 0;
    while (j < recvLen) {
        [recvData addObject:[NSNumber numberWithUnsignedChar:recv[j]]];
        j++;
    }
    [self handle68Message:recvData];
}

- (void)handle68Message:(NSArray *)data
{
    if (![self frameIsRight:data])
    {
        //68帧数据错误
        NSLog(@"68帧数据错误");
        return;
    }
    if (_recivedData68)
    {
        [_recivedData68 removeAllObjects];
        [_recivedData68 addObjectsFromArray:data];
        self.frame68Type = [self checkOutFrameType:data];
        
        if (self.frame68Type == readReplyFrame) {
            //控制码80即为割草机操控，透传
            //把读到的数据复制一份
            [[BluetoothDataManage shareInstance] handleData:_recivedData68];
        }else if (self.frame68Type == commandFrame){
            //命令帧
            if ([_recivedData68[8] unsignedIntegerValue] == 0x00) {
                switch ([_recivedData68[10] unsignedCharValue]) {
                    case 0x10:{
                        //设置系统时间结果
                    }
                        break;
                    case 0x13:{
                        //添加节点
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if([_recivedData68[12] unsignedCharValue] == 0xFF){
                                [NSObject showHudTipStr:LocalString(@"添加失败")];
                            }else{
                                if ([_recivedData68[16] unsignedCharValue] == 0xf1) {
                                    [NSObject showHudTipStr:LocalString(@"添加水阀成功")];
                                }else if ([_recivedData68[16] unsignedCharValue] == 0xf2){
                                    [NSObject showHudTipStr:LocalString(@"添加湿度计成功")];
                                }else if ([_recivedData68[16] unsignedCharValue] == 0xf3){
                                    [NSObject showHudTipStr:LocalString(@"添加割草机成功")];
                                }
                            }
                        });
                        
                    }
                        break;
                    case 0x45:{
                        //查询网关节点
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getNode" object:nil userInfo:@{@"dataArr":_recivedData68}];
                        _NodeFrame = [_recivedData68 mutableCopy];
                    }
                        break;
                    case 0x92:{
                        
                    }
                    default:
                        break;
                }
            }else if ([_recivedData68[8] unsignedIntegerValue] == 0xF0){
                if ([_recivedData68[9] unsignedIntegerValue] == 0x11) {
                    //湿度计
                    switch ([_recivedData68[10] unsignedIntegerValue]) {
                        case 0x01:{
                            if ([_recivedData68[11] unsignedIntegerValue] == 0x00) {
                                //查询湿度值
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getMoistureValue" object:nil userInfo:@{@"dataArr":_recivedData68}];
                            }
                        }
                            break;
                            
                        case 0x02:
                            if ([_recivedData68[11] unsignedIntegerValue] == 0x00) {
                                //查询电量
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getMoistureBattery" object:nil userInfo:@{@"dataArr":_recivedData68}];
                            }
                            break;
                            
                        case 0x03:{
                            if ([_recivedData68[11] unsignedIntegerValue] == 0x00) {
                                //查询湿度阈值
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getMoistureLimit" object:nil userInfo:@{@"dataArr":_recivedData68}];
                            }else if ([_recivedData68[11] unsignedIntegerValue] == 0x01){
                                //设置湿度阈值成功
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"setMoistureLimitSucces" object:nil userInfo:@{@"dataArr":_recivedData68}];
                            }
                        }
                            break;
                            
                        case 0x04:{
                            if ([_recivedData68[11] unsignedIntegerValue] == 0x00){
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getMoistureValueAndBattery" object:nil userInfo:@{@"dataArr":_recivedData68}];

                            }
                        }
                            break;
                            
                        default:
                            break;
                    }
                }else if ([_recivedData68[9] unsignedIntegerValue] == 0x10){
                    switch ([_recivedData68[10] unsignedIntegerValue]) {
                        case 0x06:
                            {
                                if ([_recivedData68[11] unsignedIntegerValue] == 0x00){
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getValveBatteryAndStatus" object:nil userInfo:@{@"dataArr":_recivedData68}];

                                }
                            }
                            break;
                        case 0x07:
                        {
                            if ([_recivedData68[11] unsignedIntegerValue] == 0x00){
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getValveWorktime" object:nil userInfo:@{@"dataArr":_recivedData68}];
                            }else if ([_recivedData68[11] unsignedIntegerValue] == 0x01){
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"setValveWorktimeSucc" object:nil userInfo:nil];
                            }
                            
                        }
                            break;
                        case 0x08:
                        {
                            if ([_recivedData68[11] unsignedIntegerValue] == 0x00){
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"getMoisReleValveInfo" object:nil userInfo:@{@"dataArr":_recivedData68}];
                            }else if ([_recivedData68[11] unsignedIntegerValue] == 0x01){
                                
                            }
                            
                        }
                        case 0x0a:
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if ([_recivedData68[11] unsignedIntegerValue] == 0x00){

                                }else if ([_recivedData68[11] unsignedIntegerValue] == 0x01){
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"setValveStartWorktimeSucc" object:nil userInfo:@{@"dataArr":_recivedData68}];
                                    [NSObject showHudTipStr:LocalString(@"设置开启时间成功")];
                                }
                            });
                            
                        }
                        default:
                            break;
                    }
                }
            }
        }
        
    }
    
}

-(BOOL)frameIsRight:(NSArray *)data
{
    NSUInteger count = data.count;
    UInt8 front = [data[0] unsignedCharValue];
    UInt8 end1 = [data[count-3] unsignedCharValue];
    UInt8 end2 = [data[count-2] unsignedCharValue];
    UInt8 end3 = [data[count-1] unsignedCharValue];
    
    //判断帧头帧尾
    if (front != 0x68 || end1 != 0x16 || end2 != 0x0D || end3 != 0x0A)
    {
        NSLog(@"帧头帧尾错误");
        return NO;
    }
    //判断cs位
    UInt8 csTemp = 0x00;
    for (int i = 0; i < count - 4; i++)
    {
        csTemp += [data[i] unsignedCharValue];
    }
    if (csTemp != [data[count-4] unsignedCharValue])
    {
        NSLog(@"校验错误");
        return NO;
    }
    return YES;
}

//判断是命令帧还是回复帧
- (FrameType68)checkOutFrameType:(NSArray *)data{
    unsigned char dataType;
    
    unsigned char type[2] = {
        0x00,0x01
    };
    
    dataType = [data[1] unsignedIntegerValue];
    dataType = dataType & 0x03;
    //NSLog(@"%d",dataType);
    FrameType68 returnVal = otherFrameType;
    
    for (int i = 0; i < 2; i++) {
        if (dataType == type[i]) {
            switch (i) {
                case 0:
                    returnVal = readReplyFrame;//割草机
                    break;
                    
                case 1:
                    returnVal = commandFrame;//水阀和温湿度
                    break;
                    
                default:
                    returnVal = otherFrameType;
                    break;
            }
        }
    }
    return returnVal;
}

@end
