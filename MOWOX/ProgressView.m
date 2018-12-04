//
//  ProgressView.m
//  MOWOX
//
//  Created by Mac on 2017/12/28.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "ProgressView.h"

@implementation ProgressView
- (void)drawRect:(CGRect)rect {
    //    仪表盘底部
    drawHu1();
    //    仪表盘进度
    [self drawHu2];
}
-(void)drawHu2
{
    //1.获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //1.1 设置线条的宽度
    CGContextSetLineWidth(ctx, 10);
    //1.2 设置线条的起始点样式
    CGContextSetLineCap(ctx,kCGLineCapButt);
    //1.3  虚实切换 ，实线5虚线10
    CGFloat length[] = {4,8};
    CGContextSetLineDash(ctx, 0, length, 2);
    //1.4 设置颜色
    [[UIColor whiteColor] set];
    //2.设置路径
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(numberChange) name:@"progressNumber" object:nil];
    
    CGFloat end = -5*M_PI_4+(6*M_PI_4*_num/_packageNum);
    
    CGContextAddArc(ctx, ScreenWidth/2 , ScreenWidth/2, 80, -5*M_PI_4, end , 0);
    
    //3.绘制
    CGContextStrokePath(ctx);
    
    
}

-(void)numberChange
{
    
    //_num = [text.userInfo[@"num"] intValue];
    _num = [BluetoothDataManage shareInstance].progress_num;
    _numLabel.text = [NSString stringWithFormat:@"%d",(int)(((float)_num / _packageNum) * 100)];
    [self setNeedsDisplay];
    
}

void drawHu1()
{
    
    //1.获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //1.1 设置线条的宽度
    CGContextSetLineWidth(ctx, 10);
    //1.2 设置线条的起始点样式
    CGContextSetLineCap(ctx,kCGLineCapButt);
    //1.3  虚实切换 ，实线5虚线10
    CGFloat length[] = {4,8};
    CGContextSetLineDash(ctx, 0, length, 2);
    //1.4 设置颜色
    [[UIColor blackColor] set];
    //2.设置路径
    CGContextAddArc(ctx, ScreenWidth/2 , ScreenWidth/2, 80, -5*M_PI_4, M_PI_4, 0);
    //3.绘制
    CGContextStrokePath(ctx);
    
}

-(void)setNum:(int)num
{
    _num = num;
    
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        _numLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth-120)/2, (ScreenWidth-80)/2, 120, 80)];
        _numLabel.textAlignment  = NSTextAlignmentCenter;
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.font = [UIFont systemFontOfSize:60];
        
        
        /*if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(change) userInfo:nil repeats:YES];
        }*/
        
        
        [self addSubview:_numLabel];
        
    }
    return self;
}
-(void)change
{
    _num +=1;
    
    if (_num > 100) {
        _num = 0;
    }
    
    _numLabel.text = [NSString stringWithFormat:@"%d",_num];
    
    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:_numLabel.text,@"num", nil];
    
    //    创建通知
    NSNotification *noti = [NSNotification notificationWithName:@"number" object:nil userInfo:dic];
    //    发送通知
    [[NSNotificationCenter defaultCenter]postNotification:noti];
    
}


@end
