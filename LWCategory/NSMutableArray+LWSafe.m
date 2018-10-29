//
//  NSMutableArray+LWSafe.m
//  RunTimeDemo
//
//  Created by 刘文强 on 2018/8/12.
//  Copyright © 2018年 LWQ. All rights reserved.
//

#import "NSMutableArray+LWSafe.h"
#import <objc/runtime.h>
@implementation NSMutableArray (LWSafe)
+ (void)load
{
    Method orig = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(objectAtIndex:));
    Method new = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(safe_objectAtIndex:));

    method_exchangeImplementations(orig, new);
}

- (void)safe_objectAtIndex:(NSUInteger)index
{
    if (self.count == 0 || self.count - 1 < index) {
        @try{
            return [self safe_objectAtIndex:index];
        }
        @catch(NSException *exception){
            NSLog(@"-------- %s Crash Because Method %s -------\n",class_getName(self.class),__func__);
            NSLog(@"%@", [exception callStackSymbols]);
        }
        @finally{}
    }else{
        return [self safe_objectAtIndex:index];
    }
}

@end
