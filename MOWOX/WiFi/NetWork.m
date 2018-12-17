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
//        if (!_recivedData68) {
//            _recivedData68 = [[NSMutableArray alloc] init];
//        }
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
//- (NSTimer *)myTimer{
//    if (!_myTimer) {
//        _myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTemp) userInfo:nil repeats:YES];
//        [_myTimer setFireDate:[NSDate distantFuture]];
//    }
//    return _myTimer;
//}

#pragma mark - Tcp Delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接成功");
    if (!_isReconnect) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject showHudTipStr:LocalString(@"Connection succeeded!")];
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
            [NSObject showHudTipStr:LocalString(@"Connect new devices.")];
        });
        _isReconnect = NO;
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject showHudTipStr:LocalString(@"Disconnect")];
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

- (void)mowerSendWithData:(NSMutableArray *)mowerData{
    NSMutableArray *packMower68 = [[NSMutableArray alloc ] init];
    [packMower68 addObjectsFromArray:mowerData];
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
    if (data){
        
        [[BluetoothDataManage shareInstance] handleData:data];
    }
}

-(BOOL)frameIsRight:(NSArray *)data
{
    NSUInteger count = data.count;
    UInt8 end1 = [data[count-2] unsignedCharValue];
    UInt8 end2 = [data[count-1] unsignedCharValue];
    
    //判断帧头帧尾
    if (end1 != 0x0D || end2 != 0x0A)
    {
        NSLog(@"帧尾错误");
        return NO;
    }
    return YES;
}


@end
