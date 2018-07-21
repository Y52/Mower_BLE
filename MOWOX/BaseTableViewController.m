//
//  BaseTableViewController.m
//  MOWOX
//
//  Created by Mac on 2017/10/30.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.automaticallyAdjustsScrollViewInsets = YES;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
#if RobotMower
    self.tableView.backgroundColor = [UIColor colorWithRed:0.15 green:0.16 blue:0.16 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
#elif MOWOXROBOT
    UIImage *backImage = [UIImage imageNamed:@"App_BG_3"];
    self.view.layer.contents = (id)backImage.CGImage;
    self.tableView.tableFooterView = [[UIView alloc] init];
#endif
    //self.view.backgroundColor = [UIColor clearColor];
    //UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    //[window insertSubview:imageView atIndex:0];
    //[self.view insertSubview:imageView atIndex:0];
    //[self.tableView.backgroundView sendSubviewToBack:imageView];
    
    //[self.tableView.backgroundView addSubview:imageView];
    //[self.tableView.backgroundView sendSubviewToBack:imageView];
    //CGPoint myCGPoint;
    //myCGPoint.x =0;
    //myCGPoint.y = -64.0;
    //self.tableView.contentOffset = myCGPoint;
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
