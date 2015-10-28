//
//  CircleCCCView.m
//  SliderCircleDemo
//
//  Created by apple on 15/6/30.
//  Copyright (c) 2015年 HuaZhengInfo. All rights reserved.
//

#import "CircleCCCView.h"

@implementation CircleCCCView
{
    NSTimer *_timer;//减速定时器
    CGFloat _numOfSubView;//子试图数量
    UIImageView *_circleView;//圆形图
    NSMutableArray *_subViewArray;//子试图数组
    CGPoint beginPoint;//第一触碰点
    CGPoint movePoint;//第二触碰点
    CGFloat scale;//旋转度数
    BOOL _fangxiang;//方向(顺时针yes)
    BOOL _isPlaying;//正在跑
    NSDate * date;//滑动时间
    NSInteger _decelerTime;//减速计数
    CGSize _subViewSize;//子试图大小
    UIPanGestureRecognizer *_pgr;
}
-(void)dealloc
{
    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
}
-(id)initWithFrame:(CGRect)frame andImage:(UIImage *)image
{
    if(self=[super initWithFrame:frame]){
        _decelerTime=0;
        scale=0;
        _subViewArray=[[NSMutableArray alloc] init];
        _circleView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        if(image==nil){
        _circleView.backgroundColor=[UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:240 / 255.0 alpha:1.0];;
        _circleView.layer.cornerRadius=frame.size.width/2;
        }else{
            _circleView.image=image;
            _circleView.backgroundColor=[UIColor clearColor];
        }
        _circleView.userInteractionEnabled=YES;
        [self addSubview:_circleView];
    }
    return self;
}
#pragma mark -  加子视图
-(void)addSubViewWithSubView:(NSArray *)imageArray andTitle:(NSArray *)titleArray andSize:(CGSize)size andcenterImage:(UIImage *)centerImage
{
    _subViewSize=size;
    if(titleArray.count==0){
        _numOfSubView=(CGFloat)imageArray.count;
    }
    if(imageArray.count==0){
        _numOfSubView=(CGFloat)titleArray.count;
    }
    for (NSInteger i=0; i<_numOfSubView ;i++) {
        
        CGFloat yy=150+sin((i/_numOfSubView)*M_PI*2)*(self.frame.size.width/2-size.width/2-20);
        CGFloat xx=150+cos((i/_numOfSubView)*M_PI*2)*(self.frame.size.width/2-size.width/2-20);
        UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(20, 20, size.width, size.height)];
        
//        [button setTitle:[NSString stringWithFormat:@"%ld%ld%ld%ld%ld",(long)i,(long)i,(long)i,(long)i,(long)i] forState:UIControlStateNormal];
        if(imageArray==nil){
            button.backgroundColor=[UIColor whiteColor];
            button.layer.cornerRadius=size.width/2;
        }else{
            [button setImage:imageArray[i] forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        button.tag=100+i;
        button.center=CGPointMake(xx, yy);
        [_subViewArray addObject:button];
        [_circleView addSubview:button];
    }
    //中间视图
    UIButton *buttonCenter=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/3.0, self.frame.size.height/3.0)];
    buttonCenter.tag=100+_numOfSubView+1;
    if(centerImage==nil){
        buttonCenter.layer.cornerRadius=self.frame.size.width/6.0;
        buttonCenter.backgroundColor=[UIColor orangeColor];
        [buttonCenter setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
        [buttonCenter setTitle:@"中间" forState:UIControlStateNormal];
    }else{
        [buttonCenter setImage:centerImage forState:UIControlStateNormal];
    }
    buttonCenter.center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [_subViewArray addObject:buttonCenter];
    [_circleView addSubview:buttonCenter];
    //加转动手势
    _pgr=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(zhuanPgr:)];
    [_circleView addGestureRecognizer:_pgr];
    //加点击效果
    for (NSInteger i=0; i<_subViewArray.count; i++) {
        UIButton *button=_subViewArray[i];
        [button addTarget:self action:@selector(subViewDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(subViewUp:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(subViewOut:) forControlEvents:UIControlEventTouchUpOutside];
    }
}
#pragma mark - 转动手势
-(void)zhuanPgr:(UIPanGestureRecognizer *)pgr
{
    UIView *view=pgr.view;
    if(pgr.state==UIGestureRecognizerStateBegan){
//        [_timer setFireDate:[NSDate distantFuture]];
        beginPoint=[pgr locationInView:self];
        date=[NSDate date];
    }else if (pgr.state==UIGestureRecognizerStateChanged){
        movePoint= [pgr locationInView:self];
        CGFloat distance=(ABS((movePoint.y-beginPoint.y)/(self.frame.size.width*M_PI))+ABS((movePoint.x-beginPoint.x))/(self.frame.size.width*M_PI))*20;
        if(movePoint.x<self.frame.size.width/2){
            if(movePoint.y-beginPoint.y>0){
                _fangxiang=NO;
               scale+=-distance;
            }else{
                _fangxiang=YES;
                scale+=distance;
            }
        }else{
                if(movePoint.y-beginPoint.y>0){
                    _fangxiang=YES;
                    scale+=+distance;
                }else{
                    _fangxiang=NO;
                    scale+=-distance;
                }
        }
        [self restButton];
        view.transform=CGAffineTransformMakeRotation(scale);
        beginPoint=movePoint;
    }else if (pgr.state==UIGestureRecognizerStateEnded){
        CGFloat time=[[NSDate date] timeIntervalSinceDate:date];
        if(time<=0.5){
            _isPlaying=YES;
            _timer=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(stopMore) userInfo:nil repeats:YES];
            
        }
    }
}
static CGFloat dece=0.1;

