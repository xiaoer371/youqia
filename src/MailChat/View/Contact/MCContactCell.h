//
//  MCContactCell.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/4.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

typedef enum : NSUInteger {
    forContactView,         //联系人界面
    forNoMessageView,       //无消息提醒界面
} forWithViewType;          //控制来自哪个界面

@interface MCContactCell : MGSwipeTableCell

@property (nonatomic, assign) BOOL isSelected;
/**
 *  控制是否可以选择
 */
@property (nonatomic, strong) UIButton *canSelectBtn;
@property (weak, nonatomic) IBOutlet UIImageView *headerImgView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *youQiaFlagLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel; //权重显示了label
@property (weak, nonatomic) IBOutlet UIButton *inviteBtn;  //邀请标签 按钮
//选中状态
- (void)changeSelectedState;
+ (instancetype)instanceFromNib;
- (void)configureCellWithModel:(id)model;
@end
