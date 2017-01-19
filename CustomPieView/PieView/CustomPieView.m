//
//  CustomPieView.m
//  TestPieView
//
//  Created by 龙培 on 16/12/12.
//  Copyright © 2016年 龙培. All rights reserved.
//
// 下载与使用详细地址https://github.com/Coolll/CustomPieView

#import "CustomPieView.h"
#import "CustomShapeLayer.h"

typedef void(^ClickBlock)(NSInteger clickIndex);

@interface CustomPieView ()
{
    //饼状图的实际半径
    CGFloat realRadius;

    //饼状图 array
    NSMutableArray *pieShapeLayerArray;
    
    //各个部分的coverLayer
    NSMutableArray *segmentCoverLayerArray;
    
    //各个部分的path
    NSMutableArray *segmentPathArray;
    
    //半径
    CGFloat pieR;
    
    //圆心
    CGPoint pieCenter;
    
    //内部的小圆
    CAShapeLayer *whiteLayer;
}

@property (nonatomic,strong) CAShapeLayer *coverCircleLayer;

/**
 *  最终的文本数组
 **/
@property (nonatomic,strong) NSMutableArray *finalTextArray;

/**
 *  颜色块的位置
 **/
@property (nonatomic,assign) CGPoint colorRightOriginPoint;

/**
 *  实际的文本字号
 **/
@property (nonatomic,assign) CGFloat realTextFont;

/**
 *  实际的文本高度
 **/
@property (nonatomic,assign) CGFloat realTextHeight;
/**
 *  实际的文本间距
 **/
@property (nonatomic,assign) CGFloat realTextSpace;
/**
 *  小圆点数组
 **/
@property (nonatomic,strong) NSMutableArray *colorPointArray;
/**
 *  点击圆饼的index的block
 **/
@property (nonatomic,copy) ClickBlock clickBlock;



@end

@implementation CustomPieView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    if (!self.hideText) {
        
        [self drawRightText];

    }
    
}

#pragma mark - 绘制右侧的文本

- (void)drawRightText
{
    CGFloat viewWidth = self.bounds.size.width;
    
    CGFloat colorHeight = [self preferGetUserSetValue:self.colorHeight withDefaultValue:self.realTextHeight];
    
    CGFloat textX = self.colorRightOriginPoint.x+colorHeight;//文本前面有一个颜色方块／圆
    CGFloat textY = self.colorRightOriginPoint.y;
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    
    for (int i = 0; i< self.finalTextArray.count; i++) {
        
        NSString *content = self.finalTextArray[i];
        
        UIColor *textColor = [UIColor blackColor];
        
        if (self.isSameColor) {
            
            if (i< self.segmentColorArray.count) {
                textColor = self.segmentColorArray[i];
            }
        }
        
        
        CGFloat textUseHeight = [self heightForTextString:content width:1000 fontSize:self.realTextFont];
        CGFloat textOffset = (self.realTextHeight - textUseHeight)/2;
        
        attrs[NSForegroundColorAttributeName] = textColor;
        attrs[NSFontAttributeName] = [UIFont systemFontOfSize:self.realTextFont];
        
        [content drawInRect:CGRectMake(textX, textY+self.realTextSpace*i+self.realTextHeight*i+textOffset, viewWidth-textX, self.realTextHeight) withAttributes:attrs];
        
        
        
    }
    

}


#pragma mark - 调用的加载和刷新方法
- (void)updatePieView
{
    [whiteLayer removeFromSuperlayer];
    
    for (CAShapeLayer *layer in pieShapeLayerArray) {
        [layer removeFromSuperlayer];
    }
    
    for (CAShapeLayer *layer in self.colorPointArray) {
        [layer removeFromSuperlayer];
    }
    
    [self.colorPointArray removeAllObjects];
    [pieShapeLayerArray removeAllObjects];
    [segmentPathArray removeAllObjects];
    [segmentCoverLayerArray removeAllObjects];
    
    
    
    [self setNeedsDisplay];
    
    if (!self.needAnimation) {
        
        [self loadNoAnimation];
        return;
    }
    
    if (self.type == PieAnimationTypeTogether) {
        
        [self loadTogetherAnimation];
        
    }else{
        
        [self loadOneAnimation];
    }
    
}

