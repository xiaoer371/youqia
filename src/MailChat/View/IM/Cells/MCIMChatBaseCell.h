//
//  MCIMChatBaseCell.h
//  NPushMail
//
//  Created by swhl on 16/2/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCIMMessageModel.h"
#import "MCIMChatBaseBubbleView.h"
#import "MCIMConversationModel.h"

#define HEAD_SIZE    40     // 头像大小
#define HEAD_PADDING 12     // 头像到cell的内间距和头像到bubble的间距
#define CELLPADDING  5      // Cell之间间距

#define NAME_LABEL_WIDTH 180      // nameLabel宽度
#define NAME_LABEL_HEIGHT 20      // nameLabel 高度
#define NAME_LABEL_PADDING 0      // nameLabel间距
#define NAME_LABEL_FONT_SIZE 13   // 字体

extern NSString *const kRouterEventChatHeadImageTapEventName;

@interface MCIMChatBaseCell : UITableViewCell
{
    MCIMChatBaseBubbleView *_bubbleView;
}

@property (nonatomic, strong) MCIMMessageModel      *messageModel;

@property (nonatomic, strong) UIImageView *headImageView;           //头像
@property (nonatomic, strong) UILabel *nameLabel;                   //昵称
@property (nonatomic, strong) UILabel *timeLabel;                   //时间
@property (nonatomic, strong) MCIMChatBaseBubbleView *bubbleView;   //内容区域
@property (nonatomic, assign) BOOL showTime;         //显示时间


- (id)initWithMessageModel:(MCIMMessageModel *)model reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setupSubviewsForMessageModel:(MCIMMessageModel *)model;

+ (NSString *)cellIdentifierForMessageModel:(MCIMMessageModel *)model;

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
          withObject:(MCIMMessageModel *)model
          isShowTime:(BOOL)isShowTime;


@end
