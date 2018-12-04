//
//  QueryDeviceController.m
//  MOWOX
//
//  Created by 杭州轨物科技有限公司 on 2018/8/3.
//  Copyright © 2018年 yusz. All rights reserved.
//

#import "QueryDeviceController.h"
#import "GCDAsyncUdpSocket.h"
#import "MJRefresh.h"
#import "DeviceTableViewCell.h"
#import "DeviceModel.h"
#import "EspViewController.h"

#import <SystemConfiguration/CaptiveNetwork.h>

#import <sys/socket.h>
#import <netdb.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "AFHTTPSessionManager.h"

#define HEIGHT_CELL 44.f
#define HEIGHT_HEADER 44.f
#define resendTimes 3

NSString *const CellIdentifier_device = @"CellID_device";
NSString *const CellNibName_device = @"DeviceTableViewCell";

@interface QueryDeviceController () <GCDAsyncUdpSocketDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) UITableView *devieceTable;
@property (nonatomic, strong) UIScrollView *noDeviceView;

///@brief 当前设备
@property (nonatomic, strong) NSMutableArray *onlineDeviceArray;

@end

@implementation QueryDeviceController
{
    BOOL isConnect;
    int resendTime;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;

    self.navigationItem.title = LocalString(@"Device");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 20, 20);
    [rightButton setImage:[UIImage imageNamed:@"img_nav_more"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(goEsp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"https://8.8.8.8" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
    _timer = [self timer];
    [self sendSearchBroadcast];
    
    if (!_onlineDeviceArray) {
        _onlineDeviceArray = [NSMutableArray array];
    }
    
    _noDeviceView = [self noDeviceView];
    _devieceTable = [self devieceTable];
    _lock = [self lock];
    
//    if (!_onlineDeviceArray.count && ![NetWork shareNetWork].connectedGateway) {
//        _devieceTable.hidden = YES;
//        _noDeviceView.hidden = NO;
//    }else{
//        _devieceTable.hidden = NO;
//        _noDeviceView.hidden = YES;
//    }
    _devieceTable.hidden = NO;
    _noDeviceView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    _timer = nil;
}

- (void)dealloc{
    if (_timer) {
        [_timer fire];
        _timer = nil;
    }
}

#pragma mark - lazy load
- (UITableView *)devieceTable{
    if (!_devieceTable) {
        _devieceTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
            
            tableView.backgroundColor = [UIColor colorWithRed:0.15 green:0.16 blue:0.16 alpha:1.0];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.hidden = YES;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[DeviceTableViewCell class] forCellReuseIdentifier:CellIdentifier_device];
            [tableView registerNib:[UINib nibWithNibName:CellNibName_device bundle:nil] forCellReuseIdentifier:CellIdentifier_device];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            //tableView.scrollEnabled = NO;
            if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
                [tableView setSeparatorInset:UIEdgeInsetsZero];
            }
            if ([tableView respondsToSelector:@selector(setLayoutMargins:)])  {
                [tableView setLayoutMargins:UIEdgeInsetsZero];
            }
            
            MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(sendSearchBroadcast)];
            // Set title
            [header setTitle:LocalString(@"Pull-down refresh") forState:MJRefreshStateIdle];
            [header setTitle:LocalString(@"Release refresh") forState:MJRefreshStatePulling];
            [header setTitle:LocalString(@"Loading") forState:MJRefreshStateRefreshing];
            
            // Set font
            header.stateLabel.font = [UIFont systemFontOfSize:15];
            header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
            
            // Set textColor
            header.stateLabel.textColor = [UIColor lightGrayColor];
            header.lastUpdatedTimeLabel.textColor = [UIColor clearColor];
            tableView.mj_header = header;
            tableView;
        });
    }
    return _devieceTable;
}

