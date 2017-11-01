//
//  MCMailSearchViewController.h
//  NPushMail
//
//  Created by zhang on 16/8/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCSearchViewController.h"
#import "MCMailModel.h"
#import "MCMailManager.h"

@interface MCMailSearchViewController : MCSearchViewController

@property (nonatomic,strong)MCMailBox *mailbox;

- (void)markReadMail:(MCMailModel*)mail markRead:(BOOL)markRead;
- (void)deleteOrMoveMail:(MCMailModel*)mail toFloder:(MCMailBox*)mailBox;

- (id)initMails:(NSArray *)mails mailManager:(MCMailManager *)mailManager processMailCallback:(MCMailProcessBlock)mailProcessCallback;
@end
