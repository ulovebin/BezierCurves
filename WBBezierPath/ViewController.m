//
//  ViewController.m
//  WBBezierPath
//
//  Created by tuhui－03 on 16/5/17.
//  Copyright © 2016年 tuhui－03. All rights reserved.
//

#import "ViewController.h"

#define MIN_HEIGHT 100

@interface ViewController ()

@property(strong,readwrite,nonatomic)CAShapeLayer *shapeLayer;//形变视图

@property(assign,readwrite,nonatomic)float curveX;//拖动点x坐标
@property(assign,readwrite,nonatomic)float curveY;//拖动点y坐标
@property(strong,readwrite,nonatomic)UIView *curveView;//拖动点


@property(assign,readwrite,nonatomic)float mHeight;//手势移动相对高度

@property(strong,readwrite,nonatomic)CADisplayLink *displayLink;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //初始化形变视图
    _shapeLayer=[CAShapeLayer layer];
    _shapeLayer.fillColor=[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1].CGColor;
    [self.view.layer addSublayer:_shapeLayer];
    
    
    //初始化拖动点
    _curveX=self.view.frame.size.width/2;
    _curveY=MIN_HEIGHT;
    _curveView=[[UIView alloc]initWithFrame:CGRectMake(_curveX, _curveY, 3, 3)];
    _curveView.backgroundColor=[UIColor redColor];
    [self.view addSubview:_curveView];
    
    
    _mHeight=100;
    //添加手势
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    self.view.userInteractionEnabled=YES;
    [self.view addGestureRecognizer:pan];
    
    //开启循环
    _displayLink=[CADisplayLink displayLinkWithTarget:self selector:@selector(calculatePath)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _displayLink.paused=YES;
    
    [self updateShapeLayerPath];
}


-(void)panGestureAction:(UIPanGestureRecognizer *)pan
{
    if (pan.state==UIGestureRecognizerStateChanged) {
        
        CGPoint point=[pan translationInView:self.view];
        
        _mHeight=point.y*0.7+MIN_HEIGHT;//乘0.7可以使拖动效果更好
        _curveX=self.view.frame.size.width/2+point.x;
        _curveY=_mHeight>MIN_HEIGHT?_mHeight:MIN_HEIGHT;
        _curveView.frame=CGRectMake(_curveX, _curveY, 3, 3);
        
        [self updateShapeLayerPath];
        
    }
    else if (pan.state==UIGestureRecognizerStateEnded)
    {
       _displayLink.paused = NO;
        
        [UIView animateWithDuration:1.0
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:1
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             _curveView.frame = CGRectMake(self.view.frame.size.width/2.0, MIN_HEIGHT, 3, 3);//拖动结束红点恢复原来位置
                             
                         } completion:^(BOOL finished) {
                             
                             if(finished)
                             {
                                 _displayLink.paused = YES;
                             }
                             
                         }];
        
    
    }


}

//拖动结束根据_curveView.frame恢复原位置帧动画，计算导航形状
-(void)calculatePath
{
    _curveX=_curveView.center.x;
    _curveY=_curveView.center.y;
    [self updateShapeLayerPath];


}

//更新导航栏贝塞尔曲线
-(void)updateShapeLayerPath
{
    UIBezierPath *path=[UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(self.view.frame.size.width, 0)];
    [path addLineToPoint:CGPointMake(self.view.frame.size.width, MIN_HEIGHT)];
    [path addQuadCurveToPoint:CGPointMake(0, MIN_HEIGHT) controlPoint:CGPointMake(_curveX, _curveY)];
    [path closePath];
    
    _shapeLayer.path=path.CGPath;
    
}



@end
