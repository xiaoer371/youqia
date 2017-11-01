//
//  MCIMInvitationModel.h
//  NPushMail
//
//  Created by admin on 3/28/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCIMInvitationModel : NSObject

/**
 *  被邀请加入群组id
 */
@property (nonatomic,copy) NSString *groupId;
/**
 *  邀请人
 */
@property (nonatomic,copy) NSString *by;

/**
 *  邀请时间
 */
@property (nonatomic,assign) NSTimeInterval timeStamp;

@end
