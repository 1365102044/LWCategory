//
//  UIControl+LWdelay.h
//  HaoYuClient
//
//  Created by 刘文强 on 2018/8/10.
//  Copyright © 2018年 LWQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (LWdelay)
@property (nonatomic, assign) NSTimeInterval lw_acceptEventInterval;   // 可以用这个给重复点击加间隔
@end
