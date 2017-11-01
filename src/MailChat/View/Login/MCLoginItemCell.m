//
//  MCLoginItemCell.m
//  NPushMail
//
//  Created by zhang on 16/1/19.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCLoginItemCell.h"

const static CGFloat kMCLoginItemCellSize = 106.0;
const static CGFloat kMCLoginItemCellItemImageViewHight    = 50.0;
const static CGFloat kMCLoginItemCellItemImageViewWidth    = 90.0;
const static CGFloat kMCLoginItemCellItemNameLableHight    = 15.0;
const static CGFloat kMCLoginItemCellItemNameLableFontSize = 13.0;

@interface MCLoginItemCell()
@property(nonatomic,strong)UIImageView *itemImageView;//邮箱图标
@property(nonatomic,strong)UIImageView *googleNoteImageView;
@property(nonatomic,strong)UILabel     *itemNameLable; //邮箱名称
@end


@implementation MCLoginItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    
    return self;
}

- (void)setUp {
    
    UIView*view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kMCLoginItemCellSize, kMCLoginItemCellSize)];
    view.center = self.contentView.center;
    view.backgroundColor = [UIColor clearColor];
    
    _itemImageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 21, kMCLoginItemCellItemImageViewWidth, kMCLoginItemCellItemImageViewHight)];
    [view addSubview:_itemImageView];
    
    _itemNameLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, kMCLoginItemCellSize, kMCLoginItemCellItemNameLableHight)];
    _itemNameLable.textAlignment = NSTextAlignmentCenter;
    _itemNameLable.textColor = [UIColor colorWithHexString:@"808080"];
    _itemNameLable.font = [UIFont systemFontOfSize:kMCLoginItemCellItemNameLableFontSize];
    [view addSubview:_itemNameLable];
    [self.contentView addSubview:view];
    //Google提示标志
    _googleNoteImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 54, 0, 54, 54)];
    _googleNoteImageView.image = [UIImage imageNamed:@"mc_googleNote.png"];
    [self.contentView addSubview:_googleNoteImageView];
}

- (void)setItemDictionary:(NSDictionary *)itemDictionary{
    _itemNameLable.text = [[itemDictionary allKeys] firstObject];
    _itemImageView.image = [UIImage imageNamed:[[itemDictionary allValues] firstObject]];
}

- (void)setGoogleNote:(BOOL)googleNote {
    _googleNoteImageView.hidden = !googleNote;
}

@end
