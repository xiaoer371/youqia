//
//  OIDProxyURLProtocol.m
//  AppAuth
//
//  Created by gaoyq on 9/28/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

#import "OIDProxyURLProtocol.h"
#import <UIKit/UIKit.h>
#import "NSURLSession+Proxy.h"

static NSString* const kProxyHeader = @"x-webview-proxy";

@interface OIDProxyURLProtocol ()

@property (nonatomic, strong) NSURLSessionTask *task;

@end

@implementation OIDProxyURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([NSURLProtocol propertyForKey:kProxyHeader inRequest:request]) {
        return NO;
    }
    
    NSString *scheme = [request.URL.scheme lowercaseString];
    if ([scheme isEqualToString:@"http"] ||
        [scheme isEqualToString:@"https"] ||
        [scheme hasPrefix:@"com"]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task
{
    return YES;
}


+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSMutableURLRequest *mutableRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@"YES" forKey:kProxyHeader inRequest:mutableRequest];
    
    if ([mutableRequest.URL.scheme hasPrefix:@"com"] ) {
        [[UIApplication sharedApplication] openURL:mutableRequest.URL];
        return;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.connectionProxyDictionary = [NSURLSession sessionProxyConfiguration];
    // Create a NSURLSession with our proxy aware configuration
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.task = [session dataTaskWithRequest:mutableRequest];
    [self.task resume];
}

- (void)stopLoading
{
    [self.task cancel];
    self.task = nil;
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if( error ) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}

@end
