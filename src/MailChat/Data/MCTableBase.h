//
//  MCTableBase.h
//  NPushMail
//
//  Created by admin on 12/22/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@protocol MCDatabaseTableProtocol <NSObject>

- (NSArray *)allModels;
- (id)getModelById:(NSInteger)uid;
- (void)insertModel:(id)model;
- (void)updateModel:(id)model;
- (void)deleteById:(NSInteger)uid;


@end

@interface MCTableBase : NSObject<MCDatabaseTableProtocol>

@property (nonatomic,readonly) FMDatabaseQueue *dbQueue;

- (instancetype)initWithDbQueue:(FMDatabaseQueue *)queue;

@end
