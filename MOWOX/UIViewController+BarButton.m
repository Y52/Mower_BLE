//
//  UIViewController+BarButton.m
//  MOWOX
//
//  Created by 杭州轨物科技有限公司 on 2018/4/8.
//  Copyright © 2018年 yusz. All rights reserved.
//

#import "UIViewController+BarButton.h"

@implementation UIViewController (BarButton)

- (void)addLeftBarButtonWithImage:(UIImage *)image action:(SEL)action

{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0,0,44,44)];
    
    view.backgroundColor = [UIColor clearColor];
    
    
    
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    firstButton.frame = CGRectMake(0, 0, 44, 44);
    
    [firstButton setImage:image forState:UIControlStateNormal];
    
    [firstButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    
    firstButton.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
    
    [firstButton setImageEdgeInsets:UIEdgeInsetsMake(5 * ScreenHeight / 667.0,5 * ScreenWidth / 375.0,0,0)];
    
    
    
    
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:firstButton];
    
    
    
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
}



@end
