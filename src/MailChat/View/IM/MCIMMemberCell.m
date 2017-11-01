//
//  MCIMMemberCell.m
//  NPushMail
//
//  Created by swhl on 16/6/20.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMMemberCell.h"
#import "MCContactModel.h"


@interface MCIMMemberCell ()

@property (nonatomic, strong) UIImageView *headTagImageView;

@end


@implementation MCIMMemberCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    _headTagImageView = [[UIImageView alloc] initWithFrame: CGRectMake(CGRectGetMaxX(self.headerImgView.frame)-10, 3, 15, 15)];
    [self.contentView addSubview:_headTagImageView];
}

- (void)configureCellWithModel:(id)model
{
    [super configureCellWithModel:model];
    if ([model isMemberOfClass:[MCContactModel class]]) {
        MCContactModel *obj = (MCContactModel *)model;
        if (obj.groupMemberType ==MCModelStateOwner) {
            _headTagImageView .hidden = NO;
            _headTagImageView.frame = CGRectMake(CGRectGetMaxX(self.headerImgView.frame)-10, 3, 15, 15);
            _headTagImageView .image =[UIImage imageNamed:@"MCIMGroup_owner.png"];
        }else if (obj.groupMemberType ==MCModelStateMember){
            _headTagImageView .hidden = YES;
        }else{
            _headTagImageView .hidden = NO;
            _headTagImageView.frame = CGRectMake(CGRectGetMaxX(self.headerImgView.frame)-20, 3, 40, 16);
            _headTagImageView .image =[UIImage imageNamed:@"MCIMGroup_NoJion.png"];
        }
    }
}

@end
