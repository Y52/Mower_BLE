//
//  QueryMowerController.m
//  MOWOX
//
//  Created by 杭州轨物科技有限公司 on 2018/8/4.
//  Copyright © 2018年 yusz. All rights reserved.
//

#import "QueryMowerController.h"
#import "MJRefresh.h"
#import "MowerListCell.h"
#import "LoginViewController.h"
#import "LMPopInputPasswordView.h"
#import "RDVViewController.h"
//#import "QRCodeAddDeviceController.h"
#import "MowerModel.h"

NSString *const CellIdentifier_Mower = @"CellID_Mower";

@interface QueryMowerController () <UITableViewDelegate,UITableViewDataSource,LMPopInputPassViewDelegate>

@property (nonatomic, strong) UITableView *mowerTable;
@property (nonatomic, strong) UIScrollView *noMowerView;

@property (nonatomic, strong) NSMutableArray *onlineMowerArray;
@property (nonatomic, strong) NSMutableArray *offlineMowerArray;

@property (nonatomic, strong) UIView *pwView;
@property (nonatomic, strong) UITextField *passwordField;
//用于存放黑色的点点
@property (nonatomic, strong) NSMutableArray *dotArray;

@property (strong, nonatomic)  LMPopInputPasswordView *popView;
@property (strong, nonatomic) BluetoothDataManage *bluetoothDataManage;

@end

@implementation QueryMowerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = LocalString(@"Robotic Mower");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 20, 20);
    [rightButton setImage:[UIImage imageNamed:@"y_add"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(showAlert) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    _noMowerView = [self noMowerView];
    _mowerTable = [self mowerTable];
    
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!_onlineMowerArray) {
        _onlineMowerArray = [[NSMutableArray alloc] init];
    }
    if (!_offlineMowerArray) {
        _offlineMowerArray = [[NSMutableArray alloc] init];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNode:) name:@"getNode" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBatterDataAndSetButton:) name:@"getMowerData" object:nil];
    [[NetWork shareNetWork] inquireNode];

}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getNode" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getMowerData" object:nil];
}

#pragma mark - lazy load
- (UITableView *)mowerTable{
    if (!_mowerTable) {
        _mowerTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.hidden = YES;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[MowerListCell class] forCellReuseIdentifier:CellIdentifier_Mower];
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
            
            MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(queryNode)];
            // Set title
            [header setTitle:LocalString(@"下拉刷新") forState:MJRefreshStateIdle];
            [header setTitle:LocalString(@"松开刷新") forState:MJRefreshStatePulling];
            [header setTitle:LocalString(@"加载中") forState:MJRefreshStateRefreshing];
            
            // Set font
            header.stateLabel.font = [UIFont systemFontOfSize:15];
            header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
            
            // Set textColor
            header.stateLabel.textColor = [UIColor lightGrayColor];
            header.lastUpdatedTimeLabel.textColor = [UIColor lightGrayColor];
            tableView.mj_header = header;
            tableView;
        });
    }
    return _mowerTable;
}

- (UIScrollView *)noMowerView{
    if (!_noMowerView) {
        _noMowerView = [[UIScrollView alloc] init];
        _noMowerView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        _noMowerView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
        _noMowerView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1];
        [self.view addSubview:_noMowerView];
        
        MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(queryNode)];
        // Set title
        [header setTitle:LocalString(@"下拉刷新") forState:MJRefreshStateIdle];
        [header setTitle:LocalString(@"松开刷新") forState:MJRefreshStatePulling];
        [header setTitle:LocalString(@"加载中") forState:MJRefreshStateRefreshing];
        
        // Set font
        header.stateLabel.font = [UIFont systemFontOfSize:15];
        header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
        
        // Set textColor
        header.stateLabel.textColor = [UIColor lightGrayColor];
        header.lastUpdatedTimeLabel.textColor = [UIColor lightGrayColor];
        _noMowerView.mj_header = header;
        
        UILabel *label = [[UILabel alloc] init];
        label.text = LocalString(@"还没有绑定割草机");
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_noMowerView addSubview:label];
        
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn setTitle:LocalString(@"Add Mower") forState:UIControlStateNormal];
        [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [addBtn setButtonStyleWithColor:[UIColor clearColor] Width:1.0 cornerRadius:buttonHeight * 0.5];
        [addBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        [addBtn addTarget:self action:@selector(showAlert) forControlEvents:UIControlEventTouchUpInside];
        [_noMowerView addSubview:addBtn];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(168.f / WScale, 20.f / HScale));
            make.centerX.equalTo(_noMowerView.mas_centerX);
            make.top.equalTo(_noMowerView.mas_top).offset(334.f / HScale);
        }];
        
        [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(345.f / WScale, 50.f / HScale));
            make.centerX.equalTo(_noMowerView.mas_centerX);
            make.top.equalTo(_noMowerView.mas_top).offset(374.f / HScale);
        }];
    }
    return _noMowerView;
}

