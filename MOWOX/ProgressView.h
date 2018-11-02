//
//  ProgressView.h
//  MOWOX
//
//  Created by Mac on 2017/12/28.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView
@property(nonatomic,assign)int packageNum;
@property(nonatomic,assign)int num;
@property(nonatomic,strong)UILabel *numLabel;
//@property(nonatomic,strong)NSTimer *timer;
@end
