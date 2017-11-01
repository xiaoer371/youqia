//
//  MCIMOACell.h
//  NPushMail
//
//  Created by swhl on 16/3/22.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCIMOAMessageModel.h"
#import "MCIMOAContentView.h"

@class MCIMOACell;
@protocol MCIMOACellDelegate <NSObject>

/**
 *  点击头像 查看用户详情
 *
 *  @param sender 回传 oamodel
 */
-(void)userHeadClick:(id)sender;
/**
 *  点击头像 查看oa详情
 *
 *  @param sender 回传 oamodel
 */
-(void)contentClick:(id)sender;

@end


@interface MCIMOACell : UITableViewCell

@property (nonatomic,weak) id<MCIMOACellDelegate> delegate;

@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic, assign)BOOL showTimeLabel;
@property (nonatomic,strong) UIImageView *userImageView;
@property (nonatomic,strong) UILabel *userNameLabel;
@property (nonatomic,strong) UIImageView *readFlagImgView;

@property (nonatomic,strong) MCIMOAContentView *cellView;

@property (nonatomic,strong) MCIMOAMessageModel *oaModel;


@end
