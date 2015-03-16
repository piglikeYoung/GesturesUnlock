//
//  ViewController.m
//  手势解锁
//
//  Created by piglikeyoung on 15/3/16.
//  Copyright (c) 2015年 jinheng. All rights reserved.
//

#import "ViewController.h"
#import "JHLockView.h"

@interface ViewController ()<JHLockViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)lockViewDidClick:(JHLockView *)lockView andPwd:(NSString *)pwd
{
    NSLog(@"ViewController %@",pwd);
}

@end
