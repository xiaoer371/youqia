//
//  MCMailComposerWebView.h
//  NPushMail
//
//  Created by zhang on 16/1/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCMailComposerWebView : UIWebView <UIWebViewDelegate>


@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
//content
@property (nonatomic, strong) NSString *htmlContent;
@property (nonatomic, strong) NSString *textContent;

@property (nonatomic)CGFloat changeHeight;


-(BOOL)resignFirstResponder;
-(BOOL)becomeFirstResponder ;
-(BOOL)isFirstResponder;

- (void)insertText:(NSString *)text;

@end
