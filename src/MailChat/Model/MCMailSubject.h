//
//  MCMailSubject.h
//  NPushMail
//
//  Created by admin on 19/11/2016.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCMailSubject : NSObject

@property (nonatomic, assign, readonly) BOOL isReply;
@property (nonatomic, assign, readonly) BOOL isFoward;

/*
 * 真正的标题，去掉 回复，转发等
 */
@property (nonatomic, strong, readonly) NSString *realSubject;

@property (nonatomic,copy, readonly) NSString *subject;

- (instancetype)initWithSubject:(NSString *)subject;

@end
