//
//  MCMailComposerViewController.h
//  NPushMail
//
//  Created by zhang on 16/1/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

typedef NS_ENUM(NSInteger,MCMailComposerOptionType) {
    
    MCMailComposerNew = 0,//写新邮件
    MCMailComposerReplyAll ,//回复全部
    MCMailComposerReplySingle,//回复
    MCMailComposerForward,//包含附件
    MCMailComposerForwardWithoutAttachment,//不包含附件
    MCMailComposerFromDraft,//草稿
    MCMailComposerFromPending,//待发送
    MCMailComposerFromMessageText,//从消息界面转发
    MCMailComposerFromMessageFile,
    MCMailComposerFromFileLibrary
};

typedef NS_ENUM(NSInteger,MCMailDraftPendingManagerType) {
    //新草稿
    MCMailDraftManagerTypeNew = 0,
    //再次编辑草稿保存
    MCMailDraftManagerTypeEditAgain,
    //发草稿箱邮件
    MCMailDraftManagerTypeSent,
    //待发送邮件保存
    MCMailPendingSave
};


#import "MCBaseSubViewController.h"
#import "MCMailModel.h"
#import "MCContactModel.h"
#import "MCMailManager.h"
@interface MCMailComposerViewController : MCBaseSubViewController

@property (nonatomic,strong)MCMailManager *mailManager;

@property (nonatomic,copy) void(^mailDraftManagerCallback)(MCMailDraftPendingManagerType draftManagerType ,MCMailModel *model);

- (instancetype)initWithMail:(MCMailModel*)mailModel mailComposerOptionType:(MCMailComposerOptionType)mailComposerOptionType;

- (instancetype)initWithTo:(NSArray*)to
                      cc:(NSArray*)cc
                     bcc:(NSArray*)bcc
                 subject:(NSString*)subject
                 content:(NSString*)content
              attachment:(NSArray*)attachments
        inlineAttachment:(NSArray*)inlineAttachments
            composerType:(MCMailComposerOptionType)composerType;

- (instancetype)initWithContent:(id)content composerType:(MCMailComposerOptionType)composerType;
@end
