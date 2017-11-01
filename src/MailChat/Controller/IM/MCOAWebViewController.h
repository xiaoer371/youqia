//
//  MCOAWebViewController.h
//  NPushMail
//
//  Created by wuwenyu on 16/5/31.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"

@interface MCOAWebViewController : MCBaseSubViewController

@property(nonatomic, strong) NSString *destinationUrl;
//是否需要返回到根页面
@property(nonatomic, assign) BOOL needBackRootCtrl;

@end
