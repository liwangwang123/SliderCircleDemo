//
//  CircleLHQView.m
//  SliderCircleDemo
//
//  Created by 123456 on 15-7-1.
//  Copyright (c) 2015年 HuaZhengInfo. All rights reserved.
//

#import "CircleLHQView.h"

@implementation CircleLHQView {
    NSTimer         *_timer;//减速定时器
    CGFloat          _numOfSubView;//子试图数量
    UIImageView     *_circleView;//圆形图
    NSMutableArray  *_subViewArray;//子试图数组
    CGPoint          _beginPoint;//第一触碰点
    CGPoint          _movePoint;//第二触碰点
    BOOL             _isPlaying;//正在跑
    NSDate          *date;//滑动时间
    
    NSDate          *_startTouchDate;
    NSInteger        _decelerTime;//减速计数
    CGSize           _subViewSize;//子试图大小
    UIPanGestureRecognizer *_pgr;
    
    double           _mStartAngle;//转动的角度
    int              _mFlingableValue;//转动临界速度，超过此速度便是快速滑动，手指离开仍会转动
    int              _mRadius;//半径
    NSMutableArray  *_btnArray;
    float            _mTmpAngle;//检测按下到抬起时旋转的角度
    BOOL _subButtonShowing;

}

-(void)dealloc {
    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
}

- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image {
    if(self=[super initWithFrame:frame]){
        //底图
        _circleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        //判断是否添加图片
        if(image == nil){
            _circleView.backgroundColor=[UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:240 / 255.0 alpha:1.0];;
            _circleView.layer.cornerRadius = frame.size.width / 2;
        }else{
            _circleView.image = image;
            _circleView.backgroundColor = [UIColor clearColor];
        }
        _circleView.userInteractionEnabled = YES;
        [self addSubview:_circleView];
        
        _decelerTime = 0;//减速计数
        _subViewArray = [[NSMutableArray alloc] init];
        _mRadius = frame.size.width / 2;//圆角
        _mStartAngle = 0;//开始角度
        _mFlingableValue = 300;//转动临界速度
        _isPlaying = false;//默认停止
    }
    return self;
}

#pragma mark - 加子视图
- (void)addSubViewWithSubView:(NSArray *)imageArray andTitle:(NSArray *)titleArray andSize:(CGSize)size andCenterImage:(UIImage *)centerImage {
    _subViewSize = size;
    if(titleArray.count == 0){
        _numOfSubView = (CGFloat)imageArray.count;
    }
    if(imageArray.count == 0){
        _numOfSubView = (CGFloat)titleArray.count;
    }
    
    _btnArray = [[NSMutableArray alloc]init];
    for(NSInteger i = 0; i < _numOfSubView; i++){
        UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(20, 20, size.width, size.height)];
        [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        if(imageArray == nil){
            button.backgroundColor = [UIColor whiteColor];
            button.layer.cornerRadius = size.width / 2;
        } else {
            [button setImage:imageArray[i] forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        button.tag = 100 + i;
        [_btnArray addObject:button];
        [_subViewArray addObject:button];
        [_circleView addSubview:button];
    }
    //最初布局
    [self layoutBtn];
    
    //中间视图
    UIButton *buttonCenter = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 3.0, self.frame.size.height / 3.0)];
    buttonCenter.tag = 100 + _numOfSubView+1;
    [buttonCenter addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    if(centerImage == nil){
        buttonCenter.layer.cornerRadius = self.frame.size.width / 6.0;
        buttonCenter.backgroundColor = [UIColor orangeColor];
        [buttonCenter setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
        [buttonCenter setTitle:@"中间" forState:UIControlStateNormal];
    }else{
        [buttonCenter setImage:centerImage forState:UIControlStateNormal];
    }
    buttonCenter.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [_subViewArray addObject:buttonCenter];
    [_circleView addSubview:buttonCenter];
    //加转动手势
    _pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(zhuanPgr:)];
    [_circleView addGestureRecognizer:_pgr];
    //加点击效果
    for (NSInteger i=0; i < _subViewArray.count; i++) {
        UIButton *button=_subViewArray[i];
        [button addTarget:self action:@selector(subViewOut:) forControlEvents:UIControlEventTouchUpOutside];
    }
}

- (void)btnAction:(UIButton *)sender {
    if (100 + _numOfSubView + 1 == sender.tag) {
        [self subViewMove];
    }
    NSLog(@"btnAction : %@, %ld", sender.titleLabel.text, sender.tag);
}

- (void)subViewMove {
    if (_subButtonShowing) {
        for (int i = 0; i < _numOfSubView; i++) {
            CGFloat yy = self.frame.size.width / 2.0;
            CGFloat xx = self.frame.size.width / 2.0;
            UIButton *btn = [_btnArray objectAtIndex:i];
            [UIView animateKeyframesWithDuration:2.0 delay:0.3 * i options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
                //收缩
                
                btn.center = CGPointMake(xx, yy);
            } completion:^(BOOL finished) {
                //扩展
                
            }];
        }
        _subButtonShowing = NO;
    } else {
        
        for (int i = 0; i < _numOfSubView; i++) {
            CGFloat yy = self.frame.size.width / 2.0 + sin((i / _numOfSubView) * M_PI * 2 + _mStartAngle) * (self.frame.size.width / 2.0 - _subViewSize.width / 2.0 - 20.0);
            CGFloat xx = self.frame.size.width / 2.0 + cos((i / _numOfSubView) * M_PI * 2 + _mStartAngle) * (self.frame.size.width / 2.0 - _subViewSize.width / 2.0 - 20.0);
            UIButton *btn = [_btnArray objectAtIndex:i];
            [UIView animateWithDuration:0.5 animations:^{
                btn.center = CGPointMake(xx, yy);
                
            }];
        }
        
        _subButtonShowing = YES;
        
    }
}
//按钮布局
-(void)layoutBtn{

    for (NSInteger i = 0; i < _numOfSubView; i++) {// 178,245
        CGFloat yy = self.frame.size.width / 2 + sin((i / _numOfSubView) * M_PI * 2 + _mStartAngle) * (self.frame.size.width / 2 -_subViewSize.width / 2 - 20);
        CGFloat xx = self.frame.size.width / 2 + cos((i / _numOfSubView) * M_PI * 2 + _mStartAngle) * (self.frame.size.width / 2 - _subViewSize.width / 2 - 20);
        UIButton *button=[_btnArray objectAtIndex:i];
        button.center = CGPointMake(xx, yy);
    }
}

