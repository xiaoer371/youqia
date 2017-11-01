//
//  MCMailProviderProtocol.h
//  NPushMail
//
//  Created by admin on 12/25/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailBox.h"
#import "MCMailModel.h"
#import "MCMailAttachment.h"
#import "MCMailConfig.h"
#import "MCMailBoxInfo.h"
#import "MCMailConstants.h"
#import "MCAccount.h"

typedef NS_OPTIONS(NSUInteger, MCIMAPMessageRequestKind){
    MCIMAPMessageRequestKindUid = 0,
    MCIMAPMessageRequestKindFlags = 1 << 0,
    MCIMAPMessageRequestKindFullHeaders = 1 << 4
};


//搜索条件类别
typedef NS_ENUM(NSInteger, MCSearchMailKind) {
    MCSearchMailKindAll = 0,
    MCSearchMailKindSubject,
    MCSearchMailKindTo,
    MCSearchMailKindFrom
};

/**
 *  邮件操作接口，用于隔离各种协议
 */
@protocol MCMailProviderProtocol <NSObject>

@property (nonatomic,strong,readonly) MCAccount *account;

- (instancetype)initWithAccount:(MCAccount *)account;

/**
 验证信息改了以后，要重新验证
 */
- (void)refreshAuthentication;

#pragma mark - Authenticate


- (void)loginSuccess:(ActionBlock)success failure:(FailureBlock)failure;

#pragma mark - Folder


- (void)getAllFoldersSuccess:(SuccessBlock)success
                     failure:(FailureBlock)failure;

- (void)getFolderInfo:(NSString *)folder
              success:(SuccessBlock)success
              failure:(FailureBlock)failure;

#pragma mark - Mails

- (void)getMailsByNumbersInFolder:(MCMailBox *)folder
                      requestKind:(MCIMAPMessageRequestKind)requestKind
                          numbers:(NSRange)numbers
                          success:(SuccessBlock)success
                          failure:(FailureBlock)failure;

- (void)getMailsByUidsInFolder:(MCMailBox *)folder
                   requestKind:(MCIMAPMessageRequestKind)requestKind
                          uids:(NSIndexSet *)uids
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure;

/**
 *  更新邮件的头部
 */
- (void)updateMails:(NSArray *)mails
           inFolder:(MCMailBox *)folder
        requestKind:(MCIMAPMessageRequestKind)requestKind
            success:(SuccessBlock)success
            failure:(FailureBlock)failure;


- (void)getAttachmentData:(MCMailAttachment*)attachment
                 progress:(ProgressBlock)progrss
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure;

/**
 *  更新邮件的内容
 */
- (void)updateMailContent:(MCMailModel*)mailModel
                 inFolder:(MCMailBox *)folder
                   urgent:(BOOL)urgent
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure;

- (void)getFullMailFolder:(MCMailBox*)folder
                    byUid:(NSInteger)uid
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure;

- (void)fetchFullMail:(MCMailModel *)mail
             inFolder:(MCMailBox *)folder
              success:(ActionBlock)success
              failure:(FailureBlock)failure;

- (void)storeFlag:(MCMailFlags)flag
          toMails:(NSArray *)uids
        storeKind:(MCMailFlagStoreKind)storeKind
          success:(ActionBlock)success
          failure:(FailureBlock)failure;

- (void)moveMails:(NSArray *)uids
       fromFolder:(NSString *)fromFolder
         toFolder:(NSString *)toFolder
          success:(ActionBlock)success
          failure:(FailureBlock)failure;

#pragma mark - Search

- (void)searchMailsWithFolder:(NSString*)folder
                   searchKind:(MCSearchMailKind)searchKind
                   searchText:(NSString*)searchText
                      success:(SuccessBlock)success
                      failure:(FailureBlock)failure;

#pragma mark - Send

- (void)smtpConnectWithSuccess:(SuccessBlock)success
                       failure:(FailureBlock)failure;

- (void)sendEmailWithData:(NSData*)messageData
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure
                 progress:(ProgressBlock)progress;

- (void)appendMailWithData:(NSData*)messageData
                    folder:(NSString*)folder
                    isSent:(BOOL)isSent
                   success:(SuccessBlock)success
                   failure:(FailureBlock)failure;

- (NSData *)buildMessageDataWithMail:(MCMailModel *)mail;

#pragma mark - Utils

- (void)cancelImapOprations;

- (void)cancelSmtpOprations;
@end
