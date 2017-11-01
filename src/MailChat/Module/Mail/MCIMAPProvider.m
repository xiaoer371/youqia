//
//  MCIMAPProvider.m
//  NPushMail
//
//  Created by admin on 12/31/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCIMAPProvider.h"
#import "MCObjc.h"
#import "MCOIMAP.h"
#import "MCOSMTP.h"
#import "MCUDID.h"
#import "NSString+MCO.h"


@interface MCIMAPProvider ()

@property (nonatomic,strong) MCOIMAPSession *imapSession;
@property (nonatomic,strong) MCOSMTPSession *smtpSession;

@property (nonatomic,strong) NSMutableDictionary *imapMsgDictionary;

@end

@implementation MCIMAPProvider

@synthesize account = _account;

#pragma mark - Lifecycle

- (instancetype)initWithAccount:(MCAccount *)account
{
    if (self = [super init]) {
        _imapMsgDictionary = [NSMutableDictionary new];
        _account = account;
        
        _imapSession = [self imapSessionWithAccount:account];
        _smtpSession = [self smtpSessionWithAccount:account];
    }
    
    return self;
}

#pragma mark - Properties

#pragma mark - Public

- (void)loginSuccess:(ActionBlock)success failure:(FailureBlock)failure
{
    MCOIMAPOperation *op = [self.imapSession checkAccountOperation];
    [op start:^(NSError * _Nullable error) {
        if (error) {
            DDLogError(@"check imap account error = %@",error);
            if (failure) {
                failure(error);
            }
        }
        else {
            if (success) {
                success();
            }
        }
     }];

}

- (void)refreshAuthentication
{
    [self disconnect];
    
    self.imapSession = [self imapSessionWithAccount:self.account];
    self.smtpSession = [self smtpSessionWithAccount:self.account];
}

- (void)getAllFoldersSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    MCOIMAPFetchFoldersOperation *op = [self.imapSession fetchAllFoldersOperation];
    [op start:^(NSError * _Nullable error, NSArray * _Nullable folders) {
        if (error) {
            DDLogError(@"getAllFolders error = %@",error);
            if (failure) {
                failure(error);
            }
        } else {
            NSMutableArray *folderList = [[NSMutableArray alloc] initWithCapacity:folders.count];
            for (MCOIMAPFolder *imapFolder in folders) {
                MCMailBox *box = [self mailBoxFromImapFolder:imapFolder];
                //过滤相同类型文件夹
                if (box.type != MCMailFolderTypeOther) {
                    for (MCMailBox *b in folderList) {
                        if (box.type == b.type) {
                            if (box.haveIMAPfolderFlag) {
                                b.type = MCMailFolderTypeOther;
                            } else {
                                box.type = MCMailFolderTypeOther;
                            }
                            break;
                        }
                    }
                }
                // 有一些文件夹是没内容的，去掉不需要显示的
                if (![self isIgnoreFolder:box]) {
                    [folderList addObject:box];
                }
            }
            
            if (folderList.count > 0) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.type == %d",3];
                NSArray *array = [folderList filteredArrayUsingPredicate:predicate];
                if (array.count == 0) {
                    [folderList addObject:[self defaultStarBox]];
                }
                [folderList addObject:[self defaultPendingBox]];
            }
            if (success) {
                success(folderList);
            }
        }
        
    }];
}

- (void)getFolderInfo:(NSString *)folder success:(SuccessBlock)success failure:(FailureBlock)failure
{
    MCOIMAPFolderInfoOperation *op = [self.imapSession folderInfoOperation:folder];
    [op start:^(NSError * _Nullable error, MCOIMAPFolderInfo * _Nullable info) {
        if (error) {
            DDLogError(@"getFolderStatus ERROR = %@",error);
            if (failure) {
                failure(error);
            }
        }
        else{
            MCMailBoxInfo *boxStatus = [MCMailBoxInfo new];
            boxStatus.uidNext = info.uidNext;
            boxStatus.uidValidity = info.uidValidity;
            boxStatus.messageCount = info.messageCount;
            boxStatus.highestModSeqValue = info.modSequenceValue;
            if (success) {
                success(boxStatus);
            }
        }
    }];
}

- (void)getMailsByNumbersInFolder:(MCMailBox *)folder requestKind:(MCIMAPMessageRequestKind)requestKind numbers:(NSRange)range success:(SuccessBlock)success failure:(FailureBlock)failure
{
    MCOIndexSet *indexSet = [MCOIndexSet indexSetWithRange:MCORangeMake(range.location, range.length)];
    
    MCOIMAPMessagesRequestKind imapRequestKind = [self mcorequestKindWithMCRequestKind:requestKind];
    MCOIMAPFetchMessagesOperation *op = [self.imapSession fetchMessagesByNumberOperationWithFolder:folder.path requestKind:imapRequestKind numbers:indexSet];
    
    [op start:^(NSError * _Nullable error, NSArray * _Nullable messages, MCOIndexSet * _Nullable vanishedMessages) {
        if (error) {
            DDLogError(@"get mail error:%@",error);
            if (failure) {
                failure(error);
            }
        }
        else{
            NSMutableArray *mails = [[NSMutableArray alloc] initWithCapacity:messages.count];
            for (MCOIMAPMessage *msg in messages) {
                [_imapMsgDictionary setObject:msg forKey:[NSString stringWithFormat:@"%u",msg.uid]];
                MCMailModel *mail = [[self class] mailModelWithIMAPMessage:msg folder:folder];
                [mails insertObject:mail atIndex:0];
            }
            if (success) {
                success(mails);
            }
        }
    }];
}