#pragma mark - 减速
-(void)stopMore
{
    _decelerTime+=1;
    if(_decelerTime%10==0){
        _decelerTime=0;
        dece-=0.01;
        if(dece<=0){
            _decelerTime=0.1;
            dece=0.1;
            [_timer setFireDate:[NSDate distantFuture]];
        }
    }
    
    if(_fangxiang==YES){
        scale+=dece;
    }else{
        scale-=dece;
    }
    _circleView.transform=CGAffineTransformMakeRotation(scale);
    [self restButton];
}

#pragma mark #pragma mark - 按钮归位
-(void)restButton
{
    for (UIView *view in _subViewArray) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.6];
        view.transform=CGAffineTransformMakeRotation(-scale);
        
        [UIView commitAnimations];
    }
}
static CGPoint centerPoint;
#pragma mark - 点下去
-(void)subViewDown:(UIButton *)button
{
    centerPoint=button.center;
    
    [_circleView removeGestureRecognizer:_pgr];
//    if(button.tag!=101+_numOfSubView){
//    button.layer.cornerRadius=(_subViewSize.width+20)/2.0;
//    CGRect frame=button.frame;
//    frame.size.width=_subViewSize.width+20;
//    frame.size.height=_subViewSize.height+20;
//    button.frame=frame;
//    }else{
//        button.layer.cornerRadius=(self.frame.size.width/3.0+20)/2.0;
//        CGRect frame=button.frame;
//        frame.size.width=self.frame.size.width/3.0+20;
//        frame.size.height=self.frame.size.height/3.0+20;
//        button.frame=frame;
//    }
    button.center=centerPoint;
}
#pragma mark - 抬起来
-(void)subViewUp:(UIButton *)button
{
    [_circleView addGestureRecognizer:_pgr];
//    if(button.tag!=101+_numOfSubView){
//    button.layer.cornerRadius=_subViewSize.width/2.0;
//    CGRect frame=button.frame;
//    frame.size.width=_subViewSize.width;
//    frame.size.height=_subViewSize.height;
//    button.frame=frame;
//    }else{
//        button.layer.cornerRadius=self.frame.size.width/6.0;
//        CGRect frame=button.frame;
//        frame.size.width=self.frame.size.width/3.0;
//        frame.size.height=self.frame.size.height/3.0;
//        button.frame=frame;
//    }
    button.center=centerPoint;
    
    //点击
    if(self.clickSomeOne){
        self.clickSomeOne([NSString stringWithFormat:@"%ld",(long)button.tag]);
    }
}
-(void)subViewOut:(UIButton *)button
{
    [_circleView addGestureRecognizer:_pgr];
//    if(button.tag!=101+_numOfSubView){
//        button.layer.cornerRadius=_subViewSize.width/2.0;
//        CGRect frame=button.frame;
//        frame.size.width=_subViewSize.width;
//        frame.size.height=_subViewSize.height;
//        button.frame=frame;
//    }else{
//        button.layer.cornerRadius=self.frame.size.width/6.0;
//        CGRect frame=button.frame;
//        frame.size.width=self.frame.size.width/3.0;
//        frame.size.height=self.frame.size.height/3.0;
//        button.frame=frame;
//    }
    button.center=centerPoint;
}
@end