- (void)showCustomViewInSuperView:(UIView*)superView
{
    pieShapeLayerArray = [NSMutableArray array];
    segmentPathArray = [NSMutableArray array];
    segmentCoverLayerArray = [NSMutableArray array];
    self.colorPointArray = [NSMutableArray array];
    
    if (!self.segmentColorArray) {
        self.segmentColorArray = [self loadRandomColorArray];
    }
    
    [superView addSubview:self];
    
    if (!self.needAnimation) {
        
        [self loadNoAnimation];
        return;
    }
    
    if (self.type == PieAnimationTypeTogether) {
        
        [self loadTogetherAnimation];
        
    }else{
        
        [self loadOneAnimation];
    }

}

#pragma mark - 单个动画的饼状图

- (void)loadOneAnimation
{
    if (!self.hideText) {
        
        [self loadTextContent];

    }
    
    [self loadPieView];
    
    [self doCustomAnimation];
}


#pragma mark - 同时动画的饼状图

- (void)loadTogetherAnimation
{
    if (!self.hideText) {
        
        [self loadTextContent];

    }
    
    [self loadCustomPieView];
    
    [self doSegmentAnimation];
    
}

#pragma mark -  无动画的饼状图

- (void)loadNoAnimation
{
    [self loadTextContent];
    
    [self loadPieView];
}



#pragma mark - 加载文本并调整饼状图中心

- (void)loadTextContent
{
    [self loadFinalText];
    
    self.centerType = PieCenterTypeMiddleLeft;
            
    [self loadRightTextAndColor];
}


#pragma mark - 处理展示的文本

- (void)loadFinalText
{
    
    self.realTextHeight = [self preferGetUserSetValue:self.textHeight withDefaultValue:20];
    
    self.realTextFont = [self preferGetUserSetValue:self.textFontSize withDefaultValue:14];
    
    self.realTextSpace = [self preferGetUserSetValue:self.textSpace withDefaultValue:10];

    
    //数据总值
    CGFloat totalValue = 0;
    
    for (NSString *valueString in self.segmentDataArray) {
        
        totalValue += [valueString floatValue];
    }
    
    

    self.finalTextArray = [NSMutableArray array];
    
    
    for ( int i = 0 ;i < self.segmentDataArray.count;i++) {
        
        //数据文本
        NSString *valueString = self.segmentDataArray[i];
        
        //数据值
        CGFloat value = [valueString floatValue];
        
        //当前数值的占比
        CGFloat rate = value/totalValue;
        
        
        NSString *titleString = @"其他";
        
        if (i < self.segmentTitleArray.count) {
         
            titleString = self.segmentTitleArray[i];
        }
        
        
        NSString *finalString = [NSString stringWithFormat:@" %@:%.1f %.1f％",titleString,value,rate*100];

        
        [self.finalTextArray addObject:finalString];
        
    }
    
    
    
    
    
}

#pragma mark - 计算右侧显示文本的frame

- (void)loadRightTextAndColor
{
    
    CGFloat viewHeight = self.bounds.size.height;
    
    CGFloat viewWidth = self.bounds.size.width;
    
    
    
    CGFloat maxWidth = 0;
    
    for ( int i = 0 ;i < self.finalTextArray.count;i++) {
        
        //文本
        NSString *valueString = self.finalTextArray[i];
        
        
        CGFloat finalWidth = [self widthForTextString:valueString height:self.realTextHeight fontSize:self.realTextFont];
        
        if (finalWidth > maxWidth) {
            
            maxWidth = finalWidth;
        }
        
        
    }
    
    CGFloat colorHeight = [self preferGetUserSetValue:self.colorHeight withDefaultValue:self.realTextHeight];

    CGFloat textRightSpace = [self preferGetUserSetValue:self.textRightSpace withDefaultValue:0];
    
    CGFloat colorOriginX = viewWidth - maxWidth-colorHeight-textRightSpace;
    
    CGFloat colorOriginY = (viewHeight-(self.realTextHeight*self.finalTextArray.count+self.realTextSpace*(self.finalTextArray.count-1)))/2;
    
    self.colorRightOriginPoint = CGPointMake(colorOriginX, colorOriginY);
    
    
    
    for (int i = 0; i< self.finalTextArray.count; i++) {
        //颜色方块
        CAShapeLayer *colorLayer = [CAShapeLayer layer];
        
        CGFloat spaceHeight = (self.realTextHeight-colorHeight)/2;
        
        colorLayer.frame = CGRectMake(colorOriginX, colorOriginY+self.realTextSpace*i+self.realTextHeight*i+spaceHeight, colorHeight, colorHeight);
        
        
        UIColor *segColor = [UIColor cyanColor];
        
        if (i < self.segmentColorArray.count) {
            
            segColor = self.segmentColorArray[i];
        }
        
        colorLayer.backgroundColor = segColor.CGColor;
        
        
        if (self.isRound) {
            
            colorLayer.cornerRadius = colorHeight/2;
        }
        
        [self.colorPointArray addObject:colorLayer];
        
        [self.layer addSublayer:colorLayer];
        
        
        
    }
    
    

}

