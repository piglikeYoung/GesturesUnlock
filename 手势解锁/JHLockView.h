//
//  JHLockView.h
//  手势解锁
//
//  Created by piglikeyoung on 15/3/16.
//  Copyright (c) 2015年 jinheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JHLockView;

@protocol JHLockViewDelegate <NSObject>

- (void) lockViewDidClick:(JHLockView *)lockView andPwd:(NSString *)pwd;

@end

@interface JHLockView : UIView

@property (weak , nonatomic) IBOutlet id<JHLockViewDelegate> delegate;

@end
