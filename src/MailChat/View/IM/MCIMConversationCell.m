//
//  MCIMConversationCell.m
//  NPushMail
//
//  Created by swhl on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMConversationCell.h"
#import "CustomBadge.h"
#import "NSDate+Category.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MCContactManager.h"
#import "UIImageView+MCCorner.h"
#import "FBKVOController.h"
#import "MCIMConversationManager.h"
#import "MCIMMessageManager.h"


@interface MCIMConversationCell ()<RTDraggableBadgeDelegate>

@property (weak, nonatomic) IBOutlet UILabel *forWardUser;  //转发的对象
@property (weak, nonatomic) IBOutlet UILabel *time; //最后聊天时间
@property (weak, nonatomic) IBOutlet UILabel *content;  //聊天的内容
@property (weak, nonatomic) IBOutlet UILabel *user;    //聊天对象  名称
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;  //聊天对象 头像
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property(nonatomic, strong) UIImageView *msgNoPushFlagImgView;

@end


@implementation MCIMConversationCell


+ (NSString *)reuseIdentifier
{
    return @"MCIMConversationCell";
}

+ (UINib *)cellNib
{
    return [UINib nibWithNibName:@"MCIMConversationCell" bundle:nil];
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    // Initialization code
    self.user.textColor = AppStatus.theme.titleTextColor;    //"333333"
    self.content.textColor = AppStatus.theme.fontTintColor;  //777777
    self.time.textColor = AppStatus.theme.fontTintColor;     //"777777
    //切圆
    [self.headImgView cornerRadiusWithMask];
    
    CGPoint point = CGPointMake(CGRectGetMinX(self.time.frame),CGRectGetMaxY(self.time.frame)+5);
    _badge =[[RTDraggableBadge alloc] initWithFrame:CGRectMake(ScreenWidth-25-13, point.y, 27, 20)];
    _badge.delegate = self;
    [self.contentView addSubview:_badge];
    
    
    CGFloat originY= CGRectGetMidY(self.contentView.frame)+3;// + CGRectGetWidth(self.time.frame);
    _msgNoPushFlagImgView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 31, originY, 12, 13)];
    _msgNoPushFlagImgView.backgroundColor =[UIColor clearColor];
    _msgNoPushFlagImgView.image = [UIImage imageNamed:@"mc_noMessageFlag.png"];
    [self.contentView addSubview:_msgNoPushFlagImgView];
    _msgNoPushFlagImgView.hidden = YES;
    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.KVOController unobserveAll];
}

