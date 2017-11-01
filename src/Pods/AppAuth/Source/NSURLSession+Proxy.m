//
//  NSURLSession+Proxy.m
//  AppAuth
//
//  Created by admin on 9/28/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

#import "NSURLSession+Proxy.h"

static NSString* const kMailChatProxyHost = @"g.mailchat.cn";
static NSInteger const kMailChatProxyPort = 9003;

@implementation NSURLSession (Proxy)

+ (NSDictionary *)sessionProxyConfiguration
{
    NSDictionary *proxyDict = @{
                                @"HTTPEnable"  : [NSNumber numberWithInt:1],
                                (NSString *)kCFStreamPropertyHTTPProxyHost  : kMailChatProxyHost,
                                (NSString *)kCFStreamPropertyHTTPProxyPort  : @(kMailChatProxyPort),
                                
                                @"HTTPSEnable" : [NSNumber numberWithInt:1],
                                (NSString *)kCFStreamPropertyHTTPSProxyHost : kMailChatProxyHost,
                                (NSString *)kCFStreamPropertyHTTPSProxyPort : @(kMailChatProxyPort),
                                };
    
    return proxyDict;
}

@end
