//
//  ViewController.m
//  SliderCircleDemo
//
//  Created by apple on 15/6/30.
//  Copyright (c) 2015年 HuaZhengInfo. All rights reserved.
//

#import "ViewController.h"
#import "CircleCCCView.h"
#import "CircleLHQView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CircleLHQView *LHQView = [[CircleLHQView alloc] initWithFrame:CGRectMake(10, 100, 300, 300) andImage:nil];
    [LHQView addSubViewWithSubView:nil andTitle:@[@"第一个",@"第二个",@"第三个",@"第四个",@"第五个",@"第六个", @"第七个"] andSize:CGSizeMake(60, 60) andcenterImage:nil];
    [self.view addSubview:LHQView];
     LHQView.clickSomeOne=^(NSString *str){
            NSLog(@"%@被点击了",str);
        };

}
-(void)change:(UIButton *)button
{
    
    for (UIView *view in self.view.subviews) {
        if([view isKindOfClass:[CircleCCCView class]]){
            [view removeFromSuperview];
        }
    }
    NSArray *arr=@[@"第一个",@"第二个",@"第三个",@"第四个",@"第五个",@"第六个", @"第七个"];
    NSMutableArray *arr2=[[NSMutableArray alloc] init];
    for (NSInteger i=0; i<button.tag; i++) {
        [arr2 addObject:arr[i]];
    }
    CircleCCCView *ccc=[[CircleCCCView alloc] initWithFrame:CGRectMake(10, 100, 300, 300) andImage:nil];
    [ccc addSubViewWithSubView:nil andTitle:arr2 andSize:CGSizeMake(60, 60) andcenterImage:nil];
    [self.view addSubview:ccc];
    ccc.clickSomeOne=^(NSString *str){
        NSLog(@"%@被点击了",str);
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