#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _onlineMowerArray.count;
            
        case 1:
            return _offlineMowerArray.count;
            //return 1;
            
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return yCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        MowerListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Mower];
        if (cell == nil) {
            cell = [[MowerListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_Mower];
        }
        MowerModel *model = _offlineMowerArray[indexPath.row];
        int name = [model.mowerNodeAddr intValue] % 256;
        cell.deviceLabel.text = [NSString stringWithFormat:@"%02d",name];
        cell.deviceImage.image = [UIImage imageNamed:@"y_offline"];
//        [cell setBatteryHidden];
//        cell.batteryLabel.hidden = YES;
        [cell setBatteryValue:0];
        cell.batteryLabel.text = [NSString stringWithFormat:@"%d%%",0];
        cell.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        MowerListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Mower];
        MowerModel *model = _onlineMowerArray[indexPath.row];
        if (cell == nil) {
            cell = [[MowerListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_Mower];
        }
        
        int name = [model.mowerNodeAddr intValue] % 256;
        cell.deviceLabel.text = [NSString stringWithFormat:@"%02d",name];
        cell.deviceImage.image = [UIImage imageNamed:@"y_online"];
        if (model.batteryValue) {
            [cell setBatteryValue:[model.batteryValue integerValue]];
            cell.batteryLabel.text = [NSString stringWithFormat:@"%@%%",model.batteryValue];
        }else{
            [cell setBatteryValue:0];
            cell.batteryLabel.text = [NSString stringWithFormat:@"%d%%",0];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {

        
    }else if (indexPath.section == 0){
        NetWork *net = [NetWork shareNetWork];
        
        MowerModel *model = _onlineMowerArray[indexPath.row];
        int mowerNodeAddr = [model.mowerNodeAddr intValue];
        net.mowerNodeAddrH = mowerNodeAddr / 256;
        net.mowerNodeAddrL = mowerNodeAddr % 256;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults integerForKey:@"pincode"]) {
            [BluetoothDataManage shareInstance].pincode = (int)[defaults integerForKey:@"pincode"];
        }else{
            NSMutableArray *dataContent = [[NSMutableArray alloc] init];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
            
            [self.bluetoothDataManage setDataType:0x0c];
            [self.bluetoothDataManage setDataContent: dataContent];
            [self.bluetoothDataManage sendBluetoothFrame];
        }
        
        _popView = [[LMPopInputPasswordView alloc]init];
        _popView.frame = CGRectMake((self.view.frame.size.width - 250)*0.5, 50, 250, 150);
        _popView.delegate = self;
        [_popView pop];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, yCellHeight)];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, yCellHeight)];
    headerTitle.font = [UIFont systemFontOfSize:14.f];
    if (section == 0) {
        headerTitle.text = LocalString(@"在线设备");
    }else{
        headerTitle.text = LocalString(@"离线设备");
    }
    [headerView addSubview:headerTitle];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return yCellHeight;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewCellEditingStyleDelete;
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        if (indexPath.section == 0) {
//            MowerModel *model = _onlineMowerArray[indexPath.row];
//            [self showComfirmAlert:model section:indexPath.section];
//        }else if (indexPath.section == 1){
//            MowerModel *model = _offlineMowerArray[indexPath.row];
//            [self showComfirmAlert:model section:indexPath.section];
//        }
//    }
//}

#pragma mark - KVO And Node Action
- (void)getNode:(NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    NSMutableArray *dataArr = dict[@"dataArr"];
    for (int i = 0; i < [dataArr[12] unsignedIntegerValue]; i++) {
        if ([dataArr[16 + i * 4] unsignedIntegerValue] == 0xF3) {
            int mowerNodeAddrH = [dataArr[14 + i * 4] intValue];
            int mowerNodeAddrL = [dataArr[13 + i * 4] intValue];
            NSNumber *mowerNodeAddr = [NSNumber numberWithInt:mowerNodeAddrH * 256 + mowerNodeAddrL];
            
            int isContain = 0;
            for (MowerModel *model in _offlineMowerArray) {
                if ([model.mowerNodeAddr isEqualToNumber:mowerNodeAddr]) {
                    isContain = 1;
                }
            }
            for (MowerModel *model in _onlineMowerArray) {
                if ([model.mowerNodeAddr isEqualToNumber:mowerNodeAddr]) {
                    isContain = 1;
                }
            }
            if (!isContain) {
                MowerModel *model = [[MowerModel alloc] init];
                model.mowerNodeAddr = mowerNodeAddr;
                [_offlineMowerArray addObject:model];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_onlineMowerArray.count || _offlineMowerArray.count) {
            _mowerTable.hidden = NO;
            _noMowerView.hidden = YES;
            [_mowerTable reloadData];
        }else{
            _mowerTable.hidden = YES;
            _noMowerView.hidden = NO;
        }
        if ([_mowerTable.mj_header isRefreshing]) {
            [_mowerTable.mj_header endRefreshing];
        }
        if ([_noMowerView.mj_header isRefreshing]) {
            [_noMowerView.mj_header endRefreshing];
        }
        NetWork *net = [NetWork shareNetWork];
        for (MowerModel *model in _offlineMowerArray) {
            //if (!model.batteryValue) {
                int mowerNodeAddr = [model.mowerNodeAddr intValue];
                int mowerNodeAddrH = mowerNodeAddr / 256;
                int mowerNodeAddrL = mowerNodeAddr % 256;
                net.mowerNodeAddrH = mowerNodeAddrH;
                net.mowerNodeAddrL = mowerNodeAddrL;
                [self inquireBatter];
            //}
        }
        for (MowerModel *model in _onlineMowerArray) {
            //if (!model.batteryValue) {
            int mowerNodeAddr = [model.mowerNodeAddr intValue];
            int mowerNodeAddrH = mowerNodeAddr / 256;
            int mowerNodeAddrL = mowerNodeAddr % 256;
            net.mowerNodeAddrH = mowerNodeAddrH;
            net.mowerNodeAddrL = mowerNodeAddrL;
            [self inquireBatter];
            //}
        }
    });
}

- (void)inquireBatter{
    BluetoothDataManage *bleDM = [BluetoothDataManage shareInstance];
    
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x11]];
    
    [bleDM setDataType:0x00];
    [bleDM setDataContent: dataContent];
    [bleDM sendBluetoothFrame];
}

