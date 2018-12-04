//
//  WorkTimeSettingViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/6.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "WorkTimeSettingViewController.h"
#import "BluetoothDataManage.h"
#import "AppDelegate.h"
#import "WorktimeCell.h"


@interface WorkTimeSettingViewController () <UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>

///@brife 帧数据控制单例
@property (strong,nonatomic) BluetoothDataManage *bluetoothDataManage;
@property (nonatomic, strong) UITableView *myTableView;

@property (strong, nonatomic)  UIPickerView *workDatePickview;
@property (strong, nonatomic)  UIButton *okButton;

///@brife 工作时间设置
@property (nonatomic, strong) NSMutableArray  *dayArray;
@property (nonatomic, strong) NSMutableArray  *startTimeArray;
@property (nonatomic, strong) NSMutableArray  *workingHoursArray;

@property (nonatomic, strong) NSMutableArray  *selectrowArray;

@end

@implementation WorkTimeSettingViewController
{
    UIToolbar *inputAccessoryView;
    NSIndexPath *selectIndexPath;
    UITextField *selectTimeTextField;
    UITextField *selectHoursTextField;
}

static CGFloat cellHeight = 45.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    self.navigationItem.title = LocalString(@"Working time setting");
    
    self.bluetoothDataManage = [BluetoothDataManage shareInstance];
    
    [self viewLayoutSet];
    [self inquireWorktimeSetting];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveWorkingTime:) name:@"recieveWorkingTime1" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveWorkingTime:) name:@"recieveWorkingTime2" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveWorkingTime1" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recieveWorkingTime2" object:nil];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:NO];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewLayoutSet{
    UIImage *image = [UIImage imageNamed:@"返回1"];
    [self addLeftBarButtonWithImage:image action:@selector(backAction)];
    
    if (!_workDatePickview) {
        _workDatePickview = [[UIPickerView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 216, ScreenWidth, 216)];
        //_workDatePickview = [[UIPickerView alloc] initWithFrame:CGRectMake(0, ScreenHeight * 0.76, ScreenWidth, ScreenHeight * 0.24)];
        //设置工作时间的PickerView
        self.startTimeArray = [NSMutableArray arrayWithArray:@[LocalString(@"AM 0:00;"),LocalString(@"AM 1:00;"),LocalString(@"AM 2:00;"),LocalString(@"AM 3:00;"),LocalString(@"AM 4:00;"),LocalString(@"AM 5:00;"),LocalString(@"AM 6:00;"),LocalString(@"AM 7:00;"),LocalString(@"AM 8:00;"),LocalString(@"AM 9:00;"),LocalString(@"AM 10:00;"),LocalString(@"AM 11:00;"),LocalString(@"PM 0:00;"),LocalString(@"PM 1:00;"),LocalString(@"PM 2:00;"),LocalString(@"PM 3:00;"),LocalString(@"PM 4:00;"),LocalString(@"PM 5:00;"),LocalString(@"PM 6:00;"),LocalString(@"PM 7:00;"),LocalString(@"PM 8:00;"),LocalString(@"PM 9:00;"),LocalString(@"PM 10:00;"),LocalString(@"PM 11:00;")]];
        self.workingHoursArray = [NSMutableArray arrayWithArray:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",]];
        self.selectrowArray = [NSMutableArray array];
        for (int i = 0; i < 20; i++) {
            [_selectrowArray addObject:[NSNumber numberWithInt:0]];
        }
        self.workDatePickview.dataSource = self;
        self.workDatePickview.delegate = self;
        //[self.workDatePickview selectRow:3 inComponent:0 animated:YES];
        //[self.workDatePickview selectRow:7 inComponent:1 animated:YES];
        //_workDatePickview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ScreenHeight * 0.05 + 44, ScreenWidth, cellHeight * 7) style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[WorktimeCell class] forCellReuseIdentifier:kCellIdentifier_WorkTime];
        [self.view addSubview:tableView];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.scrollEnabled = NO;
        tableView;
    });
    
    self.dayArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"Mon:", nil),NSLocalizedString(@"Tue:", nil),NSLocalizedString(@"Wed:", nil),NSLocalizedString(@"Thu:", nil),NSLocalizedString(@"Fri:", nil),NSLocalizedString(@"Sat:", nil),NSLocalizedString(@"Sun:", nil)]];
    
    self.okButton = [UIButton buttonWithTitle:LocalString(@"OK") titleColor:[UIColor blackColor]];
    [_okButton setButtonStyle1];
    [self.okButton addTarget:self action:@selector(setMowerTime) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_okButton];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, cellHeight * 7));
            make.top.equalTo(self.view.mas_top).offset(44 + ScreenHeight * 0.05 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, cellHeight * 7));
            make.top.equalTo(self.view.mas_top).offset(44 + ScreenHeight * 0.01 + 64);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }

    
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth * 0.6, ScreenHeight * 0.066));
        make.top.equalTo(self.myTableView.mas_bottom).offset(ScreenHeight * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

#pragma tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 7;
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WorktimeCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_WorkTime forIndexPath:indexPath];
    cell.contentView.userInteractionEnabled = YES;
    cell.weekLabel.text = _dayArray[indexPath.row];
    cell.timeTF.delegate = self;
    cell.hoursTF.delegate = self;
    cell.timeTF.inputView = _workDatePickview;
    cell.hoursTF.inputView = _workDatePickview;
    if ([_selectrowArray[indexPath.row * 2] intValue] <= 24) {
        cell.timeTF.text = [_startTimeArray objectAtIndex:[_selectrowArray[indexPath.row * 2] intValue]];
    }
    if ([_selectrowArray[indexPath.row * 2 + 1] intValue] <= 25) {
        cell.hoursTF.text = [NSString stringWithFormat:@"%@ %@",[_workingHoursArray objectAtIndex:[_selectrowArray[indexPath.row * 2 + 1] intValue]],LocalString(@"Hours")];
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UIPickerViewDataSource

// 返回多少列

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component __TVOS_PROHIBITED {

    return 40;
}

/*- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if(component == 0)
        return ScreenWidth / 3 - 40;
    else if (component == 1)
        return ScreenWidth / 3 + 20;
    return ScreenWidth / 3 +20;
}*/

// 返回多少行
- (NSInteger)pickerView:(UIPickerView *)pickerView  numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0){
        return self.startTimeArray.count;
    }else{
        return self.workingHoursArray.count;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        selectTimeTextField.text = _startTimeArray[row];
        [_selectrowArray replaceObjectAtIndex:selectIndexPath.row * 2 withObject:[NSNumber numberWithLong:row]];
    }else if (component == 1)
    {
        selectHoursTextField.text = [NSString stringWithFormat:@"%@ %@",_workingHoursArray[row],LocalString(@"Hours")];
        [_selectrowArray replaceObjectAtIndex:selectIndexPath.row * 2 + 1 withObject:[NSNumber numberWithLong:row]];
    }
}

