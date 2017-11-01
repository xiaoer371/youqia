//
//  MCJSApiManager.h
//  NPushMail
//
//  Created by admin on 3/24/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCJSApiManager : NSObject

- (instancetype)initWithWebView:(UIWebView *)webView;

/**
 *  处理url 请求
 *
 *  @param request 待处理的url
 *
 *  @return YES 表示api 有处理，NO表示 api 不需要处理
 */
- (BOOL)handleRequest:(NSURLRequest *)request;

@end
