//
//  NSURLSession+Proxy.h
//  AppAuth
//
//  Created by admin on 9/28/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (Proxy)

+ (NSDictionary *)sessionProxyConfiguration;

@end