- (void)getMailsByUidsInFolder:(MCMailBox *)folder requestKind:(MCIMAPMessageRequestKind)requestKind uids:(NSIndexSet *)uids success:(SuccessBlock)success failure:(FailureBlock)failure
{
    
    if (uids.count <= 0) {
        success(nil);
        return;
    }
    
    MCOIMAPMessagesRequestKind imapRequestKind = [self mcorequestKindWithMCRequestKind:requestKind];
    
    MCOIndexSet *indexSet = [MCOIndexSet indexSet];
    [uids enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexSet addIndex:idx];
    }];
    
    MCOIMAPFetchMessagesOperation *op = [self.imapSession fetchMessagesOperationWithFolder:folder.path requestKind:imapRequestKind uids:indexSet];
    op.extraHeaders = @[MCMailNeedToSynchKey];
    [op start:^(NSError * _Nullable error, NSArray * _Nullable messages, MCOIndexSet * _Nullable vanishedMessages) {
        if (error) {
            DDLogError(@"fetchMessagesOperationWithFolder:requestKind:uids ERROR:%@ -- %@ ---%@",error,uids,folder.path);
            if (failure) {
                failure(error);
            }
        }
        else{
            NSMutableArray *mails = [[NSMutableArray alloc] initWithCapacity:messages.count];
            for (MCOIMAPMessage *msg in messages) {
                
                MCMailModel *mail = [[self class] mailModelWithIMAPMessage:msg folder:folder];
                [mails insertObject:mail atIndex:0];
                [_imapMsgDictionary setObject:msg forKey:[NSString stringWithFormat:@"%u",msg.uid]];
            }
            if (success) {
                success(mails);
            }
        }
    }];
}


- (void)updateMails:(NSArray *)mails inFolder:(MCMailBox *)folder requestKind:(MCIMAPMessageRequestKind)requestKind success:(SuccessBlock)success failure:(FailureBlock)failure
{
    MCOIMAPMessagesRequestKind imapRequestKind = [self mcorequestKindWithMCRequestKind:requestKind];
    
    MCOIndexSet *indexSet = [MCOIndexSet indexSet];
    for (MCMailModel *mail in mails) {
        [indexSet addIndex:mail.messageUid];
    }
    
    MCOIMAPFetchMessagesOperation *op = [self.imapSession fetchMessagesOperationWithFolder:folder.path requestKind:imapRequestKind uids:indexSet];
    op.extraHeaders = @[MCMailNeedToSynchKey,@"X-Priority"];
    [op start:^(NSError * _Nullable error, NSArray * _Nullable messages, MCOIndexSet * _Nullable vanishedMessages) {
        if (error) {
            DDLogError(@"fetchMessagesOperationWithFolder:requestKind:uids ERROR:%@ -- %@",error,folder.path);
            if (failure) {
                failure(error);
            }
        }
        else if (messages.count != mails.count) {
            DDLogError(@"fetchMessages response mails count is not equal to request mails count");
            if (failure) {
                NSError *err = [NSError errorWithDomain:MCOErrorDomain code:MCOErrorParse userInfo:@{@"error" : @"Parse mail error"}];
                failure(err);
            }
        }
        else {
            
            // 防止uid 乱序的情况
            NSArray *sortedMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(MCOIMAPMessage *obj1, MCOIMAPMessage *obj2) {
                if (obj1.uid > obj2.uid) {
                    return NSOrderedDescending;
                }
                else if (obj1.uid == obj2.uid){
                    return NSOrderedSame;
                }
                else {
                    return NSOrderedAscending;
                }
            }];
            
            MCMailModel *mail = nil;
            MCOIMAPMessage *msg = nil;
            for (NSInteger i = 0, j = sortedMessages.count - 1 ; i < sortedMessages.count; i++, j--) {
                mail = mails[i];
                msg = sortedMessages[j];
                [[self class] updateMailModel:mail withImapMessage:msg folder:folder];
                [_imapMsgDictionary setObject:msg forKey:[NSString stringWithFormat:@"%u",msg.uid]];
            }
            
            if (success) {
                success(mails);
            }
        }
    }];
}

- (void)updateMailContent:(MCMailModel *)mailModel inFolder:(MCMailBox *)folder urgent:(BOOL)urgent success:(SuccessBlock)success failure:(FailureBlock)failure
{
    MCOIMAPMessage*imapMsg = [_imapMsgDictionary valueForKey:[NSString stringWithFormat:@"%ld",(long)mailModel.messageUid]];
    if (imapMsg && imapMsg.mainPart && !mailModel.isPush) {
        [self updateMailHtmlContentWithMail:mailModel folder:folder urgent:urgent imapMessage:imapMsg success:success failure:failure];
    }
    else {
        
        //避免收藏夹邮件加载内容失败
        MCMailBox *f = folder;
        if (!folder.path) {
            MCMailBox *box = [MCMailBox new];
            box.path = mailModel.folder;
            box.accountId = mailModel.accountId;
            box.uid = mailModel.boxId;
            f = box;
        }
        
        [self updateMails:@[mailModel] inFolder:f requestKind:MCIMAPMessageRequestKindFullHeaders success:^(id response) {
            // 必须再刷新一下最新的 imap message
            MCOIMAPMessage *newImapMsg = [_imapMsgDictionary valueForKey:[NSString stringWithFormat:@"%ld",(long)mailModel.messageUid]];
            [self updateMailHtmlContentWithMail:mailModel folder:folder urgent:urgent imapMessage:newImapMsg success:success failure:failure];
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }
}

- (void)updateMailHtmlContentWithMail:(MCMailModel *)mail folder:(MCMailBox *)folder urgent:(BOOL)urgent imapMessage:(MCOIMAPMessage *)imapMsg success:(SuccessBlock)success failure:(FailureBlock)failure
{
    MCOIMAPMessageRenderingOperation*op = [self.imapSession htmlBodyRenderingOperationWithMessage:imapMsg folder:mail.folder];
    op.urgent = urgent;
    [op start:^(NSString * plainTextBodyString, NSError * error) {
        if (error) {
            DDLogError(@"Get content error == %@",error);
            if (failure) {
                failure(error);
            }
        }
        else {
            mail.messageContentHtml = plainTextBodyString;
            NSString *textContent = [[[plainTextBodyString mco_flattenHTMLAndShowBlockquote:YES showLink:NO] mco_strippedWhitespace] trim];
            if (!textContent || textContent.length ==0) {
                mail.messageContentString = PMLocalizedStringWithKey(@"PM_Mail_NoneTextContent");
            } else{
                mail.messageContentString = textContent;
            }
            
            if (success) {
                success(mail);
            }
        }
    }];
}

//获取整封邮件
- (void)getFullMailFolder:(MCMailBox*)folder  byUid:(NSInteger)uid success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    MCOIMAPFetchContentOperation *op = [self.imapSession fetchMessageOperationWithFolder:folder.path uid:(uint32_t)uid];
    [op start:^(NSError * _Nullable error, NSData * _Nullable data) {
        
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
          
            MCOMessageParser *messageParser = [MCOMessageParser messageParserWithData:data];
            MCMailModel *mail = [[self class] mailModelWithIMAPMessageParser:messageParser uid:uid folder:folder];
            if (success) {
                success(mail);
            }
        }
    }];
}

