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
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *infoView = [storyboard instantiateViewControllerWithIdentifier:@"InformationViewController"];
    InformationViewController *infoView = [[InformationViewController alloc] init];
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
    NSArray *tabBarItemImages = @[@"A1_50", @"A2_50", @"A3_50"];
    NSArray *tabBarItemSelectImages = @[@"B1_50", @"B2_50", @"B3_50"];
    NSArray *tabBarItemTitles = @[LocalString(@"Information"),LocalString(@"Robot status"),LocalString(@"Setting")];
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        item.tag = 1000 + index;
        item.titlePositionAdjustment = UIOffsetMake(0, 2);
        [item setTitle:[tabBarItemTitles objectAtIndex:index]];
        UIImage *selectedimage = [UIImage imageNamed:[tabBarItemSelectImages objectAtIndex:index]];
        UIImage *unselectedimage = [UIImage imageNamed:[tabBarItemImages objectAtIndex:index]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        index++;
    }
    if (ScreenHeight < 700) {
        [self.tabBar setHeight:49.0 + kSafeArea_Bottom];
    }else{
        [self.tabBar setHeight:60.0 + kSafeArea_Bottom];
    }
    [self.tabBar setContentEdgeInsets:UIEdgeInsetsMake(kSafeArea_Bottom / 2, 0, 0, 0)];
    self.tabBar.translucent = YES;
    //self.tabBar.backgroundView.backgroundColor = kColorNavBG;
#if RobotMower
    self.tabBar.backgroundView.backgroundColor = [UIColor colorWithRed:245/255.0
                                                            green:245/255.0
                                                             blue:245/255.0
                                                            alpha:0.9];
#elif MOWOXROBOT
    self.tabBar.backgroundView.backgroundColor = [UIColor whiteColor];
    self.tabBar.backgroundView.alpha = 0.3;
#endif
}

- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if (viewController.rdv_tabBarItem.tag == 1002) {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        if (appDelegate.status == 0 && [[NetWork shareNetWork].mySocket isDisconnected]) {
            [NSObject showHudTipStr:NSLocalizedString(@"Wi-Fi not connected", nil)];
            return NO;
        }
        if (appDelegate.currentPeripheral == nil && appDelegate.status == 1) {
            [NSObject showHudTipStr:NSLocalizedString(@"Bluetooth not connected", nil)];
            return NO;
        }
    }
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
