//
//  MCIMChatBaseCell.m
//  NPushMail
//
//  Created by swhl on 16/2/23.
//  Copyright © 2016年 sprite. All rights reserved.
//
#define STRETCH_IMAGE(image, edgeInsets) [image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch]

#import "MCIMChatBaseCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSDate+Category.h"
#import "UIImageView+MCCorner.h"
#import "FBKVOController.h"

NSString *const kRouterEventChatHeadImageTapEventName = @"kRouterEventChatHeadImageTapEventName";

//static const CGFloat MCTimePadingTop = 10.0f;
static const CGFloat MCTimeHeight = 15.0f;
static const CGFloat MCTimePadingBom = 5.0f;
static const CGFloat MCTimeLabelFont = 12.0f;


@implementation MCIMChatBaseCell{
    
}

- (id)initWithMessageModel:(MCIMMessageModel *)model reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor colorWithHexString:@"cccccc"];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:MCTimeLabelFont];
        _timeLabel.layer.cornerRadius = 3.0f;
        _timeLabel.clipsToBounds = YES;
        [self.contentView addSubview:_timeLabel];
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImagePressed:)];
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(HEAD_PADDING, CELLPADDING, HEAD_SIZE, HEAD_SIZE)];
        [_headImageView addGestureRecognizer:tap];
        _headImageView.userInteractionEnabled = YES;
        _headImageView.multipleTouchEnabled = YES;
        [self.contentView addSubview:_headImageView];
        
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor colorWithHexString:@"808080"];
        _nameLabel.textAlignment = model.isSender? NSTextAlignmentRight:NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:NAME_LABEL_FONT_SIZE];
        [self.contentView addSubview:_nameLabel];
        
        [self setupSubviewsForMessageModel:model];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat offsetY =0;
    if (self.showTime) {
        NSString *timeStr =[self.messageModel.time minuteDescription];
        CGSize size = [timeStr boundingRectWithSize:CGSizeMake(220, MCTimeHeight) options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{
                                                      NSFontAttributeName:[UIFont systemFontOfSize:MCTimeLabelFont]
                                                      }
                                            context:nil].size;
        
        _timeLabel.frame = CGRectMake((ScreenWidth-size.width-10)/2, MCTimePadingBom, size.width+10, MCTimeHeight);
        
        offsetY= MCTimePadingBom + MCTimeHeight;
        
    }else{
        _timeLabel.text = @"";
        _timeLabel.frame = CGRectZero;
        offsetY= 0;
    }
    
    if (self.messageModel.isSender) {
        self.headImageView.frame = CGRectMake(
                                              self.bounds.size.width - _headImageView.frame.size.width - HEAD_PADDING,CELLPADDING+offsetY,
                                              HEAD_SIZE,
                                              HEAD_SIZE
                                              );
    }
    else{
        self.headImageView.frame = CGRectMake(HEAD_PADDING, CELLPADDING+offsetY, HEAD_SIZE, HEAD_SIZE);
    }
    [_headImageView cornerRadiusWithMask];
    
    _nameLabel.frame =_messageModel.isSender? CGRectZero:
    CGRectMake(
               CGRectGetMidX(_headImageView.frame)+_headImageView.frame.size.width,
               _headImageView.frame.origin.y-3, 190,
               NAME_LABEL_HEIGHT
               );
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - setter

- (void)setMessageModel:(MCIMMessageModel *)messageModel
{
    [self.KVOController unobserveAll];
    _messageModel = messageModel;
    self.timeLabel.text = [self.messageModel.time minuteDescription];
    self.nameLabel.text = messageModel.contactModel.displayName;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.contactModel.headImageUrl] placeholderImage:messageModel.contactModel.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
    
    
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:messageModel.contactModel keyPath:@"displayName" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        weakSelf.nameLabel.text = messageModel.contactModel.displayName;
    }];
    
    [self.KVOController observe:messageModel.contactModel keyPath:@"headImageUrl" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        
        [weakSelf.headImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.contactModel.headImageUrl] placeholderImage:messageModel.contactModel.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
        
    }];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.KVOController unobserveAll];
}

#pragma mark - private

-(void)headImagePressed:(id)sender
{
    [super routerEventWithName:kRouterEventChatHeadImageTapEventName userInfo:@{KMESSAGEKEY:self.messageModel}];
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    [super routerEventWithName:eventName userInfo:userInfo];
}

#pragma mark - public

- (void)setupSubviewsForMessageModel:(MCIMMessageModel *)model
{

}

+ (NSString *)cellIdentifierForMessageModel:(MCIMMessageModel *)model
{
    NSString *identifier = @"MessageCell";
    if (model.isSender) {
        identifier = [identifier stringByAppendingString:@"Sender"];
    }
    else{
        identifier = [identifier stringByAppendingString:@"Receiver"];
    }
    switch (model.type) {
        case IMMessageTypeText:
        {
            identifier = [identifier stringByAppendingString:@"Text"];
        }
            break;
        case IMMessageTypeImage:
        {
            identifier = [identifier stringByAppendingString:@"Image"];
        }
            break;
        case IMMessageTypeVoice:
        {
            identifier = [identifier stringByAppendingString:@"Audio"];
        }
            break;
        case IMMessageTypeFile:
        {
            identifier = [identifier stringByAppendingString:@"File"];
        }
            break;
        default:
            break;
    }
    
    return identifier;
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(MCIMMessageModel *)model isShowTime:(BOOL)isShowTime 
{
    CGFloat timeH = MCTimeHeight+MCTimePadingBom;
    CGFloat offsetY = isShowTime?timeH:0;
    return HEAD_SIZE + CELLPADDING + offsetY;
}

@end
