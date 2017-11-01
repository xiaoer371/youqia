//
//  MCChatViewCell.m
//  NPushMail
//
//  Created by swhl on 16/2/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCChatViewCell.h"
#import "UIResponder+Router.h"
#import "FBKVOController.h"
#import "UIImageView+MCCorner.h"

NSString *const kResendButtonTapEventName = @"kResendButtonTapEventName";
NSString *const kShouldResendCell = @"kShouldResendCell";

@interface MCChatViewCell ()<MCIMChatBubbleDelegate>

@end

@implementation MCChatViewCell


- (id)initWithMessageModel:(MCIMMessageModel *)model reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithMessageModel:model reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.headImageView cornerRadiusWithMask];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorWithHexString:@"eeeff2"];
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.KVOController unobserveAll];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.messageModel.type == IMMessageTypeText) {
        return;
    }
    CGRect bubbleFrame = _bubbleView.frame;
    bubbleFrame.origin.y = self.headImageView.frame.origin.y + 20;
    
    if (self.messageModel.isSender) {
        
        if (self.messageModel.type == IMMessageTypeVoice) {
            bubbleFrame.origin.y = self.headImageView.frame.origin.y + 5;
        }else{
            bubbleFrame.origin.y = self.headImageView.frame.origin.y + 2;
        }
        
        bubbleFrame.origin.x = ScreenWidth - HEAD_SIZE - HEAD_PADDING * 2 - bubbleFrame.size.width;
        _bubbleView.frame = bubbleFrame;
        
        CGRect frame = self.activityView.frame;
        frame.origin.x = bubbleFrame.origin.x - frame.size.width - ACTIVTIYVIEW_BUBBLE_PADDING;
        frame.origin.y = _bubbleView.center.y - frame.size.height / 2;
        self.activityView.frame = frame;
        
    }
    else{
        bubbleFrame.origin.x = HEAD_PADDING * 2 + HEAD_SIZE;
        _bubbleView.frame = bubbleFrame;
    }
}

- (void)reSetFrameAutoSuperView
{
    CGRect bubbleFrame = _bubbleView.frame;
    bubbleFrame.origin.y = self.headImageView.frame.origin.y + 20;
    
    if (self.messageModel.isSender) {
        
        if (self.messageModel.type == IMMessageTypeVoice) {
            bubbleFrame.origin.y = self.messageModel.isShowTime?30:10;     //self.headImageView.frame.origin.y + 5;
        }else{
            bubbleFrame.origin.y = self.messageModel.isShowTime?27:7;   //self.headImageView.frame.origin.y + 2;
        }
        
        bubbleFrame.origin.x = ScreenWidth - HEAD_SIZE - HEAD_PADDING * 2 - bubbleFrame.size.width;
        _bubbleView.frame = bubbleFrame;
        
        CGRect frame = self.activityView.frame;
        frame.origin.x = bubbleFrame.origin.x - frame.size.width - ACTIVTIYVIEW_BUBBLE_PADDING;
        frame.origin.y = _bubbleView.center.y - frame.size.height / 2;
        self.activityView.frame = frame;
        
    }
    else{
        bubbleFrame.origin.x = HEAD_PADDING * 2 + HEAD_SIZE;
        
        _bubbleView.frame = bubbleFrame;
    }
}

- (void)setMessageModel:(MCIMMessageModel *)model
{
    [self.KVOController unobserveAll];
    
    [super setMessageModel:model];

    _bubbleView.model = model;
    
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:model keyPath:@"state" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        
        // 菊花状态 （因不确定菊花具体位置，要在子类中实现位置的修改）
        switch (weakSelf.messageModel.state) {
            case IMMessageStateSending:
            {
                [weakSelf.activityView setHidden:NO];
                [weakSelf.retryButton setHidden:YES];
                [weakSelf.activtiy setHidden:NO];
                [weakSelf.activtiy startAnimating];
            }
                break;
            case IMMessageStateSuccess:
            {
                [weakSelf.activtiy stopAnimating];
                [weakSelf.activityView setHidden:YES];
                
            }
                break;
            case IMMessageStateFailure:
            {
                [weakSelf.activityView setHidden:NO];
                [weakSelf.activtiy stopAnimating];
                [weakSelf.activtiy setHidden:YES];
                [weakSelf.retryButton setHidden:NO];
            }
                break;
            default:
                break;
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - action

// 重发按钮事件
-(void)retryButtonPressed:(UIButton *)sender
{
    [self routerEventWithName:kResendButtonTapEventName
                     userInfo:@{KMESSAGEKEY:self.messageModel,kShouldResendCell:self}];
}

#pragma mark - private

- (void)setupSubviewsForMessageModel:(MCIMMessageModel *)messageModel
{
    [super setupSubviewsForMessageModel:messageModel];
    
    if (messageModel.isSender) {
        // 发送进度显示view
        _activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE)];
        [_activityView setHidden:YES];
        [self.contentView addSubview:_activityView];
        
        // 重发按钮
        _retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _retryButton.frame = CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE);
        [_retryButton addTarget:self action:@selector(retryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_retryButton setBackgroundImage:[UIImage imageNamed:@"messageSendFail.png"] forState:UIControlStateNormal];
        [_activityView addSubview:_retryButton];
        
        // 菊花
        _activtiy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activtiy.backgroundColor = [UIColor clearColor];
        [_activityView addSubview:_activtiy];
    }
    
    _bubbleView = [self bubbleViewForMessageModel:messageModel];
    [self.contentView addSubview:_bubbleView];
}

- (MCIMChatBaseBubbleView *)bubbleViewForMessageModel:(MCIMMessageModel *)messageModel
{
    switch (messageModel.type) {
            
        case IMMessageTypeText:
        {
           MCIMChatTextBubbleView *bubbleView =[[MCIMChatTextBubbleView alloc] init];
            bubbleView.delegate = self;
            return bubbleView;
        }
            break;
        case IMMessageTypeImage:
        {
            MCIMChatImageBubbleView *bubbleView = [[MCIMChatImageBubbleView alloc] init];
            bubbleView.delegate = self;
            return bubbleView;
        }
            break;
        case IMMessageTypeVoice:
        {
            MCIMChatVoiceBubbleView *bubbleView = [[MCIMChatVoiceBubbleView alloc] init];
            bubbleView.delegate = self;
            return bubbleView;
        }
            break;
        case IMMessageTypeFile:
        {
            MCIMChatFileBubbleView *bubbleView =[[MCIMChatFileBubbleView alloc] init];
            bubbleView.delegate = self;
            return bubbleView;
        }
            break;
        default:
            break;
    }
    
    return nil;
}

+ (CGFloat)bubbleViewHeightForMessageModel:(MCIMMessageModel *)messageModel
{
    switch (messageModel.type) {
        case IMMessageTypeText:
        {
            return [MCIMChatTextBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case IMMessageTypeImage:
        {
            return [MCIMChatImageBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case IMMessageTypeVoice:
        {
            return [MCIMChatVoiceBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case IMMessageTypeFile:
        {
            return [MCIMChatFileBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        default:
            break;
    }
    
    return HEAD_SIZE;
}

#pragma mark - public

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(MCIMMessageModel *)model isShowTime:(BOOL)isShowTime
{
    NSInteger bubbleHeight = [self bubbleViewHeightForMessageModel:model];
    CGFloat offfsetY = isShowTime? 20 : 0;
    DDLogVerbose(@"height======%f",bubbleHeight+ CELLPADDING +offfsetY);
    return  bubbleHeight + offfsetY + 5;
}

@end
