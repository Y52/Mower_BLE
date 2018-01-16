//
//  RDVViewController.m
//  MOWOX
//
//  Created by Mac on 2017/11/25.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "RDVViewController.h"
#import "RDVTabBarItem.h"
#import "RDVTabBarController.h"
#import "MainViewController.h"
#import "SettingViewController.h"
#import "InformationViewController.h"

@interface RDVViewController ()<RDVTabBarControllerDelegate>
{
    NSInteger selectedTabBarItemTag;
    UIViewController *currentController;
}

@end

@implementation RDVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MainViewController *mainView = [[MainViewController alloc] init];
    UINavigationController *NAV2 = [[UINavigationController alloc] initWithRootViewController:mainView];
    
    SettingViewController *setView = [[SettingViewController alloc] init];
    UINavigationController *NAV3 = [[UINavigationController alloc] initWithRootViewController:setView];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *infoView = [storyboard instantiateViewControllerWithIdentifier:@"InformationViewController"];
    UINavigationController *NAV1 = [[UINavigationController alloc] initWithRootViewController:infoView];
    
    [self setViewControllers:@[NAV1,NAV2,NAV3]];
    
    [self customizeTabBarForController];
    self.selectedIndex = 1;
    self.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customizeTabBarForController{
    NSArray *tabBarItemImages = @[@"A1", @"A2", @"A3"];
    NSArray *tabBarItemTitles = @[LocalString(@"Information"),LocalString(@"Mower status"),LocalString(@"Setting")];
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        item.tag = 1000 + index;
        item.titlePositionAdjustment = UIOffsetMake(0, 2);
        [item setTitle:[tabBarItemTitles objectAtIndex:index]];
        UIImage *selectedimage = [UIImage imageNamed:[tabBarItemImages objectAtIndex:index]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:selectedimage];
        index++;
    }
}

- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    /*if (selectedTabBarItemTag == viewController.rdv_tabBarItem.tag) {
        return NO;
    }else{
        selectedTabBarItemTag = viewController.rdv_tabBarItem.tag;
        return YES;
    }*/
    return YES;
}

- (void)tabBarController:(RDVTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        
        [(UINavigationController *)viewController popToRootViewControllerAnimated:YES];
        
    }
}


@end
