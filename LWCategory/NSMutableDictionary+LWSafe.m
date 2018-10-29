//
//  NSMutableDictionary+safe.m
//  RunTimeDemo
//
//  Created by 刘文强 on 2018/8/12.
//  Copyright © 2018年 LWQ. All rights reserved.
//

#import "NSMutableDictionary+LWSafe.h"
#import <objc/runtime.h>

@implementation NSMutableDictionary (LWSafe)

+ (void)load {
    Method fromMethod = class_getInstanceMethod(objc_getClass("__NSDictionaryM"), @selector(setObject:forKey:));
    Method toMethod = class_getInstanceMethod(objc_getClass("__NSDictionaryM"), @selector(em_setObject:forKey:));
    method_exchangeImplementations(fromMethod, toMethod);
}

- (void)em_setObject:(id)emObject forKey:(NSString *)key {
    if (emObject == nil) {
        @try {
            [self em_setObject:emObject forKey:key];
        }
        @catch (NSException *exception) {
            NSLog(@"---------- %s Crash Because Method %s  ----------\n", class_getName(self.class), __func__);
            NSLog(@"%@", [exception callStackSymbols]);
            emObject = [NSString stringWithFormat:@""];
            [self em_setObject:emObject forKey:key];
        }
        @finally {}
    }else {
        [self em_setObject:emObject forKey:key];
    }
}



@end
