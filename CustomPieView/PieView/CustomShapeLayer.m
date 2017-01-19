//
//  CustomShapeLayer.m
//  TestPieView
//
//  Created by 龙培 on 16/12/12.
//  Copyright © 2017年 龙培. All rights reserved.
//
// 下载与使用详细地址https://github.com/Coolll/CustomPieView

#import "CustomShapeLayer.h"
#import <UIKit/UIKit.h>

@implementation CustomShapeLayer


-(void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    CGPoint newCenterPoint = _centerPoint;
    CGFloat offset = [self preferGetUserSetValue:self.clickOffset withDefaultValue:15];

    if (self.isOneSection) {
        
        [self dealOneSectionWithSelected:isSelected withOffset:offset];
        return;
    }
    
    if (isSelected) {
        
        //center 往外围移动一点 使用cosf跟sinf函数
        newCenterPoint = CGPointMake(_centerPoint.x + cosf((_startAngle + _endAngle) / 2) * offset, _centerPoint.y + sinf((_startAngle + _endAngle) / 2) * offset);
    }
    //创建一个path
    UIBezierPath *path = [UIBezierPath bezierPath];
    //起始中心点改一下
    [path moveToPoint:newCenterPoint];
    [path addArcWithCenter:newCenterPoint radius:_radius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    [path addArcWithCenter:newCenterPoint radius:_innerRadius startAngle:_endAngle endAngle:_startAngle clockwise:NO];
    [path closePath];
    self.path = path.CGPath;
    
    //添加动画
    CABasicAnimation *animation = [CABasicAnimation animation];
    //keyPath内容是对象的哪个属性需要动画
    animation.keyPath = @"path";
    //所改变属性的结束时的值
    animation.toValue = path;
    //动画时长
    animation.duration = 0.35;
    //添加动画
    [self addAnimation:animation forKey:nil];
    
    
    
}

//单个圆饼的处理
- (void)dealOneSectionWithSelected:(BOOL)isSelected withOffset:(CGFloat)offset
{
    
    //创建一个path
    UIBezierPath *originPath = [UIBezierPath bezierPath];
    //起始中心点改一下
    [originPath moveToPoint:_centerPoint];
    [originPath addArcWithCenter:_centerPoint radius:_radius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    [originPath addArcWithCenter:_centerPoint radius:_innerRadius startAngle:_endAngle endAngle:_startAngle clockwise:NO];
    [originPath closePath];

    
    //再创建一个path
    UIBezierPath *path = [UIBezierPath bezierPath];
    //起始中心点改一下
    [path moveToPoint:_centerPoint];
    [path addArcWithCenter:_centerPoint radius:_radius+offset startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    [path addArcWithCenter:_centerPoint radius:_innerRadius startAngle:_endAngle endAngle:_startAngle clockwise:NO];
    [path closePath];
    
    
    
    if (!isSelected) {
        self.path = originPath.CGPath;
        
        //添加动画
        CABasicAnimation *animation = [CABasicAnimation animation];
        //keyPath内容是对象的哪个属性需要动画
        animation.keyPath = @"path";
        
        animation.fromValue = path;
        //所改变属性的结束时的值
        animation.toValue = originPath;
        
        //动画时长
        animation.duration = 0.35;
        
        //添加动画
        [self addAnimation:animation forKey:nil];

        
    }else{
        
        self.path = path.CGPath;
        
        //添加动画
        CABasicAnimation *animation = [CABasicAnimation animation];
        //keyPath内容是对象的哪个属性需要动画
        animation.keyPath = @"path";
        
        animation.fromValue = originPath;
        //所改变属性的结束时的值
        animation.toValue = path;
        
        //动画时长
        animation.duration = 0.35;
        
        //添加动画
        [self addAnimation:animation forKey:nil];

    }
    
    

}




- (CGFloat)preferGetUserSetValue:(CGFloat)userValue withDefaultValue:(CGFloat)defaultValue
{
    if (userValue > 0 ) {
        return userValue;
    }else{
        
        return defaultValue;
    }
    
}


@end