- (UIScrollView *)noDeviceView{
    if (!_noDeviceView) {
        _noDeviceView = [[UIScrollView alloc] init];
        _noDeviceView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        _noDeviceView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
        _noDeviceView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1];
        [self.view addSubview:_noDeviceView];
        
        MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(sendSearchBroadcast)];
        // Set title
        [header setTitle:LocalString(@"Pull-down refresh") forState:MJRefreshStateIdle];
        [header setTitle:LocalString(@"Release refresh") forState:MJRefreshStatePulling];
        [header setTitle:LocalString(@"Loading") forState:MJRefreshStateRefreshing];
        
        // Set font
        header.stateLabel.font = [UIFont systemFontOfSize:15];
        header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
        
        // Set textColor
        header.stateLabel.textColor = [UIColor lightGrayColor];
        header.lastUpdatedTimeLabel.textColor = [UIColor lightGrayColor];
        _noDeviceView.mj_header = header;
        
        UILabel *label = [[UILabel alloc] init];
        label.text = LocalString(@"Add your gateway soon!");
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_noDeviceView addSubview:label];
        
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn setTitle:LocalString(@"Add GateWay") forState:UIControlStateNormal];
        [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [addBtn setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.5];
        [addBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        [addBtn addTarget:self action:@selector(goEsp) forControlEvents:UIControlEventTouchUpInside];
        [_noDeviceView addSubview:addBtn];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(168.f / WScale, 20.f / HScale));
            make.centerX.equalTo(_noDeviceView.mas_centerX);
            make.top.equalTo(_noDeviceView.mas_top).offset(334.f / HScale);
        }];
        
        [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(345.f / WScale, 50.f / HScale));
            make.centerX.equalTo(_noDeviceView.mas_centerX);
            make.top.equalTo(_noDeviceView.mas_top).offset(374.f / HScale);
        }];
    }
    return _noDeviceView;
}

- (NSTimer *)timer{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(broadcast) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

-(NSLock *)lock{
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

#pragma mark - udp
- (GCDAsyncUdpSocket *)udpSocket{
    if (!_udpSocket) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _udpSocket;
}

- (void)sendSearchBroadcast{
    resendTime = resendTimes;
    
    _udpSocket = [self udpSocket];
    
    [_udpSocket localPort];
    
    NSError *error;
    
    //设置广播
    [_udpSocket enableBroadcast:YES error:&error];
    
    //开启接收数据
    [_udpSocket beginReceiving:&error];
    if (error) {
        NSLog(@"开启接收数据:%@",error);
        return;
    }
    
    isConnect = NO;
    [_timer setFireDate:[NSDate date]];
}

- (void)broadcast{
    
    if (isConnect || resendTime == 0) {
        [_timer setFireDate:[NSDate distantFuture]];
        NSLog(@"发送三次udp请求或已经接收到数据");
        [self.devieceTable.mj_header endRefreshing];
        [self.noDeviceView.mj_header endRefreshing];
        return;
    }else{
        resendTime--;
    }
    
    NSString *host = @"255.255.255.255";
    NSTimeInterval timeout = 2000;
    NSString *request = @"whereareyou\r\n";
    NSData *data = [NSData dataWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    UInt16 port = 17888;
    
    [_udpSocket sendData:data toHost:host port:port withTimeout:timeout tag:200];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    [_lock lock];
    NSLog(@"UDP接收数据……………………………………………………");
    [self.devieceTable.mj_header endRefreshing];
    isConnect = YES;//停止发送udp
    if (1) {
        /**
         *获取IP地址
         **/
        // Copy data to a "sockaddr_storage" structure.
        struct sockaddr_storage sa;
        socklen_t salen = sizeof(sa);
        [address getBytes:&sa length:salen];
        // Get host from socket address as C string:
        char host[NI_MAXHOST];
        getnameinfo((struct sockaddr *)&sa, salen, host, sizeof(host), NULL, 0, NI_NUMERICHOST);
        // Convert C string to NSString:
        NSString *ipAddress = [[NSString alloc] initWithBytes:host length:strlen(host) encoding:NSUTF8StringEncoding];
        
        //避免重复显示同一个设备
        int isContain = 0;
        for (DeviceModel *device in _onlineDeviceArray) {
            if ([ipAddress isEqualToString:device.ipAddress]) {
                isContain = 1;
                break;
            }
        }
        if (!isContain && ![[NetWork shareNetWork].connectedGateway.ipAddress isEqualToString:ipAddress]) {
            DeviceModel *dModel = [[DeviceModel alloc] init];
            dModel.ipAddress = ipAddress;
            NSLog(@"strAddr = %@", ipAddress);
            
            NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",msg);
            dModel.deviceMac = [msg substringWithRange:NSMakeRange(0, 8)];
            
            [_onlineDeviceArray addObject:dModel];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!_onlineDeviceArray.count) {
                    _devieceTable.hidden = YES;
                    _noDeviceView.hidden = NO;
                }else{
                    _devieceTable.hidden = NO;
                    _noDeviceView.hidden = YES;
                }
                
                [_devieceTable reloadData];
            });
        }
        
    }
    [_lock unlock];
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    NSLog(@"断开连接");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"发送的消息");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    NSLog(@"已经连接");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"断开连接");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"没有发送数据");
}

