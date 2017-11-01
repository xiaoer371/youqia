//
//  MCVIPMailListCell.m
//  NPushMail
//
//  Created by zhang on 16/8/25.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCVIPMailListCell.h"
#import "NSArray+MCO.h"
#import "NSString+MCO.h"
#import "UIImageView+MCCorner.h"
#import "MCMailManager.h"
#import "NSDate+Category.h"
#import "FBKVOController.h"
#import "NSString+Extension.h"
#import "MCMailAttachListCell.h"
#import "MCAvatarHelper.h"
#import "MCContactManager.h"
#import "UIImageView+WebCache.h"
#import "MCAppSetting.h"

#import "UIAlertView+Blocks.h"

@interface MCVIPMailListCell()

@property (nonatomic,strong)UIFont *normalFont;
@property (nonatomic,strong)UIFont *hightlightFont;
@property (nonatomic,assign)CGFloat unreadLeftConstrain;
@property (nonatomic,assign)CGFloat fromAdLeftConstrain;
@property (nonatomic,assign)CGFloat attachRightConstrain;

@property (nonatomic,strong)UIButton *errorButton;

@end

static NSString*const kMCVipMailImage =@"mc_mailList_vipTag.png";
static NSString*const kMCBacklogImage = @"mc_backlogMailTag";
static CGFloat  const kMCStarMailContentRightConstraint = 30.0;
static CGFloat  const kMCUnStarMailContentRightConstraint = 10.0;
static CGFloat  const kMCHaveAvatarMailLeftConstraint = 9.0;
static CGFloat  const kMCUnAvatarMailLeftConstraint = 15.0;
@implementation MCVIPMailListCell

+ (UINib *)mailCellNib
{
    return [UINib nibWithNibName:@"MCVIPMailListCell" bundle:nil];
}

+ (UINib *)avatarMailCellNib
{
    return [UINib nibWithNibName:@"MCVIPAvatarMailListCell" bundle:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _isSelected = NO;
    CGRect indicatorFrame = CGRectMake(- 24, fabs(self.frame.size.height - 24)/ 2, 24, 24);
    _mSelectedIndicator = [[UIImageView alloc] initWithFrame:indicatorFrame];
    _mSelectedIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:_mSelectedIndicator];
    [_avatarImageView cornerRadiusWithMask];
    
    _fromAdLabel.textColor = AppStatus.theme.titleTextColor;
    _subjectLabel.textColor = AppStatus.theme.titleTextColor;
    _timeLabel.textColor = AppStatus.theme.fontTintColor;
    _contentLabel.textColor = AppStatus.theme.fontTintColor;
    _normalFont = [UIFont systemFontOfSize:17.0];
    _hightlightFont = [UIFont boldSystemFontOfSize:17.0];
    _unreadLeftConstrain = _unreadLabelLeftConstraint.constant;
    _fromAdLeftConstrain = 20;
    _vipImageLeftConstraint.constant = (_fromAdLeftConstrain - 13)/2;
    _attachRightConstrain = _attachLabelRightConstraint.constant;
    self.avatarImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    
    [self.avatarImageView addGestureRecognizer:tap];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    if (_isSelected){
        
        if (((UITableView *)self.superview).isEditing){
            self.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
        } else {
            self.backgroundView.backgroundColor = [UIColor clearColor];
        }
        self.textLabel.textColor = [UIColor darkTextColor];
        [_mSelectedIndicator setImage:AppStatus.theme.selectStateImage];
        
    } else {
        
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor grayColor];
        [_mSelectedIndicator setImage:AppStatus.theme.unselectStateImage];
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    [UIView commitAnimations];
    //reset Constrain
    CGSize textSize = [[_model.receivedDate minuteDescription] mcStringSizeWithFont:12];
    _timeLabelWidthConstraint.constant = textSize.width + 2;
    if (_model.hasAttachment) {
        _attachLabelRightConstraint.constant = _attachRightConstrain;
    } else {
        _attachLabelRightConstraint.constant = _attachRightConstrain - 13;
    }
    if (!_model.isRead) {
        _unreadLabelLeftConstraint.constant = self.loadAvatar?kMCHaveAvatarMailLeftConstraint:kMCUnAvatarMailLeftConstraint;
    } else {
        _unreadLabelLeftConstraint.constant = self.loadAvatar?-_vipImageLeftConstraint.constant:6 - _vipImageLeftConstraint.constant;
    }
    _fromAdLabelLeftConstraint.constant = (_model.tags&MCMailTagImportant||_model.tags&MCMailTagBacklog)? _fromAdLeftConstrain:_fromAdLeftConstrain - _vipImageLeftConstraint.constant - 13;
    _contentRightConstraint.constant = _model.isStar?kMCStarMailContentRightConstraint:kMCUnStarMailContentRightConstraint;
    
    //设置待发送单元格样式
    CGFloat leftContentDefaultContaint = 59;
    CGFloat leftContentDefaultWithoutAvatarContaint = 15;
    if (self.mailBox.type == MCMailFolderTypePending) {
        _failSentImageView.hidden = NO;
        _leftContentConstraint.constant = self.loadAvatar?(leftContentDefaultContaint +20):(leftContentDefaultWithoutAvatarContaint+20);
        
        CGSize textSize = [self.contentLabel.text mcStringSizeWithFont:14];
        [self resetErrorButtonFrameWithPoint:CGPointMake(_leftContentConstraint.constant + textSize.width + 10, CGRectGetMinY(self.contentLabel.frame))];
    } else {
        _failSentImageView.hidden = YES;
        _leftContentConstraint.constant = self.loadAvatar?leftContentDefaultContaint:leftContentDefaultWithoutAvatarContaint;
        if (_errorButton) {
            [_errorButton removeFromSuperview];
            _errorButton = nil;
        }
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.KVOController unobserveAll];
    _subjectLabel.text = @"";
    _timeLabel.text = @"";
    _contentLabel.text = @"";
    _fromAdLabel.text = @"";
}

