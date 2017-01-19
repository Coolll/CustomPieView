//
//  CustomShapeLayer.h
//  TestPieView
//
//  Created by 龙培 on 16/12/12.
//  Copyright © 2017年 龙培. All rights reserved.
//
// 下载与使用详细地址https://github.com/Coolll/CustomPieView


#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
@interface CustomShapeLayer : CAShapeLayer

/**
 *  起始弧度
 **/
@property (nonatomic,assign) CGFloat startAngle;

/**
 *  结束弧度
 **/
@property (nonatomic,assign) CGFloat endAngle;

/**
 *  圆饼半径
 **/
@property (nonatomic,assign) CGFloat radius;

/**
 *  点击偏移量
 **/
@property (nonatomic,assign) CGFloat clickOffset;

/**
 *  是否点击
 **/
@property (nonatomic,assign) BOOL isSelected;

/**
 *  是否只有一个模块，多个模块的动画与单个模块的动画不一样
 **/
@property (nonatomic,assign) BOOL isOneSection;

/**
 *  圆饼layer的圆心
 **/
@property (nonatomic,assign) CGPoint centerPoint;

/**
 *  内圆半径
 **/
@property (nonatomic,assign) CGFloat innerRadius;

/**
 *  内圆颜色
 **/
@property (nonatomic,strong) UIColor *innerColor;





@end
