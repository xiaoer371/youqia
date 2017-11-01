//
//  MCMessageGroupsViewController.h
//  NPushMail
//
//  Created by wuwenyu on 16/7/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"

typedef enum : NSUInteger {
    SelectedMsgGroupFromSelectedContact,           //选择联系人界面点击
    SelectedMsgGroupFromContactList,           //联系人列表
} SelectedMsgGroupType;

typedef void (^SelectedMsgGroupBlock)(id model);

@interface MCMessageGroupsViewController : MCBaseSubViewController

- (id) initWithFromCtrlType:(SelectedMsgGroupType)ctrlType selectedGroupBlock:(SelectedMsgGroupBlock)block;

@end