- (void)setModel:(MCMailModel *)model {
    
    [self removeObserver];
    _model = model;
    _isSelected = model.isSelected;
    if (!model.subject||[model.subject trim].length == 0) {
        model.subject = PMLocalizedStringWithKey(@"PM_Mail_NoneSubject");
    }
    self.subjectLabel.text = model.subject;
    self.attachImageView.hidden = !model.hasAttachment;
    self.starImageView.alpha = model.isStar?1:0;
    self.unreadImageView.alpha = model.isRead?0:1;
    self.vipImageView.alpha = model.tags&MCMailTagImportant?1:0;
    if (model.tags == MCMailTagNone) {
        self.vipImageView.alpha = 0;
    } else {
        self.vipImageView.alpha = 1;
        if (model.tags & MCMailTagBacklog) {
            self.vipImageView.image = [UIImage imageNamed:kMCBacklogImage];
        } else {
            self.vipImageView.image = [UIImage imageNamed:kMCVipMailImage];
        }
    }
    self.replyImageView.alpha = model.isAnswer?1:0;
    self.timeLabel.text = [model.receivedDate minuteDescription];
    self.fromAdLabel.font = model.isRead?_normalFont:_hightlightFont;
    
    if (self.mailBox.type == MCMailFolderTypeSent ||
        self.mailBox.type == MCMailFolderTypeDrafts ||
        self.mailBox.type == MCMailFolderTypePending) {
        
        if (model.to || model.cc) {
            [self setToContact];
        } else {
            self.avatarImageView.image = nil;
            self.fromAdLabel.text = PMLocalizedStringWithKey(@"PM_Mail_NoneToAddress");
        }
        
    } else {
        
        if (model.from.email) {
            [self setFromeContact];
        } else {
            self.avatarImageView.image = nil;
        }
    }
    
    if (model.messageContentString){
        [self mailContent];
    }
    [self registeredObserver];
    [self setNeedsLayout];
    
}


//设置头像昵称
- (void)setToContact {
    
    NSMutableArray *contacts = [NSMutableArray new];
    NSMutableArray *names = [NSMutableArray new];
    NSMutableArray *addresses = [NSMutableArray new];
    if (_model.to) {
        [addresses addObjectsFromArray:_model.to];
    }
    if (_model.cc) {
        [addresses addObjectsFromArray:_model.cc];
    }
    for (int i = 0; i < addresses.count; i ++) {
        MCMailAddress* mailAddress = addresses[i];
        if (![mailAddress.email isEmail]) {
            [names addObject:mailAddress.name];
            continue;
        }
        MCContactModel *contactModel = [[MCContactManager sharedInstance] getOrCreateContactWithEmail:mailAddress.email name:mailAddress.name];
        [contacts addObject:contactModel];
        
        if (contactModel.displayName) {
            mailAddress.name = contactModel.displayName;
            [names addObject:contactModel.displayName];
        }
        
        if (i > 4) {
            break;
        }
    }
    MCContactModel *model = [contacts firstObject];
    [self resetContactWith:model displayText:[names componentsJoinedByString:@","]];
}

