//
//  MCWebViewController.m
//  NPushMail
//
//  Created by zhang on 16/4/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCWebViewController.h"
#import "UIView+MCExpand.h"
#import "MCJSApiManager.h"
#import "MCShareActivity.h"
#import "MCFeiBaUnit.h"
#import "MCAppDelegate.h"

@interface MCWebViewController ()<UIActionSheetDelegate>
@property (assign, nonatomic) NSUInteger loadCount;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic ,strong) UIColor *webViewProgressColor;
@property (strong, nonatomic) NSURL *homeUrl;
@property (nonatomic, strong) MCJSApiManager *apiManager;
@property (nonatomic ,strong) NSString  *urlTitle;
@property (nonatomic, assign) MCWebViewStyle  style;

@end

@implementation MCWebViewController


- (instancetype)initWithUrl:(NSURL *)url title:(NSString *)title style:(MCWebViewStyle)style
{
    self = [super init];
    if (self) {
        self.homeUrl = url;
        self.urlTitle = title?:@"";
        self.style = style;
    }
    return self;

}

- (instancetype)initWithUrl:(NSURL *)url title:(NSString *)title
{
    return [self initWithUrl:url title:title style:MCWebViewStyleDefault];
}

- (instancetype)initWithUrl:(NSURL *)url
{
    return [self initWithUrl:url title:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets  = YES;
    [self configUI];
    
   

    self.apiManager = [MCJSApiManager new];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)configUI {
    
    if (self.style  ==MCWebViewStyleWeiYa ) {
        MCAppDelegate * appDelegate = (MCAppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.allowRotation = 1;
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = AppStatus.theme.backgroundColor;
    
    // 进度条
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    progressView.tintColor = [UIColor grayColor];
    progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:progressView];
    self.progressView = progressView;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    webView.scalesPageToFit = YES;
    webView.backgroundColor = [UIColor whiteColor];
    webView.delegate = self;
    webView.opaque = NO;
    [self.view insertSubview:webView belowSubview:progressView];
    
    if (self.style == MCWebViewStyleFeiBa) {
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:self.homeUrl];
        [request setHTTPMethod: @"POST"];
        [[MCFeiBaUnit shared] feibaBodyParsWithsuccessBlock:^(NSString *bodyPars) {
            [webView stopLoading];
            [request setHTTPBody:[bodyPars dataUsingEncoding:NSUTF8StringEncoding]];
            [webView loadRequest: request];
        }];
        
    }else{
        NSURLRequest *request = [NSURLRequest requestWithURL:self.homeUrl];
        [webView loadRequest:request];
    }
    self.webView = webView;
    
    self.viewTitle = self.urlTitle;
    
    if (self.style == MCWebViewStyleEvent) {
//    AppStatus.theme.navbarBgImage
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"mc_navbar_eventbg.png"]
                                                      forBarMetrics:UIBarMetricsDefault];
//        self.navigationController.navigationBar.shadowImage = [UIImage new];
//        [webView moveToY:-64.0f];
//        CGFloat h = CGRectGetHeight(self.view.bounds);
//        webView.mc_height = h+64.0f;
//        [self.leftNavigationBarButtonItem setTitle:nil];
        [self.leftNavigationBarButtonItem setImage:[UIImage imageNamed:@"mc_mailaddAttach_delete.png"]];
    }
    
}

- (void)configLeftButtons {
    
    if (self.webView.canGoBack) {
        
        [self.leftNavigationBarButtonItem setImage:[AppStatus.theme.commonBackImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        // 导航栏的关闭按钮
        UIButton *colseBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        [colseBtn setTitle:PMLocalizedStringWithKey(@"PM_Login_EventClose") forState:UIControlStateNormal];
        [colseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [colseBtn addTarget:self action:@selector(colseBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [colseBtn sizeToFit];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        UIBarButtonItem *colseItem = [[UIBarButtonItem alloc] initWithCustomView:colseBtn];
        NSMutableArray *newArr = [NSMutableArray arrayWithObjects:self.leftNavigationBarButtonItem,colseItem,negativeSpacer, negativeSpacer,nil];
        self.navigationItem.leftBarButtonItems = newArr;
        
    }
    else {
        if (self.style == MCWebViewStyleEvent) {
            [self.leftNavigationBarButtonItem setImage:[UIImage imageNamed:@"mc_mailaddAttach_delete.png"]];
            [self.leftNavigationBarButtonItem setTitle:nil];
        }

        self.navigationItem.leftBarButtonItems = @[self.leftNavigationBarButtonItem];
    }
}

#pragma mark - 普通按钮事件

// 返回按钮点击
- (void)leftNavigationBarButtonItemAction:(id)sender {

    [self.webView stopLoading];
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else {
        if (self.style == MCWebViewStyleWeiYa ) {
            MCAppDelegate * appDelegate = (MCAppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.allowRotation = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
        
        [self.navigationController.navigationBar setBackgroundImage:AppStatus.theme.navbarBgImage
                                                      forBarMetrics:UIBarMetricsDefault];
        if (self.style == MCWebViewStyleDefault ||self.style == MCWebViewStyleFeiBa) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        
        if (self.delegate &&[self.delegate respondsToSelector:@selector(showGuideView)]) {
            [self.delegate showGuideView];
        }
    }
}

// 关闭按钮点击
- (void)colseBtnPressed:(id)sender {
    [self.webView stopLoading];
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - webView

// 计算webView进度条
- (void)setLoadCount:(NSUInteger)loadCount {
    _loadCount = loadCount;
    if (loadCount == 0) {
        self.progressView.hidden = YES;
        [self.progressView setProgress:0 animated:NO];
    }else {
        self.progressView.hidden = NO;
        CGFloat oldP = self.progressView.progress;
        CGFloat newP = (1.0 - oldP) / (loadCount + 1) + oldP;
        if (newP > 0.95) {
            newP = 0.95;
        }
        [self.progressView setProgress:newP animated:YES];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.loadCount ++;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.viewTitle = theTitle;
    [self configLeftButtons];
    
    
    self.loadCount --;
    self.progressView.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.loadCount --;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL isHandled = [self.apiManager handleRequest:request];
    
    NSString *requestString = [[request URL] absoluteString];
    
    //流量活动  分享好友
    if ([requestString containsString:@"event_info#eventshare"]) {
        
        [self shareEvent];
       
        return NO;
    }
    return !isHandled;
}

- (void)shareEvent
{
    NSString *content = @"邮件办公上邮洽 千万流量免费送";
    UIImage *image = [UIImage imageNamed:@"youqiaIcon.png"];
    NSURL *url = [NSURL URLWithString:@"https://a.mailchat.cn/app/event_info"];
    NSArray *activityItems = @[content, image, url];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeMessage, UIActivityTypeCopyToPasteboard];
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
