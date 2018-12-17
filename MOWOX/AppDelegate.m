//
//  AppDelegate.m
//  MOWOX
//
//  Created by Mac on 2017/10/30.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import <GizWifiSDK/GizWifiSDK.h>
@interface AppDelegate ()<GizWifiSDKDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#if RobotMower
    NSLog(@"RobotMower");
#elif MOWOXROBOT
    NSLog(@"MOWOXROBOT");
#endif
    
    [NSThread sleepForTimeInterval:1.0];//设置启动页面时间
    
    [self customizeInterface];
    [self initGiz];
    
    _status = 1;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    
    LoginViewController *vc = [[LoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
#if RobotMower
    [navigationBarAppearance setBackgroundImage:[UIImage imageNamed:@"loginView"] forBarMetrics:UIBarMetricsDefault];
    navigationBarAppearance.translucent = YES;
#elif MOWOXROBOT
    //navigationBarAppearance.barTintColor = [UIColor clearColor];
    navigationBarAppearance.translucent = YES;
    
    //设置导航栏背景图片为一个空的image，这样就透明了
    [navigationBarAppearance setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    //去掉透明后导航栏下边的黑边
    [navigationBarAppearance setShadowImage:[[UIImage alloc] init]];
#endif
    [navigationBarAppearance setTintColor:[UIColor whiteColor]];//返回按钮的箭头颜色
    //[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName: [UIFont systemFontOfSize:17.f],
                                     NSForegroundColorAttributeName: [UIColor whiteColor],
                                     };
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
}

- (void) initGiz{
    [GizWifiSDK sharedInstance].delegate = self;
    NSDictionary *parameters =@{@"appId":GizAppId,@"appSecret": GizAppSecret};
    NSDictionary *product =@{@"productKey": GizAppproductKey, @"productSecret": GizAppproductSecret};
    NSArray *productArray = @[product];
    
    [GizWifiSDK startWithAppInfo: parameters productInfo:productArray cloudServiceInfo: nil autoSetDeviceDomain:YES];
    
    
}

// 实现系统事件通知回调
- (void)wifiSDK:(GizWifiSDK *)wifiSDK didNotifyEvent:(GizEventType)eventType eventSource:(id)eventSource eventID:(GizWifiErrorCode)eventID eventMessage: (NSString *)eventMessage {
    if(eventType == GizEventSDK) {
        // SDK发生异常的通知
        NSLog(@"SDK event happened: [%@] = %@", @(eventID), eventMessage);
        
    } else if(eventType == GizEventDevice) {
        // 设备连接断开时可能产生的通知
        GizWifiDevice* mDevice = (GizWifiDevice*)eventSource;
        NSLog(@"device mac %@ disconnect caused by %@", mDevice.macAddress, eventMessage);
    } else if(eventType == GizEventM2MService) {
        // M2M服务返回的异常通知
        NSLog(@"M2M domain %@ exception happened: [%@] = %@", (NSString*)eventSource, @(eventID), eventMessage);
    } else if(eventType == GizEventToken) {
        // token失效通知
        NSLog(@"token %@ expired: %@", (NSString*)eventSource, eventMessage);
    }
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDiscovered:(NSError *)result deviceList:(NSArray<GizWifiDevice *> *)deviceList{
    for (GizWifiDevice *device in deviceList) {
        //[GizWifiSDK setDeviceServerInfo:@"eusite.gizwits.com" mac:@"84F3EBBE1F3C"];
        //[GizWifiSDK getDevicesToSetServerInfo];
        NSLog(@"%@",device.productName);
    }
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didSetDeviceServerInfo:(NSError *)result mac:(NSString *)mac{
    NSLog(@"%@",result);
}

@end
