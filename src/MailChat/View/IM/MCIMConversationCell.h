//
//  MCIMConversationCell.h
//  NPushMail
//
//  Created by swhl on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//
/**
 *  消息列表   会话cell 
 */
#import <UIKit/UIKit.h>
#import "MCIMConversationModel.h"
#import "MGSwipeTableCell.h"
#import "RTDraggableBadge.h"

typedef void(^dragBadgeOutViewBlock)(MCIMConversationModel* conversationModel);
typedef void(^doubleClickBadgeViewBlock)(MCIMConversationModel* conversationModel);

@interface MCIMConversationCell : MGSwipeTableCell

@property(nonatomic, strong) RTDraggableBadge *badge;   //未读提醒小红帽

+ (NSString *)reuseIdentifier;

+ (UINib *)cellNib;

@property (nonatomic, strong) MCIMConversationModel* conversationModel;
@property (nonatomic, copy) dragBadgeOutViewBlock dragBadgeOutViewBlock;
@property (nonatomic, copy) doubleClickBadgeViewBlock doubleClickBadgeViewBlock;

-(void)subViewWithConversation:(MCIMConversationModel*)conversationModel;

@end