- (void)fetchFullMail:(MCMailModel *)mail inFolder:(MCMailBox *)folder success:(ActionBlock)success failure:(FailureBlock)failure
{
    MCOIMAPFetchContentOperation *op = [self.imapSession fetchMessageOperationWithFolder:folder.path uid:(uint32_t)mail.messageUid];
    [op start:^(NSError * _Nullable error, NSData * _Nullable data) {
        
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            
            MCOMessageParser *messageParser = [MCOMessageParser messageParserWithData:data];
            [[self class] updateMailModel:mail withMailParser:messageParser folder:folder];
            if (success) {
                success();
            }
        }
    }];
}

- (void)storeFlag:(MCMailFlags)flag
          toMails:(NSArray *)mails
        storeKind:(MCMailFlagStoreKind)storeKind
          success:(ActionBlock)success
          failure:(FailureBlock)failure{
    
    MCOIndexSet *indexSet = [MCOIndexSet indexSet];
    NSString *folder;
    for (MCMailModel *mail in mails) {
        if (!folder) {
           folder = mail.folder;
        }
        [indexSet addIndex:mail.messageUid];
    }
    if (indexSet.count <= 0|| !folder) {
        return;
    }
    MCOMessageFlag  messageFlag;
    MCOIMAPStoreFlagsRequestKind storeFlagKind;
    if (flag&MCMailFlagSeen) {
        messageFlag = MCOMessageFlagSeen;
    } else if (flag&MCMailFlagStar) {
        messageFlag = MCOMessageFlagFlagged;
    } else {
        messageFlag = MCOMessageFlagAnswered;
    }
    
    if (storeKind == MCMailFlagStoreKindAdd) {
        storeFlagKind = MCOIMAPStoreFlagsRequestKindAdd;
    } else if (storeKind == MCMailFlagStoreKindRemove){
        storeFlagKind = MCOIMAPStoreFlagsRequestKindRemove;
    }

    [self storeMailsFolder:folder uids:indexSet storeKind:storeFlagKind messsageFlag:messageFlag success:success failure:failure];
}


- (void)moveMails:(NSArray *)mails
       fromFolder:(NSString *)fromFolder
         toFolder:(NSString *)toFolder
          success:(ActionBlock)success
          failure:(FailureBlock)failure{
    
    MCOIndexSet *indexSet = [MCOIndexSet indexSet];
    for (MCMailModel *mail in mails) {
        [indexSet addIndex:mail.messageUid];
    }
    
    if (indexSet.count <= 0) {
        if (failure) {
            failure(nil);
        }
        return;
    }
    if (![fromFolder isEqualToString:toFolder]) {
        MCOIMAPCopyMessagesOperation * opp = [self.imapSession copyMessagesOperationWithFolder:fromFolder uids:indexSet destFolder:toFolder];
        __weak typeof(self)weekSelf = self;
        [opp start:^(NSError * error, NSDictionary * uidMapping) {
            if (error) {
                DDLogError(@"[MCOIMAPCopyMessagesOperation] error = %@",error);
                if (failure) {
                    failure(error);
                }
            } else {
                [weekSelf storeMailsFolder:fromFolder uids:indexSet storeKind:MCOIMAPStoreFlagsRequestKindAdd messsageFlag:MCOMessageFlagDeleted success:^{
                    
                        MCOIMAPOperation *deleteOp = [self.imapSession expungeOperation:fromFolder];
                        [deleteOp start:^(NSError *error) {
                            if (error) {
                                if (failure) {
                                    failure(error);
                                }
                            } else {
                                if (success) {
                                    success();
                                }
                            }
                        }];
                    
                } failure:failure];
            }
        }];
        
    } else {
        
        [self storeMailsFolder:fromFolder uids:indexSet storeKind:MCOIMAPStoreFlagsRequestKindAdd messsageFlag:MCOMessageFlagDeleted success:^{
            MCOIMAPOperation *deleteOp = [self.imapSession expungeOperation:fromFolder];
            [deleteOp start:^(NSError *error) {
                if (error) {
                    DDLogError(@"error:%@",error);
                    if (failure) {
                        failure(error);
                    }
                } else {
                    if (success) {
                        success ();
                    }
                }
            }];
            
        } failure:failure];
    }
    
}


- (void)storeMailsFolder:(NSString*)folder uids:(MCOIndexSet *)indexSet
              storeKind:(MCOIMAPStoreFlagsRequestKind)storeKind
           messsageFlag:(MCOMessageFlag)messageFlag
                success:(ActionBlock)success
                failure:(FailureBlock)failure {
    
    MCOIMAPOperation *op = [self.imapSession storeFlagsOperationWithFolder:folder
                                                                      uids:indexSet
                                                                      kind:storeKind
                                                                     flags:messageFlag];
    [op start:^(NSError * error) {
        if (!error) {
            if (success) {
                success();
            }
            
        } else {
            DDLogError(@"MCOIMAPOperation error:%@",error);
            if (failure) {
                failure (error);
            }
        }
    }];
}