- (void)getBatterDataAndSetButton:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    
    //电量设置
    NSNumber *batterData = dict[@"batterData"];
    NSNumber *mowerNodeAddr = dict[@"mowerNodeAddr"];
    for (MowerModel *model in _offlineMowerArray) {
        if ([model.mowerNodeAddr isEqualToNumber:mowerNodeAddr]) {
            model.batteryValue = batterData;
            [_onlineMowerArray addObject:model];
            [_offlineMowerArray removeObject:model];
            break;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mowerTable reloadData];
    });
    
}
#pragma mark ---LMPopInputPassViewDelegate
-(void)buttonClickedAtIndex:(NSUInteger)index withText:(NSString *)text
{
    NSLog(@"buttonIndex = %li password=%@",(long)index,text);
    if(index == 1){
        if(text.length == 0){
            NSLog(@"密码长度不正确Incorrect password length");
            [NSObject showHudTipStr:LocalString(@"Incorrect PIN code length")];
        }else if(text.length < 4){
            NSLog(@"密码长度不正确");
            [NSObject showHudTipStr:LocalString(@"Incorrect PIN code length")];
        }else{
            
            if ([text intValue] == [BluetoothDataManage shareInstance].pincode) {
                RDVViewController *rdvView = [[RDVViewController alloc] init];
                rdvView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentViewController:rdvView animated:YES completion:nil];
            }else{
                NSMutableArray *dataContent = [[NSMutableArray alloc] init];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                
                [self.bluetoothDataManage setDataType:0x0c];
                [self.bluetoothDataManage setDataContent: dataContent];
                [self.bluetoothDataManage sendBluetoothFrame];
                
                [NSObject showHudTipStr:LocalString(@"Incorrect PIN code")];
            }
        }
    }
}

