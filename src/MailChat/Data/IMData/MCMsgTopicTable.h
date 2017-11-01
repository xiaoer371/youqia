//
//  MCMsgTopicTable.h
//  NPushMail
//
//  Created by swhl on 16/1/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCTableBase.h"

@interface MCMsgTopicTable : MCTableBase

/**
 *  根据topic  获取到topicId
 *
 *  @param topic topic
 *
 *  @return 返回topicId
 */
-(NSInteger)getTopicIdWithTopic:(NSString *)topic;






@end
