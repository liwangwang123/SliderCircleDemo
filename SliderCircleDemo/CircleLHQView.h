//
//  CircleLHQView.h
//  SliderCircleDemo
//
//  Created by 123456 on 15-7-1.
//  Copyright (c) 2015年 HuaZhengInfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleLHQView : UIView

@property (nonatomic,strong)void(^clickSomeOne)(NSString *);

//根据子试图数量 圆形盘的图片 初始化
-(id)initWithFrame:(CGRect)frame andImage:(UIImage *)image;

//加子视图 图片 文字 大小
-(void)addSubViewWithSubView:(NSArray *)imageArray andTitle:(NSArray *)titleArray andSize:(CGSize)size andcenterImage:(UIImage *)centerImage;
@end
