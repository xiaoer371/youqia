//
//  MCGuideViewController.h
//  NPushMail
//
//  Created by zhang on 2016/10/19.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^goOnLoginGmailActionBlock)(BOOL action);

@interface MCGuideViewController : UIViewController
@property (nonatomic,weak)IBOutlet UIImageView *guideImageView;
@property (nonatomic,weak)IBOutlet UIButton *goOnMailChat;
@property (nonatomic,weak)IBOutlet UIButton *goOnLoginGmail;
@property (nonatomic,weak)IBOutlet NSLayoutConstraint *goOnGmailBottomConstraint;
@property (nonatomic,copy)goOnLoginGmailActionBlock goOnLoginGmailAction;


@end
