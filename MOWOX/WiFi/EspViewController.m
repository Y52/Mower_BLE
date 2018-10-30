//
//  EspViewController.m
//  MOWOX
//
//  Created by 杭州轨物科技有限公司 on 2018/8/3.
//  Copyright © 2018年 yusz. All rights reserved.
//

//
//  EspViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "EspViewController.h"
#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"
#import "ESPAES.h"


#import "SSIDTableViewCell.h"
#import "PasswordTableViewCell.h"

#import <SVProgressHUD.h>

#import <SystemConfiguration/CaptiveNetwork.h>

NSString *const CellIdentifier_ssid = @"CellID_ssid";
NSString *const CellNibName_ssid = @"SSIDTableViewCell";
NSString *const CellIdentifier_password = @"CellID_password";
NSString *const CellNibName_password = @"PasswordTableViewCell";


#define HEIGHT_TEXT_FIELD 44

@interface EspTouchDelegateImpl : NSObject<ESPTouchDelegate>

@end

@implementation EspTouchDelegateImpl

-(void) dismissAlert:(UIAlertView *)alertView
{
    [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
}

-(void) showAlertWithResult: (ESPTouchResult *) result
{
    NSString *title = nil;
    NSString *message = [NSString stringWithFormat:@"%@ is connected to the wifi" , result.bssid];
    NSTimeInterval dismissSeconds = 3.5;
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    //UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertView show];
    [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:dismissSeconds];
}

-(void) onEsptouchResultAddedWithResult: (ESPTouchResult *) result
{
    NSLog(@"EspTouchDelegateImpl onEsptouchResultAddedWithResult bssid: %@", result.bssid);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithResult:result];
    });
}

@end

@interface EspViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) UITableView *ssidPasswordTable;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) NSString *apPwd;

@property (nonatomic, strong) NSCondition *condition;

@property (nonatomic, strong) EspTouchDelegateImpl *espTouchDelegate;
@property (atomic, strong) ESPTouchTask *esptouchTask;

@end

@implementation EspViewController
static float progressValue = 0.0;
static BOOL isSucc = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LocalString(@"Add Router");
    
    [self setSsidPasswordTable];
    _nextBtn = [self nextBtn];
    [self uiMasonry];
    
    self.condition = [[NSCondition alloc] init];
    self.espTouchDelegate = [[EspTouchDelegateImpl alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification)
                                                 name:SVProgressHUDDidTouchDownInsideNotification
                                               object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SVProgressHUDDidTouchDownInsideNotification object:nil];
}

#pragma mark - 懒加载
- (UIButton *)nextBtn{
    if (!_nextBtn) {
        self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextBtn setTitle:LocalString(@"Next") forState:UIControlStateNormal];
        [_nextBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [_nextBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        _nextBtn.enabled = NO;
        [_nextBtn setButtonStyle1];
        [_nextBtn addTarget:self action:@selector(startEsptouchConnect) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_nextBtn];
    }
    return _nextBtn;
}

#pragma mark - masonry
- (void)uiMasonry{
    [_ssidPasswordTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, HEIGHT_TEXT_FIELD * 3));
        make.centerY.equalTo(self.view.mas_centerY);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(345.f / WScale, 50.f / HScale));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_ssidPasswordTable.mas_bottom).offset(20 / HScale);
    }];
}

#pragma mark - action


#pragma mark - tableview
- (void)setSsidPasswordTable{
    _ssidPasswordTable = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 300, ScreenWidth, HEIGHT_TEXT_FIELD * 3) style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //[tableView registerClass:[WorktimeCell class] forCellReuseIdentifier:kCellIdentifier_WorkTime];
        [tableView registerNib:[UINib nibWithNibName:CellNibName_ssid bundle:nil] forCellReuseIdentifier:CellIdentifier_ssid];
        [tableView registerNib:[UINib nibWithNibName:CellNibName_password bundle:nil] forCellReuseIdentifier:CellIdentifier_password];
        [self.view addSubview:tableView];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.scrollEnabled = NO;
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([tableView respondsToSelector:@selector(setLayoutMargins:)])  {
            [tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        
        tableView;
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return yCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SSIDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ssid];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellNibName_ssid owner:self options:nil] lastObject];
        }
        if (_ssid) {
            cell.ssidLabel.text = _ssid;
            cell.ssidLabel.tintColor = [UIColor blackColor];
        }
        return cell;
    }else{
        PasswordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_password];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellNibName_password owner:self options:nil] lastObject];
        }
        [cell.passwordTF addTarget:self action:@selector(passwordTFTextChange:) forControlEvents:UIControlEventEditingChanged];
        cell.passwordTF.delegate = self;
        return cell;
    }
}

