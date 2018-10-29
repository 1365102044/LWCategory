//
//  TCPClient.m
//  0180406
//
//  Created by 刘文强 on 2018/8/15.
//  Copyright © 2018年 LWQ. All rights reserved.
//

#import "TCPClient.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>

@implementation TCPClient

+ (instancetype)shareTCPClient
{
    static TCPClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TCPClient alloc] init];
    });
    return instance;
}

- (BOOL)connection
{
    //创建socket
    self.clientSocket = -1;
    self.clientSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (self.clientSocket > 0) {
        NSLog(@"连接成功！！");
    }else{
        NSLog(@"连接失败！！");
        return NO;
    }
    
    //建立连接
    struct sockaddr_in serverAddress;
    serverAddress.sin_family = AF_INET;
    serverAddress.sin_port = htons(80);
    
    NSString *ip = [self obtainTCPIpAddressWithHost:@"px.hntpsjwy.com"];
    serverAddress.sin_addr.s_addr = inet_addr(ip.UTF8String);
    
    self.connetResult = connect(_clientSocket, (const struct sockaddr *)&serverAddress, sizeof(serverAddress));
    if (_connetResult == 0) {
        NSLog(@"连接成功！！");
        return YES;
    }else{
        NSLog(@"连接失败！！");
        return NO;
    }
    
}

- (void)sendStringToServerAndReceived:(NSString *)msg
{
    if (self.clientSocket > 0 && self.connetResult >= 0) {
        sigset_t set;
        sigemptyset(&set);
        sigaddset(&set, SIGPIPE);
        sigprocmask(SIG_BLOCK, &set, NULL);
        ssize_t sendLen = send(self.clientSocket, msg.UTF8String, strlen(msg.UTF8String), 0);
        NSLog(@"发送的TCP数据长度 == %ld", sendLen);
        if (sendLen > 0) {
            [self performSelectorInBackground:@selector(readStream) withObject:nil];
        }
    } else {
        //发送的时候如果连接失败，重新连接。
    }
}

//接收数据
- (void)readStream
{
    /**
     第一个int:创建的socket
     void *:  接收内容的地址
     size_t:  接收内容的长度
     第二个int:接收数据的标记 0，就是阻塞式，一直等待服务器的数据
     return:  接收到的数据长度
     */
    char readBuffer[1024] = {0};
    long OrgBr = 0;
    OrgBr = recv(self.clientSocket, readBuffer, sizeof(readBuffer), 0) < sizeof(readBuffer);
    NSLog(@"\nbr = %ld\nReceived Data：%s\n", OrgBr, readBuffer);
    memset(readBuffer, 0, sizeof(readBuffer));
    NSString * readString = [NSString stringWithUTF8String:readBuffer];
    if (readString && ![readString isKindOfClass:[NSNull class]] && readString.length > 0) {
        //接收到的数据 NSString
    } else {
        //重新连接
    }
}

//断开连接
- (void)disConnection {
    
    if (self.clientSocket > 0) {
        close(self.clientSocket);
        self.clientSocket = -1;
    }
}

/**
 更具域名获取ip
 */
- (NSString *)obtainTCPIpAddressWithHost:(NSString *)hostAdd {
    
    NSString * tcpIpStr;
    struct hostent * host_entry = gethostbyname([hostAdd UTF8String]);
    char IPStr[64] = {0};
    if(host_entry != 0) {
        
        sprintf(IPStr, "%d.%d.%d.%d",
                (host_entry->h_addr_list[0][0]&0x00ff),
                (host_entry->h_addr_list[0][1]&0x00ff),
                (host_entry->h_addr_list[0][2]&0x00ff),
                (host_entry->h_addr_list[0][3]&0x00ff));
        
        char * ip = inet_ntoa(*((struct in_addr *)host_entry->h_addr));
        tcpIpStr = [NSString stringWithFormat:@"%s", ip];
        NSLog(@"通过域名得到：%@", tcpIpStr);
    }else {
        tcpIpStr = @"";
        NSLog(@"通过IP得到：%@", tcpIpStr);
    }
    return tcpIpStr;
}
@end
