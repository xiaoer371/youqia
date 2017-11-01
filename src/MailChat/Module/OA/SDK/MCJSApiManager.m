//
//  MCJSApiManager.m
//  NPushMail
//
//  Created by admin on 3/24/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCJSApiManager.h"
#import "MCGetDeviceIdApi.h"
#import "MCCheckJsApi.h"
#import "MCGetLocationApi.h"
#import "MCAuthExpireApi.h"
#import "MCShowBackButtonApi.h"
#import "MCSetNavTitleApi.h"
#import "MCSetNavRightButtonsApi.h"
#import "MCGetTokenApi.h"
#import "MCOnFunctionApi.h"

@interface MCJSApiManager ()

@property (nonatomic,weak) UIWebView *webView;
@property (nonatomic,strong) NSMutableDictionary *apiHandlers;

@end

@implementation MCJSApiManager

- (instancetype)initWithWebView:(UIWebView *)webView
{
    if (self = [super init]) {
        _webView = webView;
        
        _apiHandlers = [NSMutableDictionary new];
        
        MCJSApi *api = [MCGetDeviceIdApi new];
        [_apiHandlers setObject:api forKey:api.name];
        
        api = [MCGetLocationApi new];
        [_apiHandlers setObject:api forKey:api.name];
        
        api = [MCAuthExpireApi new];
        [_apiHandlers setObject:api forKey:api.name];
        
        api = [MCShowBackButtonApi new];
        [_apiHandlers setObject:api forKey:api.name];
        
        api = [MCSetNavTitleApi new];
        [_apiHandlers setObject:api forKey:api.name];
        
        api = [MCSetNavRightButtonsApi new];
        [_apiHandlers setObject:api forKey:api.name];
        
        api = [MCGetTokenApi new];
        [_apiHandlers setObject:api forKey:api.name];
        
        api = [MCOnFunctionApi new];
        [_apiHandlers setObject:api forKey:api.name];

        // 检查的方法必须放在最后，才能知道所有的方法
        api = [[MCCheckJsApi alloc] initWithHanlders:_apiHandlers];
        [_apiHandlers setObject:api forKey:api.name];
        
    }
    return self;
}

- (BOOL)handleRequest:(NSURLRequest *)request
{
    NSString *requestString = [[request URL] absoluteString];
    
    NSLog(@"request : %@",requestString);
    
    if ([requestString hasPrefix:@"mc:"]) {
        
        NSArray *components = [requestString componentsSeparatedByString:@":"];
        
        NSString *function = (NSString*)[components objectAtIndex:1];
        NSString *callbackId = ((NSString*)[components objectAtIndex:2]);
        NSString *argsAsString = [(NSString*)[components objectAtIndex:3]
                                  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSData *data = [argsAsString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id params = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        NSString *functionLowercase = [function lowercaseString];
        MCJSApi *api = [_apiHandlers objectForKey:functionLowercase];
        [api processWithParameters:params success:^(NSArray *responseArgs) {
            [self returnResult:callbackId callbackType:@"ok" args:responseArgs];
        } failure:^(id error) {
            [self returnResult:callbackId callbackType:@"fail" args:@[error]];
        }];
        
        return YES;
    }
    
    return NO;
}

- (void)returnResult:(NSString *)callbackId callbackType:(NSString *)type args:(NSArray *)args;
{
    if (!callbackId) return;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:args options:0 error:nil];
    NSString *resultArrayString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    // We need to perform selector with afterDelay 0 in order to avoid weird recursion stop
    // when calling NativeBridge in a recursion more then 200 times :s (fails ont 201th calls!!!)
    [self performSelector:@selector(returnResultAfterDelay:) withObject:[NSString stringWithFormat:@"window.mc.mailchatBridge.resultForCallback('%@','%@',%@);",callbackId,type,resultArrayString] afterDelay:0];
}

-(void)returnResultAfterDelay:(NSString*)str {
    // Now perform this selector with waitUntilDone:NO in order to get a huge speed boost! (about 3x faster on simulator!!!)
    NSLog(@"callback string = %@",str);
    [self.webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:str waitUntilDone:NO];
}


@end
