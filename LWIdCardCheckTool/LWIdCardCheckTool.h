//
//  LWIdCardCheckTool.h
//  HaoYuClient
//
//  Created by 刘文强 on 2018/11/7.
//  Copyright © 2018年 LWQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWIdCardCheckTool : NSObject

/**
 * 验证身份证是否合法
 */
+ (BOOL)validateCard:(NSString *)idCard;

@end
