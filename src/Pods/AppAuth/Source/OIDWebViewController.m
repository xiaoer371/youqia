//
//  OIDWebViewController.m
//  AppAuth
//
//  Created by admin on 9/28/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

#import "OIDWebViewController.h"
#import "OIDProxyURLProtocol.h"

@interface OIDWebViewController ()

@property (nonatomic, strong, readonly) UIWebView *webView;

@end

@implementation OIDWebViewController

- (instancetype)initWithUrl:(NSURL *)url
{
    if (self = [super init]) {
        _url = url;
        _webView = [[UIWebView alloc] init];
        [NSURLProtocol registerClass:[OIDProxyURLProtocol class]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubView];
    [self loadUrl];
}

- (void)dealloc
{
    [NSURLProtocol unregisterClass:[OIDProxyURLProtocol class]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSubView
{
    CGRect webViewFrame = self.view.frame;
    if (self.navigationController && !self.navigationController.isNavigationBarHidden) {
        CGFloat yOffset = self.navigationController.navigationBar.frame.origin.y;
        webViewFrame = CGRectMake(0, yOffset , webViewFrame.size.width , webViewFrame.size.height - yOffset);
    }
    self.webView.frame = webViewFrame;
    [self.view addSubview:self.webView];
}

-(void)setOffsetY:(CGFloat)offsetY
{
    _offsetY = offsetY;
    CGRect rect = self.webView.frame;
    rect.origin.y = offsetY;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    rect.size.height = height-offsetY;
    self.webView.frame = rect;
}

- (void)loadUrl
{
    [self clearCookie];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

- (void)clearCookie
{
    //    UIWebView
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    return;
}

@end
