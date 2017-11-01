//
//  MCQueue.m
//  NPushMail
//
//  Created by admin on 3/17/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCQueue.h"

@implementation MCQueue
{
    NSMutableArray *_mutableArray;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mutableArray = [NSMutableArray new];
    }
    return self;
}

- (void)enqueue:(id)obj
{
    @synchronized(_mutableArray) {
        [_mutableArray addObject:obj];
    }
}

- (id)dequeue
{
    @synchronized(_mutableArray) {
        if (_mutableArray.count > 0) {
            id obj = _mutableArray[0];
            [_mutableArray removeObjectAtIndex:0];
            return obj;
        }else{
            return nil;
        }
    }
}

@end
