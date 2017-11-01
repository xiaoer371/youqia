//
//  MCTouchIdViewController.h
//  NPushMail
//
//  Created by wuwenyu on 16/5/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^loginTouchIdResult)(BOOL success, NSError * error);

@interface MCTouchIdViewController : UIViewController

@property (nonatomic, strong) loginTouchIdResult result;
- (IBAction)loginByOtherWays:(id)sender;

@end