-(void)setConversationModel:(MCIMConversationModel *)conversationModel
{
    [self.KVOController unobserveAll];
    
    _conversationModel = conversationModel;
    if (conversationModel.onTopTime > 0) {
        self.bgView.backgroundColor = AppStatus.theme.toolBarBackgroundColor;
    }else{
        self.bgView.backgroundColor = [UIColor whiteColor];
    }
    
    if (conversationModel.type == MailChatConversationTypeEvent
        || conversationModel.type == MailChatConversationTypeEventlive ||conversationModel.type ==MailChatConversationTypeFeiba) {
        self.time.hidden = YES;
    }else{self.time.hidden = NO;}
    
    self.forWardUser.frame = CGRectZero;
    self.forWardUser.text = @"";
    self.time.text = [conversationModel.lastMsgTime minuteDescription];
    self.user.text =(conversationModel.peer.peerName?:conversationModel.peerId);
    NSString *content = conversationModel.content;
    if (conversationModel.type == MailChatConversationTypeGroup) {
        if (!conversationModel.lastMessage) {
            conversationModel.lastMessage = [[MCIMMessageManager new] getLastMessageModelWithConversationId:conversationModel.uid];
        }
        if (conversationModel.lastMessage.from && conversationModel.lastMessage.type !=IMMessageTypeNotice && (![conversationModel.lastMessage.from  isEqualToString:AppStatus.currentUser.email])) {
            DDLogVerbose(@"name====%@",conversationModel.lastMessage.contactModel.displayName);
            MCContactModel *contactModel =[[MCContactManager sharedInstance ]getOrCreateContactWithEmail:conversationModel.lastMessage.from name:conversationModel.lastMessage.from];
            content = [NSString stringWithFormat:@"%@:%@",contactModel.displayName,conversationModel.content];
        }
    }
    if (conversationModel.isShield) {
         _badge.hidden = YES;
        _msgNoPushFlagImgView.hidden = NO;
        if (conversationModel.unreadCount > 0) {
            NSString *unreadString = conversationModel.unreadCount > 99 ? @"99+" : [NSString stringWithFormat:@"%ld",(long)conversationModel.unreadCount];
            content =[NSString stringWithFormat:@"(%@%@) %@",unreadString,PMLocalizedStringWithKey(@"PM_IMChat_UnreadNumber"),content];
        }
    }else{
        _msgNoPushFlagImgView.hidden = YES;
        _badge.hidden = NO;
        NSString *unreadString = conversationModel.unreadCount > 99 ? @"99+" : [NSString stringWithFormat:@"%ld",(long)conversationModel.unreadCount];
        _badge.text = unreadString;
    }
    self.content.text = conversationModel.draft.length>0? [NSString stringWithFormat:@"%@%@",PMLocalizedStringWithKey(@"PM_IMChat_draftsContent"),conversationModel.draft]:content;
    
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:conversationModel.peer.avatarUrl] placeholderImage:[conversationModel.peer avatarPlaceHolder] options:SDWebImageAllowInvalidSSLCertificates];

    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:conversationModel.peer keyPath:@"peerName" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        weakSelf.user.text = conversationModel.peer.peerName ?: conversationModel.peerId;
    }];
    
    [self.KVOController observe:conversationModel.peer keyPath:@"avatarUrl" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        [weakSelf.headImgView sd_setImageWithURL:[NSURL URLWithString:conversationModel.peer.avatarUrl] placeholderImage:[conversationModel.peer avatarPlaceHolder] options:SDWebImageAllowInvalidSSLCertificates];
    }];
    
    [self.KVOController observe:conversationModel keyPath:@"isShield" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        _msgNoPushFlagImgView.hidden = !conversationModel.isShield;
    }];
    
    [self.KVOController observe:conversationModel keyPath:@"draft" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        [weakSelf reSetConversationContent:conversationModel];
    }];
    
    [self.KVOController observe:conversationModel keyPath:@"content" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        if ([conversationModel.content isEqualToString:@""] /*清空聊天记录*/) {
            weakSelf.content.text = conversationModel.content;
        }else{
        }
    }];
    
    [self.KVOController observe:conversationModel keyPath:@"onTopTime" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        _bgView.backgroundColor = conversationModel.onTopTime>0?AppStatus.theme.toolBarBackgroundColor:[UIColor whiteColor];
    }];
    
}

- (void)reSetConversationContent:(MCIMConversationModel *)conversationModel
{
    NSString *content = conversationModel.content;
    if (conversationModel.type == MailChatConversationTypeGroup) {
        if (conversationModel.lastMessage.from && conversationModel.lastMessage.type !=IMMessageTypeNotice && (![conversationModel.lastMessage.from  isEqualToString:AppStatus.currentUser.email])) {
            MCContactModel *contactModel =[[MCContactManager sharedInstance ]getOrCreateContactWithEmail:conversationModel.lastMessage.from name:conversationModel.lastMessage.from];
            content = [NSString stringWithFormat:@"%@:%@",contactModel.displayName,conversationModel.content];
        }
    }
    self.content.text = conversationModel.draft.length>0? [NSString stringWithFormat:@"%@%@",PMLocalizedStringWithKey(@"PM_IMChat_draftsContent"),conversationModel.draft]:content;
}

- (void)subViewWithConversation:(MCIMConversationModel*)conversationModel
{
    self.time.frame =CGRectZero;
    self.content.frame = CGRectZero;
    self.user.frame = CGRectZero;
    self.time.text = @"";
    self.content.text = @"";
    self.user.text = @"";
    self.time = nil;
    self.content = nil;
    self.user = nil;
     _badge.hidden = YES;
    _conversationModel = conversationModel;
    
    self.forWardUser.text = conversationModel.peer.peerName?:conversationModel.peerId;
    UIImage *image = [conversationModel.peer avatarPlaceHolder];
    if (!image) {
        MCContactModel *contactModel = [[MCContactManager sharedInstance] getOrCreateContactWithEmail:conversationModel.peerId name:conversationModel.peerId];
        image =contactModel.avatarPlaceHolder;
    }
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:conversationModel.peer.avatarUrl] placeholderImage:image options:SDWebImageAllowInvalidSSLCertificates];
}

#pragma mark - RTDraggableBadgeDelegate

- (void)dragOut:(id)sender
{
    
    if (self.dragBadgeOutViewBlock) {
        self.dragBadgeOutViewBlock(self.conversationModel);
    }
    
    self.conversationModel.unreadCount = 0;
    [[MCIMConversationManager shared] updateConversation:self.conversationModel];
}

- (void)doubleClick:(id)sendr
{
    if (self.dragBadgeOutViewBlock) {
        self.dragBadgeOutViewBlock(self.conversationModel);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
