//
//  MCMailComposerWebView.m
//  NPushMail
//
//  Created by zhang on 16/1/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMailComposerWebView.h"
#import <objc/message.h>

@interface MCMailComposerWebView ()

@property (nonatomic, strong) UIView *webBrowserView;

@end


@implementation MCMailComposerWebView


- (id)init {
    
    self = [super init];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator   = NO;
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT );
        [self initWebView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initWebView];
    }
    return self;
}

- (void)initWebView{
    if (EGOVersion_iOS7) {
        self.webBrowserView = self.scrollView.subviews.firstObject;
    }else{
        self.webBrowserView = self.scrollView.subviews.lastObject;
    }
}

- (void)setHeaderView:(UIView *)headerView
{
    _headerView = headerView;
    
    [self.scrollView addSubview:headerView];
    
    CGRect frame = self.webBrowserView.frame;
    frame.origin.y = CGRectGetMaxY(headerView.frame);
    self.webBrowserView.frame = frame;
}

- (void)setChangeHeight:(CGFloat)changeHeight{
    
    CGRect frame = self.webBrowserView.frame;
    frame.origin.y = changeHeight;
    self.webBrowserView.frame = frame;
}


- (void)setFooterView:(UIView *)footerView
{
    _footerView = footerView;
    self.delegate = self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.footerView != nil) {
        [self addObserverForWebViewContentSize];
        
        //0.1s after setting position
        [self performSelector:@selector(layoutFooterView) withObject:nil afterDelay:0.1];
    }
}

-(void)layoutFooterView
{
    CGSize contentSize = self.scrollView.contentSize;
    CGFloat y = CGRectGetMaxY(self.webBrowserView.frame);
    _footerView.frame = CGRectMake(0, y, contentSize.width, _footerView.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(contentSize.width, y + _footerView.frame.size.height);
    [self.scrollView addSubview:_footerView];
}

- (void)addObserverForWebViewContentSize
{
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
}
- (void)removeObserForWebViewContentSize
{
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // Remove Observer
    [self removeObserForWebViewContentSize];
    
    [self layoutFooterView];
    
    // Add Observer
    [self addObserverForWebViewContentSize];
}

-(BOOL)resignFirstResponder {
    self.keyboardDisplayRequiresUserAction = YES;
    [self setUserInteractionEnabled:YES];
    [self webViewLoseFocus];
    return [super resignFirstResponder];
}

// only works on iOS 6+
-(BOOL)becomeFirstResponder {
    [super becomeFirstResponder];
    [self stringByEvaluatingJavaScriptFromString:@"document.getElementById('content').focus()"];
    return YES;
}

-(void)webViewLoseFocus {
    [self stringByEvaluatingJavaScriptFromString:@"storeCursor()"];
    [self stringByEvaluatingJavaScriptFromString:@"document.getElementById('content').blur()"];
}


-(BOOL)isFirstResponder{
    
    NSString *str =  [self stringByEvaluatingJavaScriptFromString:@"document.activeElement.id=='content'"];
//    NSString *str =  [self stringByEvaluatingJavaScriptFromString:@"getCaretClientPosition();"];
    if ([str isEqualToString:@"true"]) {
        return YES;
    } else {
        return NO;
    }
}



#pragma mark - Public API

- (NSString*)htmlContent
{
    NSString *jsToGetHTMLSource = @"document.getElementsByTagName('body')[0].innerHTML";
    NSString *HTMLSource = [self stringByEvaluatingJavaScriptFromString:jsToGetHTMLSource];
    HTMLSource = [HTMLSource stringByReplacingOccurrencesOfString:@"contenteditable=\"true\""withString:@""];
    return [HTMLSource stringByReplacingOccurrencesOfString:@"<br><br><br><br><br><br>" withString:@""];
}
- (NSString*)textContent
{
    NSString *jsToGetHTMLSource = @"document.body.innerText";
    NSString *HTMLSource = [self stringByEvaluatingJavaScriptFromString:jsToGetHTMLSource];
    return [HTMLSource trim];
}

- (void)insertText:(NSString *)text
{
    [self stringByEvaluatingJavaScriptFromString:@"restoreCursor()"];
    NSString *insertTextJs = [NSString stringWithFormat:@"insertTextAtCursor('%@')",text];
    [self stringByEvaluatingJavaScriptFromString:insertTextJs];
}

@end
