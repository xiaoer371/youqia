//
//  MCMailDetailWebView.h
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCMailDetailWebView : UIWebView

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIView *headerView;

- (void) headerViewHeightChange:(CGFloat)height animated:(BOOL)animated;
- (id) initWithFrame:(CGRect)frame;
//UIActivityIndicatorView
- (void)loading;
- (void)stopLoading;
@end