- (UIView *)inputAccessoryView{
    if (!inputAccessoryView) {
        inputAccessoryView = [[UIToolbar alloc] init];
        inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
        inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [inputAccessoryView sizeToFit];
        CGRect frame = inputAccessoryView.frame;
        frame.size.height = 30.0f;
        inputAccessoryView.frame = frame;
        
        UIBarButtonItem * doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        [doneBtn setTintColor:[UIColor grayColor]];
        
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [inputAccessoryView setItems:array];
    }
    return inputAccessoryView;
}

- (void)done:(id)sender {
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"done" object:nil userInfo:nil];
    [selectTimeTextField resignFirstResponder];
    [selectHoursTextField resignFirstResponder];
}

#pragma mark - UIPickerViewDelegate

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (component == 0) {
        return self.startTimeArray[row];
    }else{
        return [NSString stringWithFormat:@"%@ %@",self.workingHoursArray[row],LocalString(@"Hours")];
    }
}


#pragma mark - textFiled delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    selectIndexPath = [self.myTableView indexPathForCell:(UITableViewCell *)[[textField superview] superview]];
    selectTimeTextField = [_myTableView cellForRowAtIndexPath:selectIndexPath].contentView.subviews[1];
    selectHoursTextField = [_myTableView cellForRowAtIndexPath:selectIndexPath].contentView.subviews[2];
    selectTimeTextField.textColor = [UIColor blueColor];
    selectHoursTextField.textColor = [UIColor blueColor];
    [_workDatePickview selectRow:[_selectrowArray[selectIndexPath.row * 2] intValue] inComponent:0 animated:YES];
    [_workDatePickview selectRow:[_selectrowArray[selectIndexPath.row * 2 + 1] intValue] inComponent:1 animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    selectTimeTextField.textColor = [UIColor blackColor];
    selectHoursTextField.textColor = [UIColor blackColor];
    [selectTimeTextField resignFirstResponder];
    [selectHoursTextField resignFirstResponder];
}

#pragma mark - resign keyboard control

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"done" object:nil userInfo:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField*) textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - inquire WorkingtimeSetting

- (void)inquireWorktimeSetting{
    
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    [dataContent addObject:[NSNumber numberWithUnsignedInteger:0x00]];
    
    [self.bluetoothDataManage setDataType:0x14];
    [self.bluetoothDataManage setDataContent: dataContent];
    [self.bluetoothDataManage sendBluetoothFrame];
}

