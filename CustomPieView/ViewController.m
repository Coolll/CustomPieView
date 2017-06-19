//
//  ViewController.m
//  TestPieView
//
//  Created by 龙培 on 16/12/12.
//  Copyright © 2016年 龙培. All rights reserved.
//

#import "ViewController.h"
#import "CustomPieView.h"
#define RGBCOLOR(r,g,b,_alpha) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:_alpha]
#define PhoneScreen_HEIGHT [UIScreen mainScreen].bounds.size.height
#define PhoneScreen_WIDTH [UIScreen mainScreen].bounds.size.width

@interface ViewController ()
{
    CustomPieView *chartView;
    
    NSMutableArray *segmentDataArray;
    
    NSMutableArray *segmentTitleArray;
    
    NSMutableArray *segmentColorArray;
    
    NSInteger chartWidth;
    
    NSInteger chartHeight;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadPieData];
    
    [self loadPieChartView];
}

- (void)loadPieData
{
    chartWidth = PhoneScreen_WIDTH-20;
    
    chartHeight = 300;
    
    segmentDataArray = [NSMutableArray arrayWithObjects:@"2",@"2",@"3",@"1",@"4", nil];
    
    segmentTitleArray = [NSMutableArray arrayWithObjects:@"提莫",@"拉克丝",@"皇子",@"EZ",@"布隆", nil];
    
    segmentColorArray = [NSMutableArray arrayWithObjects:[UIColor redColor],[UIColor orangeColor],[UIColor greenColor],[UIColor brownColor], nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)loadPieChartView
{
    //包含文本的视图frame
    chartView = [[CustomPieView alloc]initWithFrame:CGRectMake(10, 100, chartWidth, chartHeight)];
    
    //数据源
    chartView.segmentDataArray = segmentDataArray;
    
    //颜色数组，若不传入，则为随即色
    chartView.segmentColorArray = segmentColorArray;
    
    //标题，若不传入，则为“其他”
    chartView.segmentTitleArray = segmentTitleArray;
    
    //动画时间
    chartView.animateTime = 2.0;
    
    //内圆的颜色
    chartView.innerColor = [UIColor whiteColor];
    
    //内圆的半径
    chartView.innerCircleR = 10;
    
    //大圆的半径
    chartView.pieRadius = 60;
    
    //整体饼状图的背景色
    chartView.backgroundColor = RGBCOLOR(240, 241, 242, 1.0);
    
    //圆心位置，此属性会被centerXPosition、centerYPosition覆盖，圆心优先使用centerXPosition、centerYPosition
    chartView.centerType = PieCenterTypeTopMiddle;
    
    //是否动画
    chartView.needAnimation = YES;
    
    //动画类型，全部只有一个动画；各个部分都有动画
    chartView.type = PieAnimationTypeTogether;
    
    //圆心，相对于饼状图的位置
    chartView.centerXPosition = 70;
    
    //右侧的文本颜色是否等同于模块的颜色
    chartView.isSameColor = NO;
    
    //文本的行间距
    chartView.textSpace = 20;
    
    //文本的字号
    chartView.textFontSize = 12;
    
    //文本的高度
    chartView.textHeight = 30;
    
    //文本前的颜色块的高度
    chartView.colorHeight = 10;
    
    //文本前的颜色块是否为圆
    chartView.isRound = YES;
    
    //文本距离右侧的间距
    chartView.textRightSpace = 20;
    
    //支持点击事件
    chartView.canClick = YES;
    
    //点击圆饼后的偏移量
    chartView.clickOffsetSpace = 10;
    
    //不隐藏右侧的文本
    chartView.hideText = NO;
    
    //点击触发的block，index与数据源对应
    [chartView clickPieView:^(NSInteger index) {
        NSLog(@"Click Index:%ld",index);
    }];
    
    //添加到视图上
    [chartView showCustomViewInSuperView:self.view];
    
    //设置默认选中的index，如不需要该属性，可注释
    //[chartView setSelectedIndex:2];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    [self loadNewDataArray];
    
    [self loadNewColorArray];
    
    
    NSInteger index = [self getRandomNumber:1 to:16];
    
    if (index == 1) {
        
        //更新半径
        chartView.pieRadius = 70;
        
    }else if (index == 2){
        
        //更新内圆颜色
        chartView.innerColor = [UIColor blackColor];
        
    }else if (index == 3){
        
        //更新内圆半径
        chartView.innerCircleR = 15;
        
        
    }else if (index == 4){
        
        //更新背景色
        chartView.backgroundColor = [UIColor lightGrayColor];
        
        
    }else if (index == 5){
        
        //更新大圆半径
        chartView.pieRadius = 80;
        
        
    }else if (index == 6){
        
        //更新动画类型
        chartView.type = PieAnimationTypeOne;
        
        
    }else if (index == 7){
        
        //更新圆心位置
        chartView.centerXPosition =  80;
        chartView.centerYPosition = 150;
        
    }else if (index == 8){
        
        //更新文本颜色与圆点颜色一致
        chartView.isSameColor = YES;
        
        
    }else if (index == 9){
        
        //更新文本行间距
        chartView.textSpace = 15;
        
        
    }else if (index == 10){
        
        //更新文本高度
        chartView.textHeight = 20;
        
        
    }else if (index == 11){
        
        //更新文本前圆点的高度
        chartView.colorHeight = 15;
        
        
    }else if (index == 12){
        
        //更新文本前的圆点为圆
        chartView.isRound = NO;
        
        
    }else if (index == 13){
        
        //更新文本右侧间距
        chartView.textRightSpace = 5;
        
        
    }else if (index == 14){
        
        //更新点击后的偏移量
        chartView.clickOffsetSpace = 30;
        
    }else if (index == 15){
        
        //移除文本，圆饼居中
        chartView.hideText = YES;
        chartView.pieRadius = 100;
        chartView.centerXPosition = 0;
        chartView.centerYPosition = 0;
        chartView.centerType = PieCenterTypeCenter;
    }
    
    
    [chartView updatePieView];
}

- (void)loadNewDataArray
{
    NSInteger dataCount = [self getRandomNumber:1 to:7];
    
    NSMutableArray *dataArray = [NSMutableArray array];
    
    for (int i = 0; i< dataCount; i++) {
        
        NSInteger value = [self getRandomNumber:1 to:20];
        
        NSString *valueString = [NSString stringWithFormat:@"%ld",value];
        
        [dataArray addObject:valueString];
        
    }
    
    chartView.segmentDataArray = dataArray;
    
}

- (void)loadNewColorArray
{
    NSMutableArray *colorArray = [NSMutableArray array];
    
    for (int i = 0; i< chartView.segmentDataArray.count; i++) {
        
        CGFloat red = [self getRandomNumber:1 to:255];
        CGFloat green = [self getRandomNumber:1 to:255];
        CGFloat blue = [self getRandomNumber:1 to:255];
        
        UIColor *color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0];
        [colorArray addObject:color];
        
    }
    
    chartView.segmentColorArray = colorArray;
    
    
}

- (int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from)));
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
