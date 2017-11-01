//
//  MCMailConstants.h
//  NPushMail
//
//  Created by admin on 1/20/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kMailChatEmailErrorDomain = @"com.mailchat.domain.error";

/**
 邮件的状态
 */
//typedef NS_OPTIONS(NSInteger, MCMailFlags){
//    MCMailFlagNone = 0,
//    MCMailFlagSeen = 1 << 0,
//    MCMailFlagStar = 1 << 1,
//    mcMailFlagAnswer = 1 << 2
//};

typedef NS_OPTIONS(NSInteger, MCMailFlags) {
    MCMailFlagNone          = 0,
    /** Seen/Read flag.*/
    MCMailFlagSeen          = 1 << 0,
    /** Replied/Answered flag.*/
    MCMailFlagAnswered      = 1 << 1,
    /** Flagged/Starred flag.*/
    MCMailFlagStar          = 1 << 2,
    /** Deleted flag.*/
    MCMailFlagDeleted       = 1 << 3,
    /** Draft flag.*/
    MCMailFlagDraft         = 1 << 4,
    /** $MDNSent flag.*/
    MCMailFlagMDNSent       = 1 << 5,
    /** $Forwarded flag.*/
    MCMailFlagForwarded     = 1 << 6,
    /** $SubmitPending flag.*/
    MCMCMailFlagSubmitPending = 1 << 7,
    /** $Submitted flag.*/
    MCMailFlagSubmitted     = 1 << 8,
};

typedef enum : NSUInteger {
    MCMailFlagStoreKindAdd,
    MCMailFlagStoreKindRemove,
    MCMailFlagStoreKindSet
} MCMailFlagStoreKind;

typedef enum : NSUInteger {
    MailChatFetchMailTypeNew,
    MailChatFetchMailTypeOld
} MailChatFetchMailType;

typedef enum : NSUInteger {
    MailChatErrorCodeUidValidityChanged
} MailChatErrorCode;



