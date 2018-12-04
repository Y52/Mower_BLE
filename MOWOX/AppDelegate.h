//
//  AppDelegate.h
//  MOWOX
//
//  Created by Mac on 2017/10/30.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BabyBluetooth/BabyBluetooth.h>



@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,strong) CBCharacteristic *currentCharacteristic;
@property (nonatomic, strong) CBPeripheral * currentPeripheral;

@property (nonatomic) int status;//0:Wi-Fi,1:BLE

@end