#pragma mark - 获取网络信息
- (NSDictionary *)fetchNetInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    //    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        //        NSLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

- (NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}

#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:{
            return 1;
        }
            
        case 1:
            return _onlineDeviceArray.count;
            //return 1;
            
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_device];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellNibName_device owner:self options:nil] lastObject];
        }
        
        DeviceModel *dModel = _onlineDeviceArray[indexPath.row];
        cell.deviceLabel.text = dModel.deviceMac;
        
        return cell;
    }else{
        DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_device];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellNibName_device owner:self options:nil] lastObject];
        }
        NetWork *net = [NetWork shareNetWork];
        if (net.connectedGateway.deviceMac) {
            cell.deviceLabel.text = net.connectedGateway.deviceMac;
            cell.userInteractionEnabled = YES;
        }else{
            cell.deviceLabel.text = LocalString(@"nodevice");
            cell.userInteractionEnabled = NO;
        }
        
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NetWork *net = [NetWork shareNetWork];
    if (indexPath.section == 1) {
        
        if (!net.mySocket.isDisconnected) {
            net.isReconnect = YES;
            [net.mySocket disconnect];
        }
        
        NSError *error = nil;
        DeviceModel *dModel = _onlineDeviceArray[indexPath.row];
        [net connectToHost:dModel.ipAddress onPort:16888 error:&error];
        
        if (error) {
            NSLog(@"tcp连接错误:%@",error);
        }else{
            net.connectedGateway = dModel;
            [_onlineDeviceArray removeObject:dModel];
            [tableView reloadData];
            [net.NodeFrame removeAllObjects];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }else if (indexPath.section == 0){
        if (!net.mySocket.isDisconnected) {
            [net.mySocket disconnect];
            net.connectedGateway = nil;
            [_devieceTable reloadData];
            [_timer setFireDate:[NSDate date]];
        }else{
            net.connectedGateway = nil;
            [_devieceTable reloadData];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER)];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, HEIGHT_HEADER)];
    headerView.backgroundColor = [UIColor darkGrayColor];
    headerTitle.font = [UIFont systemFontOfSize:18.f];
    headerTitle.adjustsFontSizeToFitWidth = YES;
    if (section == 0) {
        headerTitle.text = LocalString(@"Connected Device");
    }else{
        headerTitle.text = LocalString(@"Available Device");
    }
    [headerView addSubview:headerTitle];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEIGHT_HEADER;
}

#pragma mark - view action

- (void)goEsp{
    EspViewController *EspVC = [[EspViewController alloc] init];
    NSDictionary *netInfo = [self fetchNetInfo];
    EspVC.ssid = [netInfo objectForKey:@"SSID"];
    EspVC.bssid = [netInfo objectForKey:@"BSSID"];
    NSLog(@"%@",[netInfo objectForKey:@"SSID"]);
    EspVC.block = ^(ESPTouchResult *result) {

    };
    [self.navigationController pushViewController:EspVC animated:YES];

}

@end
