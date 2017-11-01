//
//  MCSelectedContactsBlock.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#ifndef MCSelectedContactsBlock_h
#define MCSelectedContactsBlock_h
/**
 *  最上层调用方只需要知道回调回来的数据
 *
 *  @param models
 */
typedef void (^SelectedModelsBlock)(id models);
/**
 *  是否需要立马触发联系人回调的Block
 *
 *  @param needFlag 
 */
typedef void (^selectedModelsWithRefreshBlock)(id models, BOOL needFlag);
/**
 *  选择消息群组的回调
 *
 *  @param model 消息群组model
 */
typedef void (^SelectedMsgGroupModelBlock)(id model);

typedef enum : NSUInteger {
    SelectedContactFromChat,           //从聊天界面进来
    SelectedContactForwordChat,           //从转发界面进来
    SelectedContactChatInfo,           //从聊天详情界面进来
    SelectedContactFromWriteMail,       //从写信界面进来
    SelectedContactFromMailSendMsgs,       //从写信界面发起聊天进来
} SelectedContactType;

#endif /* MCSelectedContactsBlock_h */