//#pragma mark - add delete
//- (void)showAlert{
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加设备" message:@"请选择添加方式" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *sweepAction = [UIAlertAction actionWithTitle:@"扫码添加割草机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
//        QRCodeAddDeviceController *qrVC = [[QRCodeAddDeviceController alloc] init];
//        qrVC.scanBlock = ^(NSString *Mac) {
//            Byte *byte = [NSString UInt8ByHexString:Mac];
//            if (byte[2] != 0xF3) {
//                [NSObject showHudTipStr:LocalString(@"节点地址错误，该页面只能添加割草机")];
//            }else{
//                MowerModel *model = [[MowerModel alloc] init];
//                int mowerNodeAddrH = byte[2];
//                int mowerNodeAddrL = byte[3];
//                NSNumber *mowerNodeAddr = [NSNumber numberWithInt:mowerNodeAddrH * 256 + mowerNodeAddrL];
//                int isContain = 0;
//                for (MowerModel *model1 in _offlineMowerArray) {
//                    if ([model1.mowerNodeAddr isEqualToNumber:mowerNodeAddr]) {
//                        [NSObject showHudTipStr:LocalString(@"该节点已经存在")];
//                        isContain = 1;
//                        break;
//                    }
//                }
//                for (MowerModel *model2 in _onlineMowerArray) {
//                    if ([model2.mowerNodeAddr isEqualToNumber:mowerNodeAddr]) {
//                        [NSObject showHudTipStr:LocalString(@"该节点已经存在")];
//                        isContain = 1;
//                        return;
//                    }
//                }
//                if (!isContain) {
//                    model.mowerNodeAddr = mowerNodeAddr;
//                    [_offlineMowerArray addObject:model];
//                    [_mowerTable reloadData];
//                    [[NetWork shareNetWork].NodeFrame removeAllObjects];
//                    [[NetWork shareNetWork] addNodeWithMac:Mac];
//                }
//            }
//        };
//        [self.navigationController pushViewController:qrVC animated:YES];
//    }];
//    alertController.view.tintColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1];
//    UIAlertAction *inputAction = [UIAlertAction actionWithTitle:@"手动输入添加割草机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
//        [self showView];
//    }];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//
//    [alertController addAction:sweepAction];
//    [alertController addAction:inputAction];
//    [alertController addAction:cancelAction];
//
//    [self presentViewController:alertController animated:YES completion:nil];
//}
//
//- (void)showView{
//    AlertView *alertView = [[AlertView alloc] initWithFrame:CGRectMake(0,  0, ScreenWidth, ScreenHeight)];
//    [alertView updateContentViewWithTitle:@"添加割草机" fieldPlaceholder:@"大写MAC地址" deviceHolder:@"设备码"];
//    __weak AlertView *alert = alertView;
//    alertView.actionBlock = ^(NSString *Mac) {
//        Byte *byte = [NSString UInt8ByHexString:Mac];
//        if (byte[2] != 0xF3) {
//            [NSObject showHudTipStr:LocalString(@"节点地址错误，该页面只能添加割草机")];
//        }else{
//            MowerModel *model = [[MowerModel alloc] init];
//            int mowerNodeAddrH = byte[2];
//            int mowerNodeAddrL = byte[3];
//            NSNumber *mowerNodeAddr = [NSNumber numberWithInt:mowerNodeAddrH * 256 + mowerNodeAddrL];
//            int isContain = 0;
//            for (MowerModel *model1 in _offlineMowerArray) {
//                if ([model1.mowerNodeAddr isEqualToNumber:mowerNodeAddr]) {
//                    [NSObject showHudTipStr:LocalString(@"该节点已经存在")];
//                    isContain = 1;
//                    break;
//                }
//            }
//            for (MowerModel *model2 in _onlineMowerArray) {
//                if ([model2.mowerNodeAddr isEqualToNumber:mowerNodeAddr]) {
//                    [NSObject showHudTipStr:LocalString(@"该节点已经存在")];
//                    isContain = 1;
//                    break;
//                }
//            }
//            if (!isContain) {
//                model.mowerNodeAddr = mowerNodeAddr;
//                [_offlineMowerArray addObject:model];
//                [_mowerTable reloadData];
//                [[NetWork shareNetWork].NodeFrame removeAllObjects];
//                [[NetWork shareNetWork] addNodeWithMac:Mac];
//            }
//            [alert removeFromSuperview];
//        }
//    };
//    [self.navigationController.view addSubview:alertView];
//}

//- (void)showComfirmAlert:(MowerModel *)model section:(NSInteger)section{
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除割草机" message:@"确定要进行该操作吗？" preferredStyle:UIAlertControllerStyleAlert];
//    alertController.view.tintColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1];
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
//        if (section == 0) {
//            [_onlineMowerArray removeObject:model];
//        }else if (section == 1){
//            [_offlineMowerArray removeObject:model];
//        }
//
//        [_mowerTable reloadData];
//
//        int mowerNodeAddr = [model.mowerNodeAddr intValue];
//        int mowerNodeAddrH = mowerNodeAddr / 256;
//        int mowerNodeAddrL = mowerNodeAddr % 256;
//
//        [[NetWork shareNetWork] deleteNodeWithMac:mowerNodeAddrH low:mowerNodeAddrL];
//        [[NetWork shareNetWork].NodeFrame removeAllObjects];
//    }];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//
//    [alertController addAction:okAction];
//    [alertController addAction:cancelAction];
//
//    [self presentViewController:alertController animated:YES completion:nil];
//
//}
//
//- (void)queryNode{
//    [[NetWork shareNetWork] inquireNode];
//}

@end