#pragma mark - passwordTF value change
- (void)passwordTFTextChange:(UITextField *)sender{
    _apPwd = sender.text;
    if (![sender.text isEqualToString:@""] && _ssid != nil) {
        [_nextBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        _nextBtn.enabled = YES;
    }else{
        [_nextBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        _nextBtn.enabled = NO;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (BOOL)textFieldShouldReturn:(UITextField*) textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - start Esptouch
- (void)startEsptouchConnect
{
    [SVProgressHUD showProgress:progressValue status:@"正在配网中"];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [self increaseProgress];
    
    NSLog(@"ESPViewController do confirm action...");
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSLog(@"ESPViewController do the execute work...");
        // execute the task
        NSArray *esptouchResultArray = [self executeForResults];
        // show the result to the user in UI Main Thread
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([SVProgressHUD isVisible]) {
                [SVProgressHUD dismiss];
                progressValue = 1.f;
            }
            
            ESPTouchResult *firstResult = [esptouchResultArray objectAtIndex:0];
            
            // check whether the task is cancelled and no results received
            if (!firstResult.isCancelled)
            {
                NSMutableString *mutableStr = [[NSMutableString alloc]init];
                NSUInteger count = 0;
                // max results to be displayed, if it is more than maxDisplayCount,
                // just show the count of redundant ones
                const int maxDisplayCount = 5;
                if ([firstResult isSuc])
                {
                    isSucc = YES;
                    /**多个设备同时esptouch连接
                     for (int i = 0; i < [esptouchResultArray count]; ++i)
                     {
                     ESPTouchResult *resultInArray = [esptouchResultArray objectAtIndex:i];
                     [mutableStr appendString:[resultInArray description]];
                     [mutableStr appendString:@"\n"];
                     count++;
                     if (count >= maxDisplayCount)
                     {
                     break;
                     }
                     }
                     
                     if (count < [esptouchResultArray count])
                     {
                     [mutableStr appendString:[NSString stringWithFormat:@"\nthere's %lu more result(s) without showing\n",(unsigned long)([esptouchResultArray count] - count)]];
                     }
                     **/
                    //[[[UIAlertView alloc]initWithTitle:@"Execute Result" message:mutableStr delegate:nil cancelButtonTitle:@"I know" otherButtonTitles:nil]show];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalString(@"Configue Result") message:LocalString(@"SUCCESSFUL!") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LocalString(@"I know") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
                        NSLog(@"action = %@",action);
                    }];
                    [alert addAction:cancelAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
                else
                {
                    //[[[UIAlertView alloc]initWithTitle:@"Execute Result" message:@"Esptouch fail" delegate:nil cancelButtonTitle:@"I know" otherButtonTitles:nil]show];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalString(@"Configue Result") message:LocalString(@"FAILED!") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LocalString(@"I know") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        NSLog(@"action = %@",action);
                    }];
                    [alert addAction:cancelAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
            
        });
    });
    
    
    //    else
    //    {
    //        [self.spinner stopAnimating];
    //        NSLog(@"ESPViewController do cancel action...");
    //        [self cancel];
    //    }
}

#pragma mark - the example of how to use executeForResults
- (NSArray *) executeForResults
{
    [self.condition lock];
    int taskCount = 1;//具体用途待测试
    BOOL useAES = NO;
    if (useAES) {
        NSString *secretKey = @"1234567890123456"; // TODO modify your own key
        ESPAES *aes = [[ESPAES alloc] initWithKey:secretKey];
        self.esptouchTask = [[ESPTouchTask alloc]initWithApSsid:_ssid andApBssid:_bssid andApPwd:_apPwd andAES:aes];
    } else {
        self.esptouchTask = [[ESPTouchTask alloc]initWithApSsid:_ssid andApBssid:_bssid andApPwd:_apPwd];
        NSLog(@"%@",_ssid);
        NSLog(@"%@",_bssid);
        NSLog(@"%@",_apPwd);
    }
    
    // set delegate
    [self.esptouchTask setEsptouchDelegate:self.espTouchDelegate];
    [self.condition unlock];
    NSArray * esptouchResults = [self.esptouchTask executeForResults:taskCount];
    NSLog(@"ESPViewController executeForResult() result is: %@",esptouchResults);
    return esptouchResults;
}

#pragma mark - the example of how to cancel the executing task
- (void) cancel
{
    [self.condition lock];
    if (self.esptouchTask != nil)
    {
        [self.esptouchTask interrupt];
    }
    [self.condition unlock];
}

- (void)increaseProgress{
    progressValue += 0.01;
    if (!isSucc) {
        if (progressValue >= 1.f) {
            if ([SVProgressHUD isVisible]) {
                [SVProgressHUD dismiss];
            }
            
            [self cancel];
            progressValue = 0.f;
        }else{
            [SVProgressHUD showProgress:progressValue status:LocalString(@"Distribution network")];
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC));
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [self increaseProgress];
            });
        }
    }else{
        progressValue = 0.f;
        isSucc = 0;
    }
}

- (void)handleNotification{
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    progressValue = 1.f;
}
@end
