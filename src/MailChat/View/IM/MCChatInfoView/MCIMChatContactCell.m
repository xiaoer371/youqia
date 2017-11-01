//
//  MCIMChatContactCell.m
//  NPushMail
//
//  Created by swhl on 16/3/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatContactCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+MCCorner.h"
const static NSInteger   xCellPaddingLeft = 0;
const static NSInteger   xCellPaddingTop  = 0;
const static NSInteger   xCellTitleHeight  = 20;

@interface MCIMChatContactCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UIButton    *delBtn;

@property (nonatomic, strong) UIImageView *headTagImageView;

@end


@implementation MCIMChatContactCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.deleteState = MCDeleteBtnStateNormal;
        
        CGFloat width = frame.size.width-2*xCellPaddingLeft;
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xCellPaddingLeft, xCellPaddingTop, width, width)];
        [_headImageView cornerRadius];
        [self addSubview:_headImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xCellPaddingLeft/2,CGRectGetMaxY(_headImageView.frame)+xCellPaddingTop, frame.size.width-xCellPaddingLeft, xCellTitleHeight)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [self addSubview: _titleLabel];
        
        _headTagImageView = [[UIImageView alloc] initWithFrame: CGRectMake(CGRectGetMaxX(_headImageView.frame)-20, 2, 40, 16)];
        [self addSubview:_headTagImageView];
        
    }
    return self;
}

-(void)setModel:(MCIMChatContactCellModel *)model
{
    _model = model ;
    
    _titleLabel.text = model.name;
    
    if (model.state == MCModelStateAdd) {
        _headImageView.backgroundColor = [UIColor clearColor];
        _headImageView.image = AppStatus.theme.chatStyle.chatInfoContactAddImage;
        self.delBtn.hidden = YES;
    }else if (model.state == MCModelStateDel){
        _headImageView.backgroundColor = [UIColor clearColor];
        _headImageView.image = AppStatus.theme.chatStyle.chatInfoContactdelImage;
        self.delBtn.hidden = YES;
    }else{
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:model.headerUrl] placeholderImage:model.headerDefaule options:SDWebImageAllowInvalidSSLCertificates];
    }
    
    switch (model.type) {
        case MCModelStateOwner:
            _headTagImageView .hidden = NO;
            _headTagImageView.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame)-10, 3, 15, 15);
            _headTagImageView .image =[UIImage imageNamed:@"MCIMGroup_owner.png"];
            break;
        case MCModelStateMember:
            _headTagImageView .hidden = YES;
            break;
        case MCModelStateNotJion:
            _headTagImageView .hidden = NO;
            _headTagImageView.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame)-20, 2, 40, 16);
            _headTagImageView .image =[UIImage imageNamed:@"MCIMGroup_NoJion.png"];
            break;
        default:
            break;
    }
    
}

-(void)setDeleteState:(MCDeleteState)deleteState
{
    _deleteState = deleteState;
    if (_deleteState == MCDeleteBtnStateNormal) {
        self.delBtn.hidden = YES;
    }else if (_deleteState == MCDeleteBtnStateEditing){
        self.delBtn.hidden = YES;
    }else{
        
    }
}
-(void)resetTitleName:(NSString *)name
{
    self.titleLabel.text = name;
}


-(void)delectActions:(UIButton *)sender
{
//    if (self.delegate &&[self.delegate respondsToSelector:@selector(deleteCurrentItem:)]) {
//        [self.delegate deleteCurrentItem:self];
//    }
}

#define angleToRadion(angle) (angle / 180.0 * M_PI)
-(void)StartShakeAnimations
{
    CAKeyframeAnimation *ani = [CAKeyframeAnimation animation];
    ani.keyPath = @"transform.rotation";
    ani.values = @[@(angleToRadion(-6)),@(angleToRadion(6)),@(angleToRadion(-6))];
    ani.repeatCount = MAXFLOAT;
    ani.duration = 0.2f;
    [self.layer addAnimation:ani forKey:@"mcshake"];
}

-(void)StopShakeAnimations
{
    [self.layer removeAnimationForKey:@"mcshake"];
}




@end