- (void)setFromeContact{
    MCContactModel *contactModel;
    if (_model.fromUser) {
        contactModel = _model.fromUser;
    } else {
        contactModel = [[MCContactManager sharedInstance] getOrCreateContactWithEmail:_model.from.email name:_model.from.name];
        _model.fromUser = contactModel;
    }
    [self resetContactWith:contactModel displayText:contactModel.displayName];
}
- (void)resetContactWith:(MCContactModel *)model displayText:(NSString *)displayText {
    
    if (!model) {
        self.fromAdLabel.text = PMLocalizedStringWithKey(@"PM_Mail_NoneToAddress");
        self.avatarImageView.image = nil;
    } else {
        self.fromAdLabel.text = displayText;
        __weak typeof(self) weakSelf = self;
        [self.KVOController observe:model keyPath:@"headImageUrl" options:  NSKeyValueObservingOptionInitial |NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.avatarUrl] placeholderImage:model.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
            });
        }];
    }
}

//加载邮件内容
- (void)mailContent{
    
    if (self.mailBox.type == MCMailFolderTypePending) {
        _contentLabel.text = PMLocalizedStringWithKey(@"PM_Mail_MailSendFail");
    } else {
        NSString *content = _model.messageContentString;
        if (content.length > 100) {
            NSString *subContent = [content substringToIndex:100];
            _contentLabel.text = subContent;
        } else {
            _contentLabel.text = content;
        }
    }
}

//obser
- (void)registeredObserver {
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:_model keyPath:@"isRead" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setNeedsLayout];
            weakSelf.unreadImageView.alpha = weakSelf.model.isRead ? 0 : 1;
            weakSelf.fromAdLabel.font = weakSelf.model.isRead?weakSelf.normalFont:weakSelf.hightlightFont;
            [weakSelf refreshButtons:YES];
        });
    }];
    
    [self.KVOController observe:_model keyPath:@"isStar" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setNeedsLayout];
            BOOL isStar = [change[NSKeyValueChangeNewKey] boolValue];
            weakSelf.starImageView.alpha = isStar ? 1 : 0;
            [weakSelf refreshButtons:YES];
        });
    }];
    
    [self.KVOController observe:_model keyPath:@"messageContentString" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf mailContent];
        });
    }];
    
    [self.KVOController observe:_model keyPath:@"tags" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setNeedsLayout];
            if (weakSelf.model.tags == MCMailTagNone) {
                weakSelf.vipImageView.alpha = 0;
            } else {
                self.vipImageView.alpha = 1;
                if (weakSelf.model.tags & MCMailTagBacklog) {
                    weakSelf.vipImageView.image = [UIImage imageNamed:kMCBacklogImage];
                } else {
                    weakSelf.vipImageView.image = [UIImage imageNamed:kMCVipMailImage];
                }
            }
            [weakSelf refreshButtons:YES];
        });
    }];
    
    [self.KVOController observe:_model keyPath:@"isAnswer" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setNeedsLayout];
            weakSelf.replyImageView.alpha = _model.isAnswer?1:0;
        });
    }];
}
- (void)removeObserver {
    
    [self.KVOController unobserveAll];
}

//select
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (void)changeMSelectedState
{
    _isSelected = !_isSelected;
    [self setNeedsLayout];
}
//Tap avatar

- (void)tap:(UIGestureRecognizer*)gesture
{
    if ([self.cellDelegate respondsToSelector:@selector(tapAvatar:contact:)]) {
        [self.cellDelegate tapAvatar:self contact:self.model.fromUser];
        [MCUmengManager addEventWithKey:mc_mail_to_contact];
    }
}

- (void)errorNoteTap {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:self.model.messageContentString delegate:nil cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Sure") otherButtonTitles:nil];
    [alert show];
}

- (UIButton*)errorButton {
    
    if (!_errorButton) {
        _errorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _errorButton.backgroundColor = [UIColor whiteColor];
        _errorButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _errorButton.frame = CGRectMake(0, 0, 50, CGRectGetHeight(self.contentLabel.frame));
        [_errorButton addTarget:self action:@selector(errorNoteTap) forControlEvents:UIControlEventTouchUpInside];
        [_errorButton setTitle:PMLocalizedStringWithKey(@"PM_Mail_error") forState:UIControlStateNormal];
        [_errorButton setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
        _errorButton.layer.cornerRadius = 5.0f;
        _errorButton.layer.borderWidth = 0.5;
        _errorButton.layer.borderColor = AppStatus.theme.tintColor.CGColor;
        [self addSubview:_errorButton];
    }
    return _errorButton;
}

- (void)resetErrorButtonFrameWithPoint:(CGPoint)point {
    CGRect  rect = self.errorButton.frame;
    rect.origin.x = point.x;
    rect.origin.y = point.y;
    self.errorButton.frame = rect;
}

@end
