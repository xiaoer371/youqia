//
//  MCFileTable.h
//  NPushMail
//
//  Created by wuwenyu on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCTableBase.h"

@class MCFileBaseModel;

@interface MCFileTable : MCTableBase

- (NSMutableArray *)getAllFiles;
- (NSMutableArray *)getFilesWithLocation:(NSString *)location;
- (BOOL)deleteFileWithFileName:(NSString *)fileName;
- (void)setCollectWithFileName:(NSString *)fileName isCollect:(BOOL)isCollect;
- (void)setLocationWithFileName:(NSString *)fileName location:(NSString *)location;
- (id)getModelByfileId:(NSString *)fileId;
@end