NSTimer *flowtime;
float anglePerSecond;
float speed;  //转动速度

#pragma mark - 转动手势
-(void)zhuanPgr:(UIPanGestureRecognizer *)pgr {
//    UIView *view=pgr.view;
    if(pgr.state == UIGestureRecognizerStateBegan){
        _mTmpAngle = 0;
        _beginPoint = [pgr locationInView:self];//获取手指接触点位置
        _startTouchDate = [NSDate date];        //手指开始的时间
    }else if (pgr.state == UIGestureRecognizerStateChanged){
        float StartAngleLast = _mStartAngle;//转动角度
        _movePoint= [pgr locationInView:self];//手指移动到的点
        float start = [self getAngle:_beginPoint];//获得起始弧度
        float end = [self getAngle:_movePoint];//结束弧度
        //判断象限
        if ([self getQuadrant:_movePoint] == 1 || [self getQuadrant:_movePoint] == 4) {
            _mStartAngle += end - start;
            _mTmpAngle += end - start;
//            NSLog(@"第一、四象限____%f",mStartAngle);
        } else {
            // 二、三象限，色角度值是付值
            _mStartAngle += start - end;
            _mTmpAngle += start - end;
//            NSLog(@"第二、三象限____%f",mStartAngle);
//             NSLog(@"mTmpAngle is %f",mTmpAngle);
        }
        [self layoutBtn];
        _beginPoint=_movePoint;
        speed = _mStartAngle - StartAngleLast;
        NSLog(@"speed is %f",speed);
    } else if (pgr.state==UIGestureRecognizerStateEnded){
        // 计算，每秒移动的角度
        NSTimeInterval time=[[NSDate date] timeIntervalSinceDate:_startTouchDate];
        anglePerSecond = _mTmpAngle*50 / time;
        NSLog(@"anglePerSecond is %f",anglePerSecond);
        // 如果达到该值认为是快速移动
        if (fabsf(anglePerSecond) > _mFlingableValue && !_isPlaying) {
            // post一个任务，去自动滚动
            _isPlaying = true;
            flowtime = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                        target:self
                                                      selector:@selector(flowAction)
                                                      userInfo:nil
                                                       repeats:YES];
        }
    }
}

//获取当前点弧度

- (float)getAngle:(CGPoint)point {
    double x = point.x - _mRadius;
    double y = point.y - _mRadius;
    return (float) (asin(y / hypot(x, y)));
}

/**
 * 根据当前位置计算象限
 *
 * @param x
 * @param y
 * @return
 */
-(int)getQuadrant:(CGPoint)point {
    int tmpX = (int)(point.x - _mRadius);
    int tmpY = (int)(point.y - _mRadius);
    if (tmpX >= 0) {
        return tmpY >= 0 ? 1 : 4;
    } else {
        return tmpY >= 0 ? 2 : 3;
    }
}

-(void)flowAction{
    if (speed < 0.1) {
        _isPlaying = false;
        [flowtime invalidate];
        flowtime = nil;
        return;
    }
    // 不断改变mStartAngle，让其滚动，/30为了避免滚动太快
    _mStartAngle += speed ;
    speed = speed / 1.1;
    // 逐渐减小这个值
//    anglePerSecond /= 1.1;
    [self layoutBtn];
}

-(void)subViewOut:(UIButton *)button
{
    //点击
    if(self.clickSomeOne){
        self.clickSomeOne([NSString stringWithFormat:@"%ld",(long)button.tag]);
    }
}

@end
