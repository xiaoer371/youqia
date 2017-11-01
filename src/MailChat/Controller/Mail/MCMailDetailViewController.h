//
//  MCMailDetailViewController.h
//  NPushMail
//
//  Created by zhang on 15/12/23.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"
#import "MCMailModel.h"
#import "MCMailManager.h"

@protocol MCMailDetailViewControllerDelegate <NSObject>
@optional
- (void)mailDetailViewHandleMail:(MCMailModel *)mail tag:(MCMailTags)tags mark:(BOOL)mark;
- (void)mailDetailViewHandleMail:(MCMailModel *)mail setRead:(BOOL)read;
- (void)mailDetailViewHandleMail:(MCMailModel *)mail  from:(MCMailBox*)fromBox moveTo:(MCMailBox *)mailBox;
- (MCMailModel*)mailDetailViewReadOtherFromMail:(MCMailModel*)mail toNext:(BOOL)next;

@end

@interface MCMailDetailViewController : MCBaseViewController
@property (nonatomic,strong)MCMailModel *mailModel;
@property (nonatomic,strong)MCMailBox *mailbox;
- (id)initWithMail:(MCMailModel *)mailModel manager:(MCMailManager *)mailManager delegate:(id)object;

@end