#pragma mark - 计算文本的宽、高

- (CGFloat) widthForTextString:(NSString *)tStr height:(CGFloat)tHeight fontSize:(CGFloat)tSize{
    
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:tSize]};
    CGRect rect = [tStr boundingRectWithSize:CGSizeMake(MAXFLOAT, tHeight) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.width+5;
    
}

//计算label的高度
- (CGFloat)heightForTextString:(NSString*)vauleString width:(CGFloat)textWidth fontSize:(CGFloat)textSize
{
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:textSize]};
    CGRect rect = [vauleString boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine attributes:dict context:nil];
    return rect.size.height ;
}

#pragma mark - 加载同时动画的饼状图


- (void)loadCustomPieView
{
    
    //半径
    pieR = [self preferGetUserSettingRadiusValue];
    //圆心
    [self loadPieCenter];
    
    if (self.centerXPosition > 0  ) {
        
        pieCenter = CGPointMake(self.centerXPosition, pieCenter.y);
    }
    
    if (self.centerYPosition > 0 ) {
        
        pieCenter = CGPointMake(pieCenter.x, self.centerYPosition);
        
    }
    
    //数据总值
    CGFloat totalValue = 0;
    //当前开始的弧度,这里初始的角度要和self.coverCircleLayer遮罩的初始角度一致，否则，颜色模块会被分割开
    CGFloat currentRadian = -M_PI/2;
    
    for (NSString *valueString in self.segmentDataArray) {
        
        totalValue += [valueString floatValue];
    }
    
    
    CGFloat offset = [self preferGetUserSetValue:self.clickOffsetSpace withDefaultValue:15];

    CGFloat innerWhiteRadius = [self preferGetUserSetInnerRadiusValue:self.innerCircleR withDefaultValue:pieR/3];
    UIColor *innerColor = [self preferGetUserSetColor:self.innerColor withDefaultColor:[UIColor whiteColor]];

    
    for ( int i = 0 ;i < self.segmentDataArray.count;i++) {
        
        
        //数据文本
        NSString *valueString = self.segmentDataArray[i];
        
        //数据值
        CGFloat value = [valueString floatValue];
        
        //根据当前数值的占比，计算得到当前的弧度
        CGFloat radian = [self loadPercentRadianWithCurrent:value withTotalValue:totalValue];
        
        //弧度结束值 初始值＋当前弧度
        CGFloat endAngle = currentRadian+radian;
        
        
        //贝塞尔曲线
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:pieCenter];
        //圆弧 默认最右端为0，YES时为顺时针。NO时为逆时针。
        [path addArcWithCenter:pieCenter radius:pieR startAngle:currentRadian endAngle:endAngle clockwise:YES];
        [path addArcWithCenter:pieCenter radius:innerWhiteRadius startAngle:endAngle endAngle:currentRadian clockwise:NO];

        //添加到圆心直线
        [path addLineToPoint:pieCenter];
        //路径闭合
        [path closePath];
        
        //当前shapeLayer的遮罩
        UIBezierPath *coverPath = [UIBezierPath bezierPathWithArcCenter:pieCenter radius:pieR/2+offset startAngle:currentRadian endAngle:endAngle clockwise:YES];
        [segmentPathArray addObject:coverPath];
        
        
        
        
        //初始化Layer
        CustomShapeLayer *radiusLayer = [CustomShapeLayer layer];
        //设置layer的路径
        radiusLayer.centerPoint = pieCenter;
        radiusLayer.startAngle = currentRadian;
        radiusLayer.endAngle = endAngle;
        radiusLayer.radius = pieR;
        radiusLayer.innerColor = innerColor;
        radiusLayer.innerRadius = innerWhiteRadius;
        radiusLayer.path = path.CGPath;

        //下一个弧度开始位置为当前弧度的结束位置
        currentRadian = endAngle;
        

        //默认cyan颜色
        UIColor *currentColor = [UIColor cyanColor];
        
        if (i < self.segmentColorArray.count) {
            
            currentColor = self.segmentColorArray[i];
        }
        
        radiusLayer.fillColor = CGColorCreateCopyWithAlpha(currentColor.CGColor, 1.0);
        [pieShapeLayerArray addObject:radiusLayer];
        
        [self.layer addSublayer:radiusLayer];
        
    }
    
    
    
    
    
    for (int i = 0;i < segmentPathArray.count ;i++) {
        UIBezierPath *path = segmentPathArray[i];
        CAShapeLayer *originLayer = pieShapeLayerArray[i];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.lineWidth = pieR+offset*2;
        layer.strokeStart = 0;
        layer.strokeEnd = 0;
        layer.strokeColor = [UIColor blackColor].CGColor;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.path = path.CGPath;
        originLayer.mask = layer;

        [segmentCoverLayerArray addObject:layer];
        
    }

    
    
    UIBezierPath *whitePath = [UIBezierPath bezierPathWithArcCenter:pieCenter radius:innerWhiteRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    whiteLayer = [CAShapeLayer layer];
    whiteLayer.path = whitePath.CGPath;
    whiteLayer.fillColor = innerColor.CGColor;
    [self.layer addSublayer:whiteLayer];
    

}

