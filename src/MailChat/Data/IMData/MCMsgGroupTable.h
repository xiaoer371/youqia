//
//  MCMsgGroupTable.h
//  NPushMail
//
//  Created by swhl on 16/1/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAccountTableBase.h"
#import "MCIMGroupModel.h"

@interface MCMsgGroupTable : MCAccountTableBase

- (MCIMGroupModel *)groupWithGroupId:(NSString *)groupId;

- (NSArray  <MCIMGroupModel*> * )getSavedGroupModels;

@end