- (void)getAttachmentData:(MCMailAttachment*)attachment progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    MCOIMAPFetchContentOperation *op = [self.imapSession fetchMessageAttachmentOperationWithFolder:attachment.partFolder uid:(unsigned int)attachment.mailUid  partID:attachment.partId encoding:(MCOEncoding)attachment.partEncode];
    
    op.urgent = YES;
    op.progress = ^(unsigned int current, unsigned int maximum){
        
        if (progress) {
            progress(current,maximum);
        }
    };
    
    [op start:^(NSError *error, NSData *partData) {
        if (error) {
            DDLogError(@"MCOIMAPFetchContentOperation error:%@",error);
            if (failure) {
                failure(error);
            }
        } else {
            if (success) {
                success (partData);
            }
        }
    }];
    
}


- (void)searchMailsWithFolder:(NSString*)folder
                   searchKind:(MCSearchMailKind)searchKind
                   searchText:(NSString*)searchText
                      success:(SuccessBlock)success
                      failure:(FailureBlock)failure {
    
    [self.imapSession cancelAllOperations];
    
    MCOIMAPSearchOperation* op = [self.imapSession searchExpressionOperationWithFolder:folder expression:[self mailcoreSearchExpWithSearchKind:searchKind searchText:searchText]];
    [op start:^(NSError *error, MCOIndexSet *resultIndexSet) {
        if (error) {
            DDLogError(@"MCOIMAPSearchOperation error:%@",error);
            if (failure) {
                failure(error);
            }
        } else {
            NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
            [resultIndexSet enumerateIndexes:^(uint64_t idx) {
                [indexSet addIndex:idx];
            }];
            
            success (indexSet);
        }
    }];
}
//sent

- (void)smtpConnectWithSuccess:(SuccessBlock)success failure:(FailureBlock)failure {
    
    MCOSMTPOperation *op = [self.smtpSession loginOperation];
    [op start:^(NSError * _Nullable error) {
        if (error){
            if (failure) {
                failure(error);
            }
            DDLogError(@"MCOSMTPOperation connect error:%@",error);
        }else {
            if (success) {
                success(nil);
            }
        }
    }];
}

- (void)sendEmailWithData:(NSData *)messageData success:(SuccessBlock)success failure:(FailureBlock)failure progress:(ProgressBlock)progress {
    
    MCOSMTPSendOperation *op = [self.smtpSession sendOperationWithData:messageData];
    [op start:^(NSError * _Nullable error) {
        if (error) {
            DDLogError(@"MCOSMTPSendOperation error:%@",error);
            failure(error);
        } else {
            success(nil);
        }
    }];
    
    op.progress = ^(unsigned int current, unsigned int maximum) {
        progress(current,maximum);
    };
}
//保存草稿
- (void)appendMailWithData:(NSData*)messageData folder:(NSString*)folder  isSent:(BOOL)isSent success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    if (isSent) {
        //排除网易邮箱已发送不进行append 避免出现已发送出现重复邮件；
        NSString *host = self.account.config.imap.hostName;
        if ([host rangeOfString:@"imap.163.com"].location != NSNotFound |
            [host rangeOfString:@"imap.yeah.net"].location != NSNotFound|
            [host rangeOfString:@"imap.126.com"].location != NSNotFound|
            [host rangeOfString:@"imap.qiye.163.com"].location != NSNotFound){
            return;
        }
    }
    MCOIMAPAppendMessageOperation * op =[self.imapSession appendMessageOperationWithFolder:folder messageData:messageData flags:MCOMessageFlagSeen];
    
    [op start:^(NSError * error, uint32_t currentId) {
        if (error) {
            DDLogError(@"MCOIMAPAppendMessageOperation error:%@",error);
            if (failure) {
                failure (error);
            }
        } else {
            if (success) {
                success (nil);
            }
        }
    }];
}

- (NSData *)buildMessageDataWithMail:(MCMailModel *)mail
{
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    NSMutableArray *toAdds = [[NSMutableArray alloc] init];
    for(MCMailAddress *toAddress in mail.to) {
        MCOAddress *newAddress = [MCOAddress addressWithDisplayName:[toAddress.name trimNewLine] mailbox:toAddress.email];
        [toAdds  addObject:newAddress];
    }
    [[builder header] setTo:toAdds];
    NSMutableArray *ccAdds = [[NSMutableArray alloc] init];
    for(MCMailAddress *ccAddress in mail.cc) {
        MCOAddress *newAddress = [MCOAddress addressWithDisplayName:[ccAddress.name trimNewLine] mailbox:ccAddress.email];
        [ccAdds addObject:newAddress];
    }
    [[builder header] setCc:ccAdds];
    NSMutableArray *bccAdds = [[NSMutableArray alloc] init];
    for(MCMailAddress *bccAddress in mail.bcc) {
        MCOAddress *newAddress = [MCOAddress addressWithDisplayName:[bccAddress.name trimNewLine] mailbox:bccAddress.email];
        [bccAdds addObject:newAddress];
    }
    [[builder header] setBcc:bccAdds];
    
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:self.account.displayName mailbox:self.account.email]];
    [[builder header] setSubject:mail.subject];
    
    if (mail.messageId) {
        NSMutableArray *inRelyTos;
        if (mail.inReplyTo) {
            inRelyTos = [mail.inReplyTo mutableCopy];
            if (![inRelyTos containsObject:mail.messageId]) {
                [inRelyTos addObject:mail.messageId];
            }
        } else {
            inRelyTos = [@[mail.messageId] mutableCopy];
        }
        [[builder header] setInReplyTo:inRelyTos];
        
        NSMutableArray *references;
        if (mail.references) {
            references = [mail.references mutableCopy];
            if (![references containsObject:mail.messageId]) {
                [references addObject:mail.messageId];
            }
        } else {
            references = [@[mail.messageId] mutableCopy];
        }
        [[builder header] setReferences:references];
    }
    mail.messageId = [NSString stringWithFormat:@"%@@%@",[MCUDID newUUID],[builder.header.from.mailbox mailDomain]];
    [[builder header] setMessageID:mail.messageId];
    
    NSString*customMailUID;
    
    if (!mail.customMarkId) {
        customMailUID = [MCUDID newUUID];
    } else {
        customMailUID = mail.customMarkId;
    }
    mail.customMarkId = customMailUID;
    
    [[builder header] setExtraHeaderValue:customMailUID forName:MCMailNeedToSynchKey];
    [builder setHTMLBody:[self replaceSignatureWithContentHTML:mail.messageContentHtml]];
    
    for (MCMailAttachment *mailAttachment in mail.attachments) {
        MCOAttachment *mCOAttchment = [MCOAttachment attachmentWithData:mailAttachment.data filename:mailAttachment.name];
        if (mailAttachment.mimeType) {
            mCOAttchment.mimeType = mailAttachment.mimeType;
            //"message/RFC822" 暂作处理eml格式附件的mimeType（message/RFC822）避免奔溃
            if ([mailAttachment.fileExtension isEqualToString:@"eml"]) {
                mCOAttchment.mimeType = @"eml";
            }
        }
        mCOAttchment.attachment = YES;
        [builder addAttachment:mCOAttchment];
    }
    
    //inline attachment
    for (MCMailAttachment *mailAttachment in mail.inlineAttachments) {
        MCOAttachment *mCOAttachment = [MCOAttachment attachmentWithData:mailAttachment.data filename:mailAttachment.name];
        mCOAttachment.contentID = mailAttachment.cid;
        mCOAttachment.inlineAttachment = YES;
        [builder addRelatedAttachment:mCOAttachment];
    }
    
    return [builder data];
}

