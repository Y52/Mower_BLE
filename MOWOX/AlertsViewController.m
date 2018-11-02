//
//  AlertsViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/20.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "AlertsViewController.h"
#import "ViewAlertsCell.h"
#import "BluetoothDataManage.h"
#import "Masonry.h"

@interface AlertsViewController ()
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;
@property (nonatomic, strong) UITableView *myTableView1;
@property (nonatomic, strong) UITableView *myTableView2;
@property (nonatomic) NSNumber *alertsCount;
@property (nonatomic,strong) NSMutableArray *alertsDateArray;
@property (nonatomic,strong) NSMutableArray *alertsTypeArray;

///@brife ui和功能各模块
@property (weak, nonatomic) IBOutlet UIImageView *parkImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *batteryImage;
@property (weak, nonatomic) IBOutlet UIButton *signalButton;
@property (weak, nonatomic) IBOutlet UIImageView *lineImage;
@property (weak, nonatomic) IBOutlet UIButton *backViewControllerButton;

@end

@implementation AlertsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *backImage = [UIImage imageNamed:@"backgroundnew"];
    self.view.layer.contents = (id)backImage.CGImage;
    [self viewLayoutSet];
    
    _bluetoothDataManage = [BluetoothDataManage shareInstance];
    _alertsCount = [[NSNumber alloc] initWithInt:0];
    _alertsDateArray = [NSMutableArray array];
    _alertsTypeArray = [NSMutableArray array];
    
    
    
    _myTableView1 = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(15, 160, ScreenWidth - 15 * 2, 80) style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[ViewAlertsCell class] forCellReuseIdentifier:kCellIdentifier_ViewAlerts];
        [self.view addSubview:tableView];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    _myTableView2 = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(15, 300, ScreenWidth - 15 * 2, 240) style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[ViewAlertsCell class] forCellReuseIdentifier:kCellIdentifier_ViewAlerts];
        [self.view addSubview:tableView];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveAlertsContent:) name:@"recieveAlertsContent" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveAlertsContent" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _myTableView1.delegate = nil;
    _myTableView1.dataSource = nil;
    _myTableView2.delegate = nil;
    _myTableView2.dataSource = nil;
}

- (void)viewLayoutSet{
    [self.parkImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.top.equalTo(self.view.mas_top).offset(28);
        make.left.equalTo(self.view.mas_left).offset(ScreenWidth * 0.112);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(128, 21));
        make.left.equalTo(self.parkImage.mas_right).offset(8);
        make.top.equalTo(self.view.mas_top).offset(28);
    }];
    [self.batteryImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(39, 20));
        make.left.equalTo(self.titleLabel.mas_right).offset(ScreenWidth * 0.053);
        make.top.equalTo(self.view.mas_top).offset(28);
    }];
    [self.batteryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(42, 21));
        make.left.equalTo(self.batteryImage.mas_left);
        make.top.equalTo(self.batteryImage.mas_bottom).offset(-3);
    }];
    [self.signalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.top.equalTo(self.view.mas_top).offset(28);
        make.right.equalTo(self.view.mas_right).offset(- (ScreenWidth - 239 -ScreenWidth *  0.165) / 2);
    }];
    [self.lineImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(6);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
        make.top.equalTo(self.parkImage.mas_bottom).offset(7);
    }];
    [self.backViewControllerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(45, 45));
        make.right.equalTo(self.view.mas_right).offset(- ScreenWidth * 0.0225);
        make.top.equalTo(self.lineImage.mas_bottom).offset(ScreenWidth * 0.037);
    }];
}

#pragma mark - get alert contents
- (void)getAlertContent
{
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:[_alertsCount integerValue]]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x07];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}

- (void)recieveAlertsContent:(NSNotification *)nsnotification
{
    NSDictionary *dict = [nsnotification userInfo];
    [_alertsTypeArray addObject:dict[@"alertsType"]];
    [_alertsDateArray addObject:dict[@"dateLabel"]];
}

#pragma tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (self.alertsDateArray != nil && self.alertsTypeArray != nil && self.alertsTypeArray.count == self.alertsDateArray.count && self.alertsDateArray.count > 0){
        if (tableView == _myTableView2) {
            row = self.alertsDateArray.count;
        }else if (tableView == _myTableView1){
            row = 1;
        }
    }
    
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ViewAlertsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ViewAlerts forIndexPath:indexPath];
    if (tableView == _myTableView2) {
        cell.timeLabel.text = self.alertsDateArray[indexPath.row];
        switch ([self.alertsTypeArray[indexPath.row] intValue]) {
            case 1:
                cell.alertLabel.text = @"";
                break;
                
            default:
                break;
        }
    }else if (tableView == _myTableView1){
        cell.timeLabel.text = self.alertsTypeArray[self.alertsTypeArray.count - 1];
        cell.alertLabel.text = @"";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
