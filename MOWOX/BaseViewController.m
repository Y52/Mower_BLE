//
//  BaseViewController.m
//  MOWOX
//
//  Created by 杭州轨物科技有限公司 on 2018/7/20.
//  Copyright © 2018年 yusz. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if RobotMower
    UIImage *backImage = [UIImage imageNamed:@"backgroundnew"];
    self.view.layer.contents = (id)backImage.CGImage;
#elif MOWOXROBOT
    UIImage *backImage = [UIImage imageNamed:@"App_BG_4"];
    self.view.layer.contents = (id)backImage.CGImage;
#endif
    
}

@end
