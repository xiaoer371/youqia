//
//  MCIMChatContactView.h
//  NPushMail
//
//  Created by swhl on 16/3/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MCIMChatContactViewTypeSingle    = 0,
    MCIMChatContactViewTypeGroupDel  = 1,
    MCIMChatContactViewTypeGroupNoDel  = 2
} MCIMChatContactViewType;


@class MCIMChatContactCellModel;
@protocol MCIMChatContactViewDelegate <NSObject>

@required

@optional

-(BOOL)deleteWihthItemModel:(MCIMChatContactCellModel *)model;

-(void)didSelectItem:(MCIMChatContactCellModel *)model;

-(void)addDataSourceItem;

-(void)deleteDataSourceItem;

-(void)didReloadDataSourceFrame:(CGRect)newFrame;


/**
 * 添加成员变成群聊
 */
-(void)didSelectAddContactToGroup;

/**
 * 查看群成员
 */
-(void)didSelectGroupMembers;

@end

@interface MCIMChatContactView : UIView
{
    
}
@property (nonatomic, weak) id <MCIMChatContactViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray            *dataArray;
@property (nonatomic, assign) CGPoint          originPoint;
@property (nonatomic) MCIMChatContactViewType    type;



-(instancetype)initWithFrame:(CGRect)frame
                  dataSource:(NSArray *)array
                        type:(MCIMChatContactViewType)type;


-(void)addItemsWithModels:(NSArray <__kindof MCIMChatContactCellModel *> *)models;

-(void)deleteItemsWithModels:(NSArray <__kindof MCIMChatContactCellModel *> *)models;

@end

