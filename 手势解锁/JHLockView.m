//
//  JHLockView.m
//  手势解锁
//
//  Created by piglikeyoung on 15/3/16.
//  Copyright (c) 2015年 jinheng. All rights reserved.
//

#import "JHLockView.h"

@interface JHLockView()

@property (strong , nonatomic) NSMutableArray *buttons;
/**
 *  定义属性,记录用户当前手指的位置(非按钮范围内)
 */
@property (assign , nonatomic) CGPoint currentPoint;

@end

@implementation JHLockView

-(NSMutableArray *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

// 当视图是通过代码创建出来的就会调用initWithFrame
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

// 当视图从xib或storyboard中创建出来就会调用
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    
    return self;
}

/**
 *   创建9个按钮添加到自定view中
 */
-(void)setup
{
    for (int i = 0; i < 9; i++) {
        // 1.创建按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        // 2.设置按钮的背景图片
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
        
        // 3.添加按钮到view
        [self addSubview:btn];
        
        //btn.backgroundColor = [UIColor redColor];
        
        // 4.禁止按钮的点击事件（因为我们需要监听触摸事件）
        btn.userInteractionEnabled = NO;
        
        // 5.设置按钮的tag作为唯一标识
        btn.tag = i;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    // 设置按钮的frame
    for (int i = 0; i < self.subviews.count; i++) {
        // 1.取出对应位置的按钮
        UIButton *btn = self.subviews[i];
        
        // 2.设置frame
        CGFloat btnW = 74;
        CGFloat btnH = 74;
        // 2.1计算间距
        CGFloat margin = (self.frame.size.width - (3 * btnW)) / 4;
        int col = i % 3; // 列号
        int row = i / 3; // 行号
        // 间距 + 列号 * (按钮宽度+ 间距)
        CGFloat btnX = margin + col * (btnW + margin);
        CGFloat btnY = margin + row * (btnW + margin);
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 1.获取按下的点
    CGPoint startPoint = [self getCurrentTouchPoint:touches];
    
    // 2.判断触摸的位置是否在按钮的范围内
    UIButton *btn = [self getCurrentBtnWithPoint:startPoint];
    
    // 存储按钮
    if (btn) {
        // 设置选中状态
        btn.selected = YES;
        // 将按钮保存到数组中
        [self.buttons addObject:btn];
    }
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 1.获取按下的点
    CGPoint movePoint = [self getCurrentTouchPoint:touches];
    // 2.获取触摸的按钮
    UIButton *btn = [self getCurrentBtnWithPoint:movePoint];
    
    // 存储按钮
    if (btn && btn.selected != YES) {
        // 设置选中状态
        btn.selected = YES;
        // 将按钮保存到数组中
        [self.buttons addObject:btn];
    }
    
    // 记录当前手指移动位置
    self.currentPoint = movePoint;
    
    // 通知view绘制线段
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 取出用户输入的密码
    NSMutableString *result = [NSMutableString string];
    for (UIButton *btn in self.buttons) {
        [result appendFormat:@"%d",btn.tag];
    }
    
    // 通知代理,告诉代理用户输入的密码
    if ([self.delegate respondsToSelector:@selector(lockViewDidClick:andPwd:)]) {
        [self.delegate lockViewDidClick:self andPwd:result];
    }
    
    // 当手指离开屏幕所有的按钮都不选中
    // 本方法是数组里的每一个元素都调用同一个方法
    [self.buttons makeObjectsPerformSelector:@selector(setSelected:) withObject:@(NO)];
    
    // 清空数组
    [self.buttons removeAllObjects];
    [self setNeedsDisplay];
    
    // 清空currentPoint
    self.currentPoint = CGPointZero;
}

/**
 *  根据系统传入的UITouch集合获取当前触摸的点
 *  @return 当初触摸的点
 */
-(CGPoint)getCurrentTouchPoint:(NSSet *)touches
{
    // 1.获取按下的点
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    return point;
}


/**
 *  根据触摸点获取触摸到的按钮
 *  @return 触摸的按钮
 */
-(UIButton *)getCurrentBtnWithPoint:(CGPoint) point
{
    // 2.判断触摸的位置是否在按钮的范围内
    for (UIButton *btn in self.subviews) {
        if (CGRectContainsPoint(btn.frame, point)) {
            return btn;
        }
    }
    return nil;
}

-(void) drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 清空上下文
    CGContextClearRect(ctx, rect);
    
    // 从数组中取出所有的按钮，连接所有按钮的中点
    for (int i = 0; i < self.buttons.count; i++) {
        // 取出按钮
        UIButton *btn = self.buttons[i];
        if (0 == i) {
            CGContextMoveToPoint(ctx, btn.center.x, btn.center.y);
        }else{
            CGContextAddLineToPoint(ctx, btn.center.x, btn.center.y);
        }
    }
    
    // 判断数组中是否有按钮, 如果有按钮就有起点, 有起点就不会报错,针对穿出的线段,没点击按钮之前不应该有穿出的线段
    if (self.buttons.count != 0) {
        CGContextAddLineToPoint(ctx, self.currentPoint.x, self.currentPoint.y);
    }
    
//    [[UIColor greenColor] set];
    
    [[UIColor colorWithRed:18/255.0 green:102/255.0 blue:72/255.0 alpha:1] set];
    CGContextSetLineWidth(ctx, 10);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextStrokePath(ctx);
}

@end