//prative
//设置邮洽默认签名链接
- (NSString*)replaceSignatureWithContentHTML:(NSString*)html {
    
    NSRange range;
    while ((range = [html rangeOfString:@"发自邮洽"]).location != NSNotFound) {
        html = [html stringByReplacingCharactersInRange:range withString:@"发自<a href=\"http://mailchat.cn/\" style=\"color:#4284d9;\">邮洽</a>"];
    }
    return html;
    
}

//取消当前请求操作
- (void)cancelImapOprations {
    [self.imapSession cancelAllOperations];
}
- (void)cancelSmtpOprations {
    [self.smtpSession cancelAllOperations];
}

#pragma mark - Private

- (void)disconnect
{
    if (_imapSession) {
        MCOIMAPOperation *op = [self.imapSession disconnectOperation];
        [op start:^(NSError * _Nullable error) {
            if (error) {
                DDLogError(@"disconnectOperation %@",error);
            }
        }];
    }
    
    _imapSession = nil;
    _smtpSession = nil;
}

- (MCOSMTPSession *)smtpSessionWithAccount:(MCAccount *)account
{
    MCMailConfigItem *smtp = account.config.smtp;
    
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.checkCertificateEnabled = NO;
    smtpSession.timeout = 30;
    smtpSession.hostname = smtp.hostName;
    smtpSession.port = (uint)smtp.port;
    smtpSession.username = account.email;
    smtpSession.connectionType = smtp.ssl > 0 ? MCOConnectionTypeTLS : MCOConnectionTypeClear;
    if (smtp.ssl == 1 || [smtp.hostName rangeOfString:@"outlook"].location !=NSNotFound) {
        smtpSession.connectionType = MCOConnectionTypeStartTLS;
    }
    smtpSession.checkCertificateEnabled = NO;
    
    if (account.authType == MCAccountAuthTypeOAuth) {
        smtpSession.authType = MCOAuthTypeXOAuth2;
        smtpSession.OAuth2Token = account.password;
    }
    else {
        smtpSession.authType = MCOAuthTypeSASLLogin;
        smtpSession.password = account.password;
    }
    
    smtpSession.connectionLogger = ^(void * connectionID, MCOConnectionLogType type, NSData * data)
    {
        NSString *logText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (type >= MCOConnectionLogTypeErrorParse) {
            DDLogError(@"%@",logText);
        }
        else{
            DDLogDebug(@"%@",logText);
        }
    };
    
    smtpSession.dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    return smtpSession;
}

- (MCOIMAPSession*)imapSessionWithAccount:(MCAccount *)account
{
    MCMailConfigItem *imap = account.config.imap;
    
    MCOIMAPSession*imapSession = [[MCOIMAPSession alloc] init];
    imapSession.hostname = imap.hostName;
    imapSession.port = (uint)imap.port;
    imapSession.username = account.email;
    imapSession.maximumConnections = 10;
    imapSession.timeout = 30;
    imapSession.checkCertificateEnabled = NO;
    imapSession.connectionType = imap.ssl> 0 ? MCOConnectionTypeTLS : MCOConnectionTypeClear;;
    if (account.authType == MCAccountAuthTypeOAuth) {
        imapSession.authType = MCOAuthTypeXOAuth2;
        imapSession.OAuth2Token = account.password;
    }
    else {
        imapSession.password = account.password;
    }
    
    imapSession.connectionLogger = ^(void * connectionID, MCOConnectionLogType type, NSData * data)
    {
        NSString *logText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (type >= MCOConnectionLogTypeErrorParse) {
            DDLogError(@"%@",logText);
        }
        else{
            DDLogVerbose(@"%@",logText);
        }
    };
    
    imapSession.dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    return imapSession;
    
}

/**
 *  网易邮箱禁用第三方客户端，这边发一个欺骗的identity给它
 */
- (void)sendClientIdentifyToServerIfNeeded
{
    MCOIMAPCapabilityOperation * op = [self.imapSession capabilityOperation];
    [op start:^(NSError * error, MCOIndexSet * capabilities) {
        if ([capabilities containsIndex:MCOIMAPCapabilityId]) {
            MCOIMAPIdentity * identity = [MCOIMAPIdentity identityWithVendor:@"tencent limited" name:@"com.tencent.foxmail" version:@"7.2.6.42"];
            [identity setInfo:@"window" forKey:@"os"];
            [identity setInfo:@"6.1" forKey:@"os-version"];
            [identity setInfo:@"foxmail@foxmail.com" forKey:@"contact"];
            MCOIMAPIdentityOperation * op1 = [self.imapSession identityOperationWithClientIdentity:identity];
            [op1 start:^(NSError *  error1, NSDictionary * serverIdentity) {
                if (error) {
                    DDLogError(@"Set IMAP Identity error = %@",error);
                }
            }];
        }
    }];
}

