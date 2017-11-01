//
//  MCLoginMainViewController.h
//  NPushMail
//
//  Created by zhang on 16/1/18.
//  Copyright © 2016年 sprite. All rights reserved.
//


typedef NS_ENUM(NSInteger,MCLoginPopOptionType) {
    MCLoginPopOptionCanNotPop = 0, // 不存在mainview  不返回
    MCLoginPopOptionCanPop,        // 存在mainview    返回
    MCLoginPopOptionOther          // 存在mainview    不返回
};

#import "MCBaseLoginViewController.h"
#import "MCMailConfig.h"
#import "AppAuth.h"

@interface MCLoginMainViewController : MCBaseLoginViewController
@property (nonatomic,assign)MCLoginPopOptionType mcLoginPopType;
@end
