//
//  OIDWebViewController.h
//  AppAuth
//
//  Created by admin on 9/28/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OIDWebViewController : UIViewController

@property (nonatomic, strong, readonly) NSURL *url;

@property (nonatomic,assign) CGFloat offsetY;

- (instancetype)initWithUrl:(NSURL *)url;

@end