- (MCMailBox *)mailBoxFromImapFolder:(MCOIMAPFolder *)imapFolder
{
    MCMailBox *box = [MCMailBox new];
    box.path = imapFolder.path;
    box.delimiter = imapFolder.delimiter;
    box.flags = imapFolder.flags;
    box.accountId = self.account.accountId == 0?AppStatus.currentUser.accountId:self.account.accountId;
    
    NSString *delimiterString = [NSString stringWithFormat:@"%c",box.delimiter];
    NSArray *nameArray = [imapFolder.path componentsSeparatedByString:delimiterString];
    NSString *folderDisplayName = [nameArray lastObject];
    const char *stringAsChar = [folderDisplayName cStringUsingEncoding:[NSString defaultCStringEncoding]];
    folderDisplayName = [NSString stringWithCString:stringAsChar encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF7_IMAP)];
    box.name = folderDisplayName;
    if (imapFolder.flags & MCOIMAPFolderFlagFolderTypeMask) {
        if (imapFolder.flags & MCOIMAPFolderFlagInbox) {
            box.type = MCMailFolderTypeInbox;
        }
        else if (imapFolder.flags & MCOIMAPFolderFlagSentMail){
            box.type = MCMailFolderTypeSent;
        }
        else if (imapFolder.flags & MCOIMAPFolderFlagSpam){
            box.type = MCMailFolderTypeSpam;
        }
        else if (imapFolder.flags & MCOIMAPFolderFlagStarred){
            box.type = MCMailFolderTypeStarred;
        }
        else if (imapFolder.flags & MCOIMAPFolderFlagTrash){
            box.type = MCMailFolderTypeTrash;
        }
        else if (imapFolder.flags & MCOIMAPFolderFlagDrafts){
            box.type = MCMailFolderTypeDrafts;
        }
        else{
            box.type = MCMailFolderTypeOther;
        }
        box.haveIMAPfolderFlag = YES;
    }
    else{
        
        NSString *folderPath = imapFolder.path;
        // 2.0 的邮箱文件夹都是以 INBOX. 开头的，这边处理一下
        if ([folderPath hasPrefix:@"INBOX."]) {
            folderPath = [imapFolder.path substringFromIndex:6];
        }
        
        //根据名称来判断文件夹类型
        if ([self folderPath:imapFolder.path equalsTo:@"INBOX"]) {
            box.type = MCMailFolderTypeInbox;
        }
        else if ([self folderPath:folderPath equalsTo:@"Draft"]||
                 [self folderPath:folderPath equalsTo:@"draft"]||
                 [self folderPath:folderPath equalsTo:@"Drafts"]||
                 [self folderPath:folderDisplayName equalsTo:@"草稿箱"]||
                 [self folderPath:folderDisplayName equalsTo:@"草稿"]){
            box.type = MCMailFolderTypeDrafts;
        }
        else if ([self folderPath:folderPath equalsTo:@"Sent"]||
                 [self folderPath:folderPath equalsTo:@"sent"]||
                 [self folderPath:folderPath equalsTo:@"Sent Messages"]||
                 [self folderPath:folderPath equalsTo:@"Sent Items"]||
                 [self folderPath:folderDisplayName equalsTo:@"已发送"]||
                 [self folderPath:folderDisplayName equalsTo:@"已发送邮件"]||
                 [self folderPath:folderPath equalsTo:@"Outbox"]){
            box.type = MCMailFolderTypeSent;
        }
        else if ([self folderPath:folderPath equalsTo:@"Spam"] ||
                 [self folderPath:folderPath equalsTo:@"spam"] ||
                 [self folderPath:folderPath equalsTo:@"Junk"]||
                 [self folderPath:folderPath equalsTo:@"junk"]||
                 [self folderPath:folderDisplayName equalsTo:@"垃圾箱"]||
                 [self folderPath:folderDisplayName equalsTo:@"垃圾邮件"]){
            box.type = MCMailFolderTypeSpam;
        }
        else if ([self folderPath:folderPath equalsTo:@"Trash"] ||
                 [self folderPath:folderPath equalsTo:@"trash"] ||
                 [self folderPath:folderPath equalsTo:@"Delete"]||
                 [self folderPath:folderPath equalsTo:@"Deleted Messages"]||
                 [self folderPath:folderPath equalsTo:@"Deleted Items"]||
                 [self folderPath:folderDisplayName equalsTo:@"已删除"]||
                 [self folderPath:folderDisplayName equalsTo:@"已删除邮件"]){
            box.type = MCMailFolderTypeTrash;
        }
        else{
            box.type = MCMailFolderTypeOther;
        }
    }
    
    return box;
}

- (BOOL)folderPath:(NSString *)path equalsTo:(NSString *)name
{
    //imap常规文件夹格式相对固定几个，根据range判断可能有误，直接比较为好
    return [path isEqualToString:name];
}

- (BOOL)isIgnoreFolder:(MCMailBox *)box
{
    static NSArray *ignoreFolderPaths = nil;
    if (!ignoreFolderPaths) {
        ignoreFolderPaths = @[@"&UXZO1mWHTvZZOQ-" //QQ Notes
//                              @"Notes"
                              ];
    }
    
    return [ignoreFolderPaths containsObject:box.path];
}

+ (MCOConnectionType)connectionTypeWithEncryptType:(MCMailEncryptType)encryptType
{
    if (encryptType == MCMailEncryptNone) {
        return MCOConnectionTypeClear;
    }
    else if (encryptType == MCMailEncryptTLS){
        return MCOConnectionTypeStartTLS;
    }
    else{
        return MCOConnectionTypeTLS;
    }
}

+ (MCMailModel *)mailModelWithIMAPMessage:(MCOIMAPMessage *)imapMsg folder:(MCMailBox *)folder
{
    MCMailModel *mailModel = [MCMailModel new];
    [self updateMailModel:mailModel withImapMessage:imapMsg folder:folder];
    return mailModel;
}

