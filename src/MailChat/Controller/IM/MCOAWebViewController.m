//
//  MCOAWebViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/5/31.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCOAWebViewController.h"
#import "MCJSApiManager.h"
#import "MCAccountConfig.h"
#import "MCWebViewController.h"

@interface MCOAWebViewController ()<UIWebViewDelegate>

@property(nonatomic,strong) UIWebView *webView;
@property(nonatomic,strong) MCJSApiManager *apiManager;

@end

@implementation MCOAWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewTitle = @"OA";
    [self.view addSubview:self.webView];
    if (self.destinationUrl) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.destinationUrl]]];
    }
    self.apiManager = [[MCJSApiManager alloc] initWithWebView:self.webView];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_webView stopLoading];
    [SVProgressHUD dismiss];
}

//WebView
- (UIWebView*)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth,ScreenHeigth-NAVIGATIONBARHIGHT)];
        _webView.delegate = self;
        _webView.backgroundColor = [UIColor clearColor];
    }
    
    
    
    return _webView;
}

- (void)leftNavigationBarButtonItemAction:(id)sender {
    [_webView stopLoading];
    [SVProgressHUD dismiss];
    if (_needBackRootCtrl) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - webViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_MessageLoading")];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:@"加载失败，请稍后重试"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL result = [self.apiManager handleRequest:request];
    NSString *requestString = [[request URL] absoluteString];
    if ([requestString containsString:@"downloadAction.do"]) {
        MCWebViewController *webController = [[MCWebViewController alloc] initWithUrl:request.URL];
        [self.navigationController pushViewController:webController animated:YES];
        return NO;
    }
    
    if ([requestString hasSuffix:@"mailchaterror.html"]) {
        [AppStatus.accountData.accountConfig resetOaStatus];
    }
    return !result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
