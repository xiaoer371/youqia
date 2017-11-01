//
//  MCAliBaseGroupModel.h
//  NPushMail
//
//  Created by swhl on 16/12/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAliBaseModel.h"

typedef enum : NSUInteger {
    MCAliGroupTypeRequest = 0,  // 请求加入群，邀请加入群
    MCAliGroupTypeAccept ,      // 同意入群     （预留）
    MCAliGroupTypeRefused,      // 被拒绝加入群 （ 只有申请人能收到， 预留 ）
    MCAliGroupTypeLeave,        // 主动离开群
    MCAliGroupTypeKickedOff,    // 被踢群
    MCAliGroupTypeRename,       // 重命名群组
} MCAliGroupType;

@interface MCAliBaseGroupModel : MCAliBaseModel

@property (nonatomic, assign) MCAliGroupType  type;
@property (nonatomic, strong) NSString        *groupId;


@property (nonatomic, strong) NSString        *account; //(ps: 要执行的用户，)
@property (nonatomic, strong) NSString        *content; //(ps: 操作详细信息)


@end
