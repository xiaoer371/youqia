//
//  MCFileManagerViewController.h
//  NPushMail
//
//  Created by wuwenyu on 15/12/30.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"

typedef enum : NSUInteger {
    MCFileCtrlFromChat,           //从聊天界面进来
    MCFileCtrlFromMail,       //从写信界面进来
    MCFileCtrlFromOther,       //从其它界面进来
} MCFileCtrlFromType;

typedef void (^selectedFilesBlock)(id models);

@interface MCFileManagerViewController : MCBaseSubViewController

- (id)initWithFromType:(MCFileCtrlFromType)type selectedFileBlock:(selectedFilesBlock)block;

@end
