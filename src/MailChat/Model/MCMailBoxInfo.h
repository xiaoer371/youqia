//
//  MCMailBoxStatus.h
//  NPushMail
//
//  Created by admin on 1/13/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCMailBoxInfo : NSObject

/** The folder's IMAP UIDNEXT value. Used to determine the uid for the next received message. */
@property (nonatomic, assign) uint32_t uidNext;

/** The folders IMAP UIDVALIDITY value. Must be used to determine if the server has changed assigned UIDs */
@property (nonatomic, assign) uint32_t uidValidity;

/** Number of messages in the folder */
@property (nonatomic, assign) uint32_t messageCount;

/** Highest modification sequence value for this folder. See CONDSTORE RFC 4551. */
@property (nonatomic, assign) uint64_t highestModSeqValue;

@end