- (void)doSegmentAnimation
{
    
    for (CAShapeLayer *layer in segmentCoverLayerArray) {
        
        [self doCustomAnimationWithLayer:layer];
    }
}

- (void)doCustomAnimationWithLayer:(CAShapeLayer*)layer
{
    CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeAnimation.fromValue = @(0);
    
    if (_animateTime >0 ) {
        strokeAnimation.duration = _animateTime;
        
    }else{
        strokeAnimation.duration = 4;
    }
    
    strokeAnimation.toValue = @(1);
    strokeAnimation.autoreverses = NO; //有无自动恢复效果
    strokeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    strokeAnimation.removedOnCompletion = YES;
    [layer addAnimation:strokeAnimation forKey:@"strokeEndAnimation"];
    layer.strokeEnd = 1;
}



#pragma mark 加载一个动画的饼状图

- (void)loadPieView
{
    //放置layer的主layer，如果没有这个layer，那么设置背景色就无效了，因为被mask了。
    CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
    backgroundLayer.frame = self.bounds;
    [self.layer addSublayer:backgroundLayer];
    
    
    //半径
    pieR = [self preferGetUserSettingRadiusValue];
    //圆心
    [self loadPieCenter];
    
    if (self.centerXPosition >0  ) {
        
        pieCenter = CGPointMake(self.centerXPosition, pieCenter.y);
    }
    
    if (self.centerYPosition >0 ) {
        
        pieCenter = CGPointMake(pieCenter.x, self.centerYPosition);
        
    }

    
    //数据总值
    CGFloat totalValue = 0;
    //当前开始的弧度,这里初始的角度要和self.coverCircleLayer遮罩的初始角度一致，否则，颜色模块会被分割开
    CGFloat currentRadian = -M_PI/2;
    
    for (NSString *valueString in self.segmentDataArray) {
        
        totalValue += [valueString floatValue];
    }
    
    CGFloat offset = [self preferGetUserSetValue:self.clickOffsetSpace withDefaultValue:15];
    CGFloat innerWhiteRadius = [self preferGetUserSetInnerRadiusValue:self.innerCircleR withDefaultValue:pieR/3];
    UIColor *innerColor = [self preferGetUserSetColor:self.innerColor withDefaultColor:[UIColor whiteColor]];
    
    for ( int i = 0 ;i < self.segmentDataArray.count;i++) {
        
        //数据文本
        NSString *valueString = self.segmentDataArray[i];
        
        //数据值
        CGFloat value = [valueString floatValue];
        
        //根据当前数值的占比，计算得到当前的弧度
        CGFloat radian = [self loadPercentRadianWithCurrent:value withTotalValue:totalValue];
        
        //弧度结束值 初始值＋当前弧度
        CGFloat endAngle = currentRadian+radian;
        
        
        //贝塞尔曲线
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:pieCenter];
        //圆弧 默认最右端为0，YES时为顺时针。NO时为逆时针。
        [path addArcWithCenter:pieCenter radius:pieR startAngle:currentRadian endAngle:endAngle clockwise:YES];
        [path addArcWithCenter:pieCenter radius:innerWhiteRadius startAngle:endAngle endAngle:currentRadian clockwise:NO];

        //添加到圆心直线
        [path addLineToPoint:pieCenter];
        //路径闭合
        [path closePath];
        
        //初始化Layer
        CustomShapeLayer *radiusLayer = [CustomShapeLayer layer];
        //设置layer的路径
        radiusLayer.centerPoint = pieCenter;
        radiusLayer.startAngle = currentRadian;
        radiusLayer.endAngle = endAngle;
        radiusLayer.radius = pieR;
        radiusLayer.innerColor = innerColor;
        radiusLayer.innerRadius = innerWhiteRadius;
        radiusLayer.path = path.CGPath;

        //下一个弧度开始位置为当前弧度的结束位置
        currentRadian = endAngle;
        

        //默认cyan颜色
        UIColor *currentColor = [UIColor cyanColor];
        
        if (i < self.segmentColorArray.count) {
            
            currentColor = self.segmentColorArray[i];
        }
        
        radiusLayer.fillColor = CGColorCreateCopyWithAlpha(currentColor.CGColor, 1.0);
        [pieShapeLayerArray addObject:radiusLayer];
        
        [backgroundLayer addSublayer:radiusLayer];
        
    }
    
    


    
    
