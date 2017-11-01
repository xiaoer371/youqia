//
//  MCWebViewController.h
//  NPushMail
//
//  Created by zhang on 16/4/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"

typedef enum : NSUInteger {
    MCWebViewStyleDefault = 0,
    MCWebViewStyleEvent,
    MCWebViewStyleOther,
    MCWebViewStyleFeiBa,
    MCWebViewStyleWeiYa,
} MCWebViewStyle;


@protocol MCWebViewControllerDelegate <NSObject>

- (void)showGuideView;

@end

@interface MCWebViewController : MCBaseSubViewController<UIWebViewDelegate>

@property (nonatomic,weak) id<MCWebViewControllerDelegate> delegate;

- (instancetype)initWithUrl:(NSURL *)url title:(NSString *)title style:(MCWebViewStyle)style;

- (instancetype)initWithUrl:(NSURL *)url title:(NSString *)title;

- (instancetype)initWithUrl:(NSURL *)url;

@end
