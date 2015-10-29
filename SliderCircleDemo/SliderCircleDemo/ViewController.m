//
//  ViewController.m
//  SliderCircleDemo
//
//  Created by apple on 15/6/30.
//  Copyright (c) 2015年 HuaZhengInfo. All rights reserved.
//

#import "ViewController.h"
#import "CircleLHQView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CircleLHQView *LHQView = [[CircleLHQView alloc] initWithFrame:CGRectMake(10, 100, 300, 300) andImage:nil];
    
    [LHQView addSubViewWithSubView:nil andTitle:@[@"第一个",@"第二个",@"第三个",@"第四个",@"第五个",@"第六个", @"第七个"] andSize:CGSizeMake(60, 60) andCenterImage:nil];
    [self.view addSubview:LHQView];
     LHQView.clickSomeOne=^(NSString *str){
            NSLog(@"%@被点击了",str);
        };

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