+ (void)updateMailModel:(MCMailModel *)mailModel withImapMessage:(MCOIMAPMessage *)imapMsg folder:(MCMailBox *)folder
{
    mailModel.accountId = folder.accountId;
    mailModel.boxId = folder.uid;
    mailModel.folder = folder.path;
    mailModel.messageUid = imapMsg.uid;
    mailModel.messageId = imapMsg.header.messageID;
    mailModel.subject = imapMsg.header.subject;
    mailModel.references = imapMsg.header.references;
    mailModel.inReplyTo = imapMsg.header.inReplyTo;
    mailModel.from = [[self class] mailAddressWithIMAPAddress:imapMsg.header.from];
    mailModel.to = [[self class] addressArrayWithImapAddressArray:imapMsg.header.to];
    mailModel.cc = [[self class] addressArrayWithImapAddressArray:imapMsg.header.cc];
    mailModel.bcc = [[self class] addressArrayWithImapAddressArray:imapMsg.header.bcc];
    mailModel.replyTo = [[self class] addressArrayWithImapAddressArray:imapMsg.header.replyTo];
//    mailModel.isRead = imapMsg.flags & MCOMessageFlagSeen;
//    mailModel.isStar = imapMsg.flags & MCOMessageFlagFlagged;
    mailModel.mailFlags = (MCMailFlags)imapMsg.flags;
    mailModel.receivedDate = imapMsg.header.receivedDate;
    mailModel.date   = imapMsg.header.date;
    mailModel.customMarkId = [imapMsg.header extraHeaderValueForName:MCMailNeedToSynchKey];
    mailModel.xPriority = [[imapMsg.header extraHeaderValueForName:@"X-Priority"] integerValue];
    //TODO:如何判断是否有附件
    if (imapMsg.mainPart) {
        mailModel = [self mailAttachmentModelWith:mailModel imapMessage:imapMsg folder:folder];
    }
}

+ (MCMailModel *)mailModelWithIMAPMessageParser:(MCOMessageParser *)parserMsg uid:(NSUInteger)uid folder:(MCMailBox *)folder
{
    MCMailModel *mailModel = [MCMailModel new];
    mailModel.messageUid = uid;
    [self updateMailModel:mailModel withMailParser:parserMsg folder:folder];
    return mailModel;
}


+ (void)updateMailModel:(MCMailModel *)mailModel withMailParser:(MCOMessageParser *)parserMsg folder:(MCMailBox *)folder
{
    mailModel.accountId = folder.accountId;
    mailModel.boxId = folder.uid;
    mailModel.folder = folder.path;
    mailModel.messageId = parserMsg.header.messageID;
    mailModel.subject = parserMsg.header.subject;
    mailModel.references = parserMsg.header.references;
    mailModel.inReplyTo = parserMsg.header.inReplyTo;
    mailModel.from = [[self class] mailAddressWithIMAPAddress:parserMsg.header.from];
    mailModel.to = [[self class] addressArrayWithImapAddressArray:parserMsg.header.to];
    mailModel.cc = [[self class] addressArrayWithImapAddressArray:parserMsg.header.cc];
    mailModel.bcc = [[self class] addressArrayWithImapAddressArray:parserMsg.header.bcc];
    mailModel.replyTo = [[self class] addressArrayWithImapAddressArray:parserMsg.header.replyTo];
    mailModel.messageContentHtml = parserMsg.htmlBodyRendering;
    mailModel.messageContentString = parserMsg.plainTextRendering;
    mailModel.receivedDate = parserMsg.header.receivedDate;
    mailModel.date   = parserMsg.header.date;
    mailModel.customMarkId = [parserMsg.header extraHeaderValueForName:MCMailNeedToSynchKey];
    //TODO:如何判断是否有附件
    NSMutableArray *parserAttach = [NSMutableArray new];
    if (parserMsg.attachments) {
        parserAttach = [parserMsg.attachments mutableCopy];
    }
    if (parserMsg.htmlInlineAttachments) {
        [parserAttach addObjectsFromArray:parserMsg.htmlInlineAttachments];
    }
    NSMutableArray *attach = [NSMutableArray new];
    NSMutableArray *inlineAttach = [NSMutableArray new];
    for (MCOAttachment *mcoAttachment in parserAttach) {
        MCMailAttachment *mailAttachmet = [MCMailAttachment new];
        mailAttachmet.mailUid = mailModel.messageUid;
        mailAttachmet.from = mailModel.from;
        mailAttachmet.size = mcoAttachment.data.length;
        mailAttachmet.partId = [MCUDID newUUID];
        mailAttachmet.mimeType = mcoAttachment.mimeType;
        mailAttachmet.name = mcoAttachment.filename;
        mailAttachmet.fileExtension = mcoAttachment.filename.pathExtension;
        mailAttachmet.data = mcoAttachment.data;
        mailAttachmet.receiveDate = [mailModel.receivedDate timeIntervalSince1970];
        mailAttachmet.cid = mcoAttachment.contentID;
        mailAttachmet.partFolder = folder.path;
        if (mailAttachmet.cid) {
            [inlineAttach addObject:mailAttachmet];
        } else {
            [attach insertObject:mailAttachmet atIndex:0];
            mailModel.hasAttachment = YES;
        }
    }
    mailModel.attachments = attach;
    mailModel.inlineAttachments = inlineAttach;
}


+ (MCMailAddress *)mailAddressWithIMAPAddress:(MCOAddress *)imapAddress
{
    if (!imapAddress) {
        return nil;
    }
    if (!imapAddress.displayName && !imapAddress.mailbox) {
        return nil;
    }
    MCMailAddress *address = [MCMailAddress new];
    address.name = imapAddress.displayName?imapAddress.displayName:imapAddress.mailbox;
    address.email = imapAddress.mailbox;
    return address;
}

+ (NSArray *)addressArrayWithImapAddressArray:(NSArray *)addresses
{
    if (addresses == nil) {
        return nil;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:addresses.count];
    for (MCOAddress *addr in addresses) {
        MCMailAddress *mailAddr = [[self class] mailAddressWithIMAPAddress:addr];
        [array addObject:mailAddr];
    }
    
    return array;
}

