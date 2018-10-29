//
//  TCPClient.h
//  0180406
//
//  Created by 刘文强 on 2018/8/15.
//  Copyright © 2018年 LWQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPClient : NSObject
@property (nonatomic, assign) int clientSocket;
@property (nonatomic, assign) int connetResult;

+ (instancetype)shareTCPClient;

//域名 eg:www.baidu.com   端口:8080
- (BOOL)connection;

- (void)sendStringToServerAndReceived:(NSString *)message;

- (void)disConnection;

@end
