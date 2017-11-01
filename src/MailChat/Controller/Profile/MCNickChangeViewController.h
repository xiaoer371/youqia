//
//  MCNickChangeViewController.h
//  NPushMail
//
//  Created by zhang on 16/5/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"

typedef enum : NSUInteger {
    settingNickName,           //设置昵称
    settingOaServer,           //设置OA代理服务器
} infoSettingType;

@interface MCNickChangeViewController : MCBaseSubViewController

- (id)initNickViewWithAccount:(MCAccount*)account;
- (id)initWithAccount:(MCAccount *)account settingType:(infoSettingType)type;

@end
