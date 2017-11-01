//
//  MCIMChatContactCell.h
//  NPushMail
//
//  Created by swhl on 16/3/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCIMChatContactCellModel.h"

typedef enum : NSUInteger {
    MCDeleteBtnStateNormal = 0,
    MCDeleteBtnStateEditing = 1,
} MCDeleteState;

@class MCIMChatContactCell;

@protocol MCIMChatContactCellDelegate <NSObject>

//-(void)deleteCurrentItem:(MCIMChatContactCell*)item;

@end

@interface MCIMChatContactCell : UICollectionViewCell

@property (nonatomic, strong) MCIMChatContactCellModel *model;
@property (nonatomic, weak) id<MCIMChatContactCellDelegate> delegate;

@property (nonatomic) MCDeleteState deleteState;

-(void)StartShakeAnimations;

-(void)StopShakeAnimations;

-(void)resetTitleName:(NSString *)name;

@end
