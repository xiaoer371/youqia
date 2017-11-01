//
//  MCIMProcessor.m
//  NPushMail
//
//  Created by admin on 3/17/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMProcessor.h"
#import "MCIMMessageHandle.h"
#import "MCMessageParser.h"
#import "MCIMGroupCommandHandler.h"
#import "MCIMNotificationHandle.h"

@interface MCIMProcessor ()

@property (nonatomic,strong) NSArray *handlers;

@end

@implementation MCIMProcessor

- (instancetype)init
{
    self = [super init];
    if (self) {
        _handlers = @[[MCIMMessageHandle new],
                      [MCIMGroupCommandHandler new],
                      [MCIMNotificationHandle new]];
    }
    return self;
}

- (void)processData:(NSData *)data ofTopic:(NSString *)topic
{
    MCIMDataModel *dataModel = [MCMessageParser createMesssageWithTopic:topic data:data];
    if (dataModel) {
        for (id<MCIMHandleProtocol> handle in _handlers) {
            [handle processData:dataModel];
        }
    }
}

@end
