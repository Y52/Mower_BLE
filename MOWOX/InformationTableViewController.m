//
//  InformationTableViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/6.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "InformationTableViewController.h"

@interface InformationTableViewController ()

@end

@implementation InformationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width, 22)];
    label.font = [UIFont fontWithName:@"Helvetica" size:20];
    // you can set the alignment if you want, default value is UITextAlignmentLeft
    label.textColor = [UIColor blackColor];
    // set the label background colour to be transparent
    label.backgroundColor = [UIColor clearColor];
    
    // add label to the header
    
    
    if (section == 0) {
        label.text = NSLocalizedString(@"About", nil);
        [headerView addSubview:label];
    }else if (section == 1){
        label.text = NSLocalizedString(@"Contact Us", nil);
        [headerView addSubview:label];
    }
    
    
    
    return headerView;
}
@end
