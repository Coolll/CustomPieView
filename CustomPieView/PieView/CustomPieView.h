//
//  CustomPieView.h
//  TestPieView
//
//  Created by 龙培 on 16/12/12.
//  Copyright © 2016年 龙培. All rights reserved.
//
// 下载与使用详细地址https://github.com/Coolll/CustomPieView


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,PieAnimationType){
    
    PieAnimationTypeOne = 0,//所有部分只有一个动画
    PieAnimationTypeTogether//所有部分一起动画
    
};

typedef NS_ENUM(NSInteger ,PieCenterType) {
    
    PieCenterTypeCenter = 0,//默认，圆心位于视图的中心
    PieCenterTypeTopLeft,//圆位于视图的上部的左侧
    PieCenterTypeTopMiddle,//圆位于视图的上部的中间
    PieCenterTypeTopRight,//圆位于视图的上部的右侧
    PieCenterTypeMiddleLeft,//圆位于视图的中部的左侧
    PieCenterTypeMiddleRight,//圆位于视图的中部的右侧
    PieCenterTypeBottomLeft,//圆位于视图的底部的左侧
    PieCenterTypeBottomMiddle,//圆位于视图的底部的中间
    PieCenterTypeBottomRight//圆位于视图的底部的右侧
};



@interface CustomPieView : UIView
/**
 *  饼状图数据数组
 **/
@property (nonatomic,strong) NSArray *segmentDataArray;
/**
 *  饼状图标题数组
 **/
@property (nonatomic,strong) NSArray *segmentTitleArray;
/**
 *  饼状图颜色数组
 **/
@property (nonatomic,strong) NSArray *segmentColorArray;
/**
 *  圆饼的半径
 **/
@property (nonatomic,assign) CGFloat pieRadius;
/**
 *  是否动画
 **/
@property (nonatomic,assign) BOOL needAnimation;

/**
 *  是否隐藏文本
 **/
@property (nonatomic,assign) BOOL hideText;

/**
 *  动画时间
 **/
@property (nonatomic,assign) CGFloat animateTime;

/**
 *  动画类型,默认只有一个动画
 **/
@property (nonatomic,assign) PieAnimationType type;

/**
 *  内部圆的半径，默认大圆半径的1/3
 **/
@property (nonatomic,assign) CGFloat innerCircleR;
/**
 *  内部圆的颜色，默认白色
 **/
@property (nonatomic,strong) UIColor *innerColor;

/**
 *  圆的位置，默认视图的中心
 **/
@property (nonatomic,assign) PieCenterType centerType;

/**
 *  右侧文本 距离右侧的间距
 **/
@property (nonatomic,assign) CGFloat textRightSpace;

/**
 *  圆心的X位置
 **/
@property (nonatomic,assign) CGFloat centerXPosition;

/**
 *  圆心的Y位置
 **/
@property (nonatomic,assign) CGFloat centerYPosition;

/**
 *  文本的高度，默认20
 **/
@property (nonatomic,assign) CGFloat textHeight;

/**
 *  文本前的颜色模块的高度，默认等同于文本高度
 **/
@property (nonatomic,assign) CGFloat colorHeight;

/**
 *  文本的字号，默认14
 **/
@property (nonatomic,assign) CGFloat textFontSize;

/**
 *  文本的行间距，默认10
 **/
@property (nonatomic,assign) CGFloat textSpace;

/**
 *  文本前的颜色是否为圆
 **/
@property (nonatomic,assign) BOOL isRound;

/**
 *  是否文本颜色等于模块颜色,默认不一样，文本默认黑色
 **/
@property (nonatomic,assign) BOOL isSameColor;

/**
 *  是否允许点击
 **/
@property (nonatomic,assign) BOOL canClick;

/**
 *  点击偏移量，默认15
 **/
@property (nonatomic,assign) CGFloat clickOffsetSpace;

//添加视图
- (void)showCustomViewInSuperView:(UIView*)superView;

//圆饼的点击事件
- (void)clickPieView:(void(^)(NSInteger index))clickBlock;

//更新圆饼
- (void)updatePieView;

@end