//    CGFloat offset = [self preferGetUserSetValue:self.clickOffsetSpace withDefaultValue:15];
    
    //贝塞尔曲线
    UIBezierPath *innerPath = [UIBezierPath bezierPath];
    //圆弧 默认最右端为0，YES时为顺时针。NO时为逆时针。
    [innerPath addArcWithCenter:pieCenter radius:pieR/2+offset startAngle:-M_PI/2 endAngle:M_PI*3/2 clockwise:YES];
    
    
    //初始化Layer
    self.coverCircleLayer = [CAShapeLayer layer];
    //设置layer的路径
    self.coverCircleLayer.lineWidth = pieR+offset*2;
    self.coverCircleLayer.strokeStart = 0;
    self.coverCircleLayer.strokeEnd = 1;
    //Must 如果stroke没有颜色，那么动画没法进行了
    self.coverCircleLayer.strokeColor = [UIColor blackColor].CGColor;
    //决定内部的圆是否显示,如果clearColor，则不会在动画开始时就有各个颜色的、完整的内圈。
    self.coverCircleLayer.fillColor = [UIColor clearColor].CGColor;
    self.coverCircleLayer.path = innerPath.CGPath;
    [backgroundLayer setMask:self.coverCircleLayer];

    
    
    
    //内圈的小圆
    UIBezierPath *whitePath = [UIBezierPath bezierPathWithArcCenter:pieCenter radius:innerWhiteRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    whiteLayer = [CAShapeLayer layer];
    whiteLayer.path = whitePath.CGPath;
    whiteLayer.fillColor = innerColor.CGColor;
    [self.layer addSublayer:whiteLayer];
    
    
    
}


- (void)doCustomAnimation
{
    CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeAnimation.fromValue = @(0);
    
    if (_animateTime >0 ) {
        strokeAnimation.duration = _animateTime;
        
    }else{
        strokeAnimation.duration = 4;
    }
    
    strokeAnimation.toValue = @(1);
    strokeAnimation.autoreverses = NO; //有无自动恢复效果
    strokeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    strokeAnimation.removedOnCompletion = YES;
    [_coverCircleLayer addAnimation:strokeAnimation forKey:@"strokeEndAnimation"];

    _coverCircleLayer.strokeEnd = 1;
}


#pragma mark - 点击事件

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //不能点击则不做处理了
    if (!self.canClick) {
        return;
    }
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    for (CustomShapeLayer *shapeLayer in pieShapeLayerArray) {
        
        //如果只有一个模块，那么动画就要变化了，不是简单的偏移了
        if (self.segmentDataArray.count == 1) {
            shapeLayer.isOneSection = YES;
        }

        
        //判断选择区域
        shapeLayer.clickOffset =  [self preferGetUserSetValue:self.clickOffsetSpace withDefaultValue:15];

        if (CGPathContainsPoint(shapeLayer.path, 0, touchPoint, YES)) {
            
            //修改选中状态
            if (shapeLayer.isSelected) {
                
                shapeLayer.isSelected = NO;
            }else{
                shapeLayer.isSelected = YES;
                
            }
            
            NSInteger index = [pieShapeLayerArray indexOfObject:shapeLayer];
            
            //执行block并开始右侧小圆点动画
            [self dealClickCircleWithIndex:index];
            

        } else {
            
            shapeLayer.isSelected = NO;
        }
    }
}

