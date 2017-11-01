//
//  MCContactMailsViewController.h
//  NPushMail
//
//  Created by zhang on 2016/12/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCContactModel.h"
#import "MCMailListTableView.h"
@interface MCContactMailsViewController : UIViewController

@property (nonatomic,strong)MCContactModel *contactModel;

- (id)initWithContact:(MCContactModel*)contact;

@end