- (void)recieveWorkingTime:(NSNotification *)notification{
    if ([notification.name isEqualToString:@"recieveWorkingTime1"]) {
        NSDictionary *dict = [notification userInfo];
        NSNumber *monStart = 0;
        NSNumber *monWork = 0;
        NSNumber *tueStart = 0;
        NSNumber *tueWork = 0;
        NSNumber *wedStart = 0;
        NSNumber *wedWork = 0;
        NSNumber *thuStart = 0;
        NSNumber *thuWork = 0;
        if (dict[@"monStart"]) {
            monStart = dict[@"monStart"];
        }
        if (dict[@"monWork"]) {
            monWork = dict[@"monWork"];
        }
        if (dict[@"tueStart"]) {
            tueStart = dict[@"tueStart"];
        }
        if (dict[@"tueWork"]) {
            tueWork = dict[@"tueWork"];
        }
        if (dict[@"wedStart"]) {
            wedStart = dict[@"wedStart"];
        }
        if (dict[@"wedWork"]) {
            wedWork = dict[@"wedWork"];
        }
        if (dict[@"thuStart"]) {
            thuStart = dict[@"thuStart"];
        }
        if (dict[@"thuWork"]) {
            thuWork = dict[@"thuWork"];
        }
        [_selectrowArray insertObject:monStart atIndex:0];
        [_selectrowArray insertObject:monWork atIndex:1];
        [_selectrowArray insertObject:tueStart atIndex:2];
        [_selectrowArray insertObject:tueWork atIndex:3];
        [_selectrowArray insertObject:wedStart atIndex:4];
        [_selectrowArray insertObject:wedWork atIndex:5];
        [_selectrowArray insertObject:thuStart atIndex:6];
        [_selectrowArray insertObject:thuWork atIndex:7];
    }else{
        NSDictionary *dict = [notification userInfo];
        NSNumber *friStart = 0;
        NSNumber *friWork = 0;
        NSNumber *satStart = 0;
        NSNumber *satWork = 0;
        NSNumber *sunStart = 0;
        NSNumber *sunWork = 0;
        if (dict[@"friStart"]) {
            friStart = dict[@"friStart"];
        }
        if (dict[@"friWork"]) {
            friWork = dict[@"friWork"];
        }
        if (dict[@"satStart"]) {
            satStart = dict[@"satStart"];
        }
        if (dict[@"satWork"]) {
            satWork = dict[@"satWork"];
        }
        if (dict[@"sunStart"]) {
            sunStart = dict[@"sunStart"];
        }
        if (dict[@"sunWork"]) {
            sunWork = dict[@"sunWork"];
        }
        [_selectrowArray insertObject:friStart atIndex:8];
        [_selectrowArray insertObject:friWork atIndex:9];
        [_selectrowArray insertObject:satStart atIndex:10];
        [_selectrowArray insertObject:satWork atIndex:11];
        [_selectrowArray insertObject:sunStart atIndex:12];
        [_selectrowArray insertObject:sunWork atIndex:13];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_myTableView reloadData];
    });
    
}

#pragma mark - set mower work time
- (void)setMowerTime
{
    //NSLog(@"%@",_selectrowArray);
    NSMutableArray *dataContent1 = [NSMutableArray array];
    NSMutableArray *dataContent2 = [NSMutableArray array];
    if (dataContent1.count != 8 && dataContent2.count != 8) {
        for (int i = 0; i < 8; i++) {
            [dataContent1 addObject:_selectrowArray[i]];
            [dataContent2 addObject:_selectrowArray[8 + i]];
        }
    }
    if (([_selectrowArray[0] intValue] + [_selectrowArray[1] intValue]) > 24){
        [NSObject showHudTipStr:LocalString(@"Monday's time set wrong")];
    }else if (([_selectrowArray[2] intValue] + [_selectrowArray[3] intValue]) > 24){
        [NSObject showHudTipStr:LocalString(@"Tuesday's time set wrong")];
    }else if (([_selectrowArray[4] intValue] + [_selectrowArray[5] intValue]) > 24){
        [NSObject showHudTipStr:LocalString(@"Wednesday's time set wrong")];
    }else if (([_selectrowArray[6] intValue] + [_selectrowArray[7] intValue]) > 24){
        [NSObject showHudTipStr:LocalString(@"Thursday's time set wrong")];
        NSLog(@"%d",[_selectrowArray[8] intValue]);
        NSLog(@"%d",[_selectrowArray[9] intValue]);
    }else if (([_selectrowArray[8] intValue] + [_selectrowArray[9] intValue]) > 24){
        [NSObject showHudTipStr:LocalString(@"Friday's time set wrong")];
    }else if (([_selectrowArray[10] intValue] + [_selectrowArray[11] intValue]) > 24){
        [NSObject showHudTipStr:LocalString(@"Saturday's time set wrong")];
    }else if (([_selectrowArray[12] intValue] + [_selectrowArray[13] intValue]) > 24){
        [NSObject showHudTipStr:LocalString(@"Sunday's time set wrong")];
    }else{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.bluetoothDataManage setDataType:0x04];
            [self.bluetoothDataManage setDataContent: dataContent1];
            [self.bluetoothDataManage sendBluetoothFrame];
            usleep(130 * 1000);
            [self.bluetoothDataManage setDataType:0x05];
            [self.bluetoothDataManage setDataContent: dataContent2];
            [self.bluetoothDataManage sendBluetoothFrame];
        });
    }
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