- (MCOIMAPMessagesRequestKind)mcorequestKindWithMCRequestKind:(MCIMAPMessageRequestKind)requestKind
{
    MCOIMAPMessagesRequestKind imapRequestKind;
    
    if (requestKind == MCIMAPMessageRequestKindUid) {
        imapRequestKind = MCOIMAPMessagesRequestKindUid;
    }
    else if (requestKind == MCIMAPMessageRequestKindFlags) {
        imapRequestKind = MCOIMAPMessagesRequestKindFlags;
    } else {
        imapRequestKind = (MCOIMAPMessagesRequestKind)
        (MCOIMAPMessagesRequestKindFullHeaders | MCOIMAPMessagesRequestKindStructure|
         MCOIMAPMessagesRequestKindInternalDate |
         MCOIMAPMessagesRequestKindFlags|MCOIMAPMessagesRequestKindExtraHeaders);
    }
   
    return imapRequestKind;
}

- (MCOIMAPSearchExpression*)mailcoreSearchExpWithSearchKind:(MCSearchMailKind)searchKind searchText:(NSString*)searchText {
    
    int mailType =  self.account.type;
    MCOIMAPSearchExpression *searchExp;
    MCOIMAPSearchExpression * exprContent = [MCOIMAPSearchExpression searchBody:searchText];
    MCOIMAPSearchExpression * exprSubject = [MCOIMAPSearchExpression searchSubject:searchText withSearchType:mailType];
    MCOIMAPSearchExpression * exprCc      = [MCOIMAPSearchExpression searchCc:searchText];
    MCOIMAPSearchExpression * exprTo      = [MCOIMAPSearchExpression searchTo:searchText];
    MCOIMAPSearchExpression * exprRecipient = [MCOIMAPSearchExpression searchOr:exprCc other:exprTo withSearchType:mailType];
    MCOIMAPSearchExpression * exprFrom    = [MCOIMAPSearchExpression searchFrom:searchText withSearchType:mailType];
    MCOIMAPSearchExpression * exprSet1    = [MCOIMAPSearchExpression searchOr:exprFrom other:exprContent withSearchType:mailType];
    MCOIMAPSearchExpression * exprSet2    = [MCOIMAPSearchExpression searchOr:exprSubject other:exprSet1 withSearchType:mailType];
    MCOIMAPSearchExpression * searchAll   = [MCOIMAPSearchExpression searchOr:exprTo other:exprSet2 withSearchType:mailType];
    
    switch (searchKind) {
        case MCSearchMailKindAll:
            searchExp = searchAll;
            break;
        case MCSearchMailKindFrom:
            searchExp = exprFrom;
            break;
        case MCSearchMailKindTo:
            searchExp = exprRecipient;
            break;
        case MCSearchMailKindSubject:
            searchExp = exprSubject;
            break;
    }
    
    return searchExp;
}


//TODO: save attachments
+(MCMailModel*)mailAttachmentModelWith:(MCMailModel*)mailModel imapMessage:(MCOIMAPMessage*)imapMessage folder:(MCMailBox*)folder{
    
    BOOL haveAttachment = NO;
    NSMutableArray*attachments = [NSMutableArray new];//MCMailAttachment聚合
    NSMutableArray*inlineAtttchments = [NSMutableArray new];
    NSMutableArray*imapParts = [NSMutableArray new];//原始附件与内嵌附件
    [imapParts addObjectsFromArray:imapMessage.attachments];
    [imapParts addObjectsFromArray:imapMessage.htmlInlineAttachments];
    
    for (MCOIMAPPart*imapPart in imapParts) {
        MCMailAttachment *attachment = [MCMailAttachment new];
        attachment.mailUid = imapMessage.uid;
        attachment.partId  = imapPart.partID;
        attachment.name    = imapPart.filename;
        if (!attachment.name) {
            attachment.name = [MCUDID newUUID];
        }
        attachment.fileExtension = [imapPart.filename pathExtension];
        //TODO: 有可能出现 MCOIMAPMultipart  不存在size
        if ([imapPart isKindOfClass:[MCOIMAPPart class]]) {
            attachment.size  = [imapPart decodedSize];
            attachment.partEncode = (MCAttachEncode)imapPart.encoding;
        }else {
            attachment.size  = 1;
            attachment.partEncode = MCAttachEncodeBase64;
        }
        
        attachment.cid     = imapPart.contentID;
        attachment.receiveDate = [mailModel.receivedDate timeIntervalSince1970];
        attachment.from = mailModel.from;
        if (!haveAttachment) {
            haveAttachment = attachment.cid?NO:YES;
        }
        attachment.mimeType = imapPart.mimeType;
        attachment.partFolder = folder.path;
        if (attachment.cid) {
           [inlineAtttchments addObject:attachment];
        } else {
            [attachments insertObject:attachment atIndex:0];
        }
    }
    mailModel.hasAttachment = haveAttachment;
    mailModel.attachments = attachments;
    mailModel.inlineAttachments = inlineAtttchments;
    return mailModel;
}

#pragma mark 默认拥有待发送，收藏夹

- (MCMailBox *)defaultStarBox {
    MCMailBox * starBox = [MCMailBox new];
    starBox.name =  PMLocalizedStringWithKey(@"PM_Mail_FolderOptionCollect");
    starBox.type = MCMailFolderTypeStarred;
    starBox.accountId = self.account.accountId == 0 ?AppStatus.currentUser.accountId:self.account.accountId;
    return starBox;
}

- (MCMailBox *)defaultPendingBox {
    //待发送
    MCMailBox * pendingBox = [MCMailBox new];
    pendingBox.name = PMLocalizedStringWithKey(@"PM_Mail_FolderOptionOutBox");
    pendingBox.path = @"pendingMail";
    pendingBox.type = MCMailFolderTypePending;
    pendingBox.accountId = self.account.accountId == 0 ?AppStatus.currentUser.accountId:self.account.accountId;
    return pendingBox;
}

@end
