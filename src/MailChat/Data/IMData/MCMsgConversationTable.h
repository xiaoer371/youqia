//
//  MCMsgConversationTable.h
//  NPushMail
//
//  Created by swhl on 16/1/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAccountTableBase.h"
#import "MCIMConversationModel.h"

@interface MCMsgConversationTable : MCAccountTableBase

- (MCIMConversationModel *)getModelByPeerId:(NSString *)peerId;

@end
