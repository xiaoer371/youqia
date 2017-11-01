//
//  MCGroup.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCGroup : NSObject

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *groupId;
@property (nonatomic, assign)int32_t sortId;
@property (nonatomic, strong)NSMutableArray *members;
@property (nonatomic, assign)BOOL switchFlag;//是否展开的标示
@property (nonatomic, assign)BOOL isSelected;//是否被选中，选择分组的时候用到
@property (nonatomic, assign)BOOL isDefaultGroup;//是否默认分组
@property (nonatomic, assign)int  defaultGroupSortId;//默认分组的排序
- (id)initWithName:(NSString *)name withGroupId:(NSString *)groupId withSortId:(int32_t)sortId withMembers:(NSMutableArray *)members withSwitchFlag:(BOOL)flag;

@end
