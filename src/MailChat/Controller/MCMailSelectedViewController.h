//
//  MCMailSelectedViewController.h
//  NPushMail
//
//  Created by zhang on 16/8/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"
#import "MCMailManagerView.h"
#import "MCMailManager.h"
typedef NS_ENUM(NSInteger,MCSelectType) {
    MCSelectNormal = 0,
    MCSelectDo
};

@interface MCMailSelectedViewController : MCBaseSubViewController
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *tableViewbottomConstrain;
@property (nonatomic,strong)MCMailBox *folder;
@property (nonatomic,strong)MCMailManager *mailManager;
@property (nonatomic,strong)NSString *sectionTitle;

- (id)initWithMails:(NSArray *)mails selectType:(MCSelectType)selectType didProcessMails:(MCMailProcessBlock)mailProcessCallback;
@end
