//
//  UIControl+LWdelay.m
//  HaoYuClient
//
//  Created by 刘文强 on 2018/8/10.
//  Copyright © 2018年 LWQ. All rights reserved.
//

#import "UIControl+LWdelay.h"
#import <objc/runtime.h>
//增加两个属性
static const char *UIControl_acceptEventInterval = "UIControl_acceptEventInterval";
static const char *UIControl_ignoreEvent = "UIControl_ignoreEvent";

@implementation UIControl (LWdelay)
//时间间隔
- (NSTimeInterval)lw_acceptEventInterval
{
    return [objc_getAssociatedObject(self, UIControl_acceptEventInterval) doubleValue];
}
- (void)setLw_acceptEventInterval:(NSTimeInterval)lw_acceptEventInterval
{
    objc_setAssociatedObject(self, UIControl_acceptEventInterval, @(lw_acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//是否响应事件的标志位
-(BOOL)uxy_ignoreEvent
{
    return [objc_getAssociatedObject(self, UIControl_ignoreEvent) boolValue];
}
-(void)setUxy_ignoreEvent:(BOOL)uxy_ignoreEvent
{
    objc_setAssociatedObject(self, UIControl_ignoreEvent, @(uxy_ignoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
+(void)load
{
    //将系统的sendAction方法和自己实现的方法进行互换
    Method a=class_getInstanceMethod(self,@selector(sendAction:to:forEvent:));
    Method b = class_getInstanceMethod(self,@selector(__lw_sendAction:to:forEvent:));
    method_exchangeImplementations(a,b);
}
//点击后会先进入这里
- (void)__lw_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if (self.uxy_ignoreEvent)//根据状态判断是否继续执行
        return;
    if (self.lw_acceptEventInterval > 0)
    {
        self.uxy_ignoreEvent = YES;
        //周期性清空标志位
        [self performSelector:@selector(setUxy_ignoreEvent:) withObject:@(NO) afterDelay:self.lw_acceptEventInterval];
    }
    //这里其实是系统的原来的sendAction to方法。
    [self __lw_sendAction:action to:target forEvent:event];
}

@end
