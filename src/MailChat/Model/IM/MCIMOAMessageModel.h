//
//  MCIMOAMessageModel.h
//  NPushMail
//
//  Created by admin on 4/15/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMMessageModel.h"

typedef enum : NSUInteger {
    IMOATypeNewTrans = 0,  //待办  NEW_TRANS
    IMOATypeAnnouncement = 1,  //公告   ANNOUNCE
} IMOAType;


@interface MCIMOAMessageModel : MCIMMessageModel

@property(nonatomic, copy) NSString *app;     //应用类型：目前是oa
@property(nonatomic, copy) NSString *sponsor; //项目发起人
@property(nonatomic, copy) NSString *toUser;  //消息接收人的邮件地址
@property(nonatomic, copy) NSString *title;   //消息标题，
@property(nonatomic, assign) IMOAType oaType;
@property(nonatomic, copy) NSString *eventId; //事件ID：待办事务ID或者公告ID
@property(nonatomic, copy) NSString *url;    //跳转的UR
@property(nonatomic, copy) NSString *extend; //备用 扩展字段

@end
