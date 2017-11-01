//
//  MCTouchIdHelper.h
//  NPushMail
//
//  Created by wuwenyu on 16/5/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^verficationToucIdReply)(BOOL success, NSError * error);

@interface MCTouchIdHelper : NSObject

+ (instancetype)shared;
- (void)verificationTouchIdWithOpenGesturePwd:(BOOL)gestureFlag title:(NSString *)title reply:(verficationToucIdReply)verficationReply;

@end
