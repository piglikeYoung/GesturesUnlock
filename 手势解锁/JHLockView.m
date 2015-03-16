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
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        // 2.设置按钮的背景图片
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
        
        // 3.添加按钮到view
        [self addSubview:btn];
        
        btn.backgroundColor = [UIColor redColor];
        
        // 4.禁止按钮的点击事件（因为我们需要监听触摸事件）
        btn.userInteractionEnabled = NO;
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
    //   UITouch *touch =  [touches anyObject];
    //   CGPoint startPoint = [touch locationInView:touch.view];
    
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
    
    // 通知view绘制线段
    [self setNeedsDisplay];
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
    
    [[UIColor greenColor] set];
    CGContextSetLineWidth(ctx, 10);
    CGContextStrokePath(ctx);
}

@end