- (void)dealClickCircleWithIndex:(NSInteger)index
{
    if (self.clickBlock) {
        self.clickBlock(index);
    }
    
    if (index < self.colorPointArray.count) {

        CAShapeLayer *layer = self.colorPointArray[index];
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.values = @[@0.9,@2.0,@1.5,@0.7,@1.3,@1.0];
        animation.calculationMode = kCAAnimationCubic;
        animation.duration = 0.8;
        [layer addAnimation:animation forKey:@"scaleAnimation"];

    }

}

- (void)clickPieView:(void(^)(NSInteger index))clickBlock
{
    if (clickBlock) {
        self.clickBlock =clickBlock;
    }
}


#pragma mark - 圆心处理

- (void)loadPieCenter
{
    CGFloat viewHeight = self.bounds.size.height;
    CGFloat viewWidth = self.bounds.size.width;
    
    //圆心
    pieCenter = CGPointMake(viewWidth/2, viewHeight/2);


    
    switch (self.centerType) {
        case PieCenterTypeCenter:
        {
            //圆心
            pieCenter = CGPointMake(viewWidth/2, viewHeight/2);
            
        }
            break;
        case PieCenterTypeTopLeft:
        {
            //圆心
            pieCenter = CGPointMake(pieR, pieR);
            
        }
            break;
        case PieCenterTypeTopMiddle:
        {
            //圆心
            pieCenter = CGPointMake(viewWidth/2, pieR);
            
        }
            break;
        case PieCenterTypeTopRight:
        {
            //圆心
            pieCenter = CGPointMake(viewWidth-pieR, pieR);
            
        }
            break;
        case PieCenterTypeMiddleLeft:
        {
            //圆心
            pieCenter = CGPointMake(pieR, viewHeight/2);
            

        }
            break;
        case PieCenterTypeMiddleRight:
        {
            //圆心
            pieCenter = CGPointMake(viewWidth-pieR, viewHeight/2);
            
        }
            break;
        case PieCenterTypeBottomLeft:
        {
            //圆心
            pieCenter = CGPointMake(pieR, viewHeight-pieR);
            
        }
            break;
        case PieCenterTypeBottomMiddle:
        {
            //圆心
            pieCenter = CGPointMake(viewWidth/2, viewHeight-pieR);
            

        }
            break;
        case PieCenterTypeBottomRight:
        {
            //圆心
            pieCenter = CGPointMake(viewWidth-pieR, viewHeight-pieR);
            

        }
            break;
    
            break;
        default:
            break;
    }
}

- (NSMutableArray*)loadRandomColorArray
{
    NSMutableArray *colorArray = [NSMutableArray array];
    
    for (int i = 0; i< self.segmentDataArray.count; i++) {
        
        
        UIColor *color = [self loadRandomColor];
        
        [colorArray addObject:color];
        
    }
    

    return colorArray;
    
}

- (UIColor *)loadRandomColor
{
    CGFloat red = [self getRandomNumber:1 to:255];
    CGFloat green = [self getRandomNumber:1 to:255];
    CGFloat blue = [self getRandomNumber:1 to:255];
    
    UIColor *color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0];
    
    return color;
}

- (int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from)));
}



#pragma mark - 根据百分比 分配弧度

- (CGFloat)loadPercentRadianWithCurrent:(CGFloat)current withTotalValue:(CGFloat)total
{
    CGFloat percent = current/total;
    
    return percent*M_PI*2;
}

#pragma  mark 优先获取用户设置的圆饼半径
- (CGFloat)preferGetUserSettingRadiusValue
{
    CGFloat viewHeight = self.bounds.size.height;
    CGFloat viewWidth = self.bounds.size.width;
    
    CGFloat minValue = viewWidth > viewHeight? viewHeight:viewWidth;
    
    
    //圆饼的半径
   CGFloat pieRadius = 0;
    
    if (self.pieRadius > 0) {
        //如果设置了圆饼的半径
        pieRadius = self.pieRadius;
        
        //如果设置的圆饼半径太大，则取能显示的最大值
        if (pieRadius > minValue/2) {
            
            pieRadius = minValue/2;
        }
        
    }else{
        //如果没有设置圆饼的半径
        pieRadius = minValue/2;
    }
    
    return pieRadius;
}

- (CGFloat)preferGetUserSetInnerRadiusValue:(CGFloat)userValue withDefaultValue:(CGFloat)defaultValue
{
    if (userValue >= 0 ) {
        return userValue;
    }else{
        
        return defaultValue;
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

- (UIColor*)preferGetUserSetColor:(UIColor*)userColor withDefaultColor:(UIColor*)defaultColor
{
    if (userColor) {
        return userColor;
    }else{
        return defaultColor;
    }
}

@end
