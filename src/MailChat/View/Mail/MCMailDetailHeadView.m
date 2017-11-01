//
//  MCMailDetailHeadView.m
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCMailDetailHeadView.h"
#import "NSString+Extension.h"
#import "NSDate+Category.h"
#import "MCMailManager.h"
@implementation  MCMailAddressButton
- (BOOL)canBecomeFirstResponder {return YES;}
@end

@interface MCMailDetailHeadView ()

@property (nonatomic,strong)NSMutableArray *contactArray;
//主题
@property(nonatomic,strong)UILabel *mcSubjectLabel;
//子标题
@property(nonatomic,strong)UILabel *mcSubTitleLable;
@property(nonatomic,strong)UIView  *mcSubTitleView;
@property(nonatomic,strong)UILabel *mcTimeLable;
//发件人
@property(nonatomic,strong)UIView *fromContactView;
//详情
@property(nonatomic,strong)UIButton *mcDetailButton;
//分割线
@property(nonatomic,strong)UIView *separatorLine;
@property(nonatomic,strong)UIButton *starActionButton;

@property(nonatomic,assign)NSInteger defaultTag;
@property(nonatomic,assign)NSInteger didSelectIndex;
@property(nonatomic,assign)CGFloat mailHeadViewShowHeight;
@property(nonatomic,assign)CGFloat mailHeadViewhihedHeight;

@property(nonatomic,assign)BOOL detailContactShow;
@property(nonatomic,assign)BOOL star;
//dataSource
@property(nonatomic,strong)NSMutableArray *from;
@property(nonatomic,strong)NSMutableArray *to;
@property(nonatomic,strong)NSMutableArray *cc;

@property(nonatomic,assign) CGFloat kMCMailDetailHeadViewContactViewMaxWidth;

@end

const static CGFloat kMCMailDetailHeadViewSubjectFont           = 17.0;
const static CGFloat kMCMailDetailHeadViewSubTitleFont          = 14.0;
const static CGFloat kMCMailDetailHeadViewContactButtonHight    = 18.0;
const static CGFloat kMCMailDetailHeadViewContactButtonSpace    = 8.0;
const static CGFloat kMCMailDetailHeadViewMargin                = 12.0;
const static CGFloat kMCMailDetailHeadViewNoteWidth             = 50.0;
const static CGFloat kMCMailDetailHeadViewAttactmentButtonSize  = 32.0;
const static CGFloat kMCMailDetailHeadViewSpace                 = 10.0;
const static CGFloat kMCMailDetailHeaViewDetailButtonWidth      = 40.0;
const static CGFloat kMCMailDetailHeaViewDetailButtonHight      = 25.0;
const static NSInteger kMCMailDetailHeadViewContactViewTag      = 1000;

@implementation MCMailDetailHeadView

- (id)initWithMail:(MCMailModel*)mailModel setDelegate:(id)delegate{
    
    if (self = [super init]) {
        [self setUp];
        _contactArray = [NSMutableArray new];
        _from = [NSMutableArray new];
        _to = [NSMutableArray new];
        _cc = [NSMutableArray new];
        _delegate = delegate;
        _kMCMailDetailHeadViewContactViewMaxWidth = ScreenWidth - kMCMailDetailHeadViewNoteWidth - kMCMailDetailHeadViewMargin - kMCMailDetailHeaViewDetailButtonWidth;
        self.mail = mailModel;
    }
    return  self;
    
}

- (void)setUp{
    
    _mcSubjectLabel = [[UILabel alloc] init];
    _mcSubjectLabel.numberOfLines = 0;
    _mcSubjectLabel.textColor = AppStatus.theme.titleTextColor;
    _mcSubjectLabel.font = [UIFont boldSystemFontOfSize:kMCMailDetailHeadViewSubjectFont];
    [self addSubview:_mcSubjectLabel];
    
    _mcSubTitleView = [[UIView alloc]init];
    _mcSubTitleView.backgroundColor = [UIColor clearColor];
    _mcSubTitleLable = [[UILabel alloc] init];
    _mcSubTitleLable.font = [UIFont systemFontOfSize:kMCMailDetailHeadViewSubTitleFont];
    _mcSubTitleLable.textColor = AppStatus.theme.fontTintColor;
    _mcTimeLable = [[UILabel alloc]init];
    _mcTimeLable.font = _mcSubTitleLable.font;
    _mcTimeLable.textColor = _mcSubTitleLable.textColor;
    [_mcSubTitleView addSubview:_mcSubTitleLable];
    [_mcSubTitleView addSubview:_mcTimeLable];
    [self addSubview:_mcSubTitleView];
    
    _starActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_starActionButton setFrame:CGRectMake(ScreenWidth -34 ,7 , 30, 30)];
    [_starActionButton addTarget:self action:@selector(starMail:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_starActionButton];
    
    _mcDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_mcDetailButton setTitle:PMLocalizedStringWithKey(@"PM_Mail_ShowMoreDetail") forState:UIControlStateNormal];
    _mcDetailButton.titleLabel.font = [UIFont systemFontOfSize:kMCMailDetailHeadViewSubTitleFont];
    [_mcDetailButton setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
    [_mcDetailButton addTarget:self action:@selector(detailButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_mcDetailButton];
    _separatorLine = [[UIView alloc]init];
    _separatorLine.backgroundColor = AppStatus.theme.toolBarSeparatorColor;
    [self addSubview:_separatorLine];
    [self bringSubviewToFront:_separatorLine];
}

- (void)loadViewWithAnimation:(BOOL)animate{
    
    CGFloat hight = _detailContactShow?_mailHeadViewShowHeight:_mailHeadViewhihedHeight;
    [UIView animateWithDuration:animate?0.3:0 animations:^{
        _separatorLine.frame = CGRectMake(0, hight - 1.5, ScreenWidth, 0.5);
        _mcDetailButton.frame = CGRectMake(ScreenWidth - kMCMailDetailHeaViewDetailButtonWidth , hight - kMCMailDetailHeaViewDetailButtonHight - 5, kMCMailDetailHeaViewDetailButtonWidth, kMCMailDetailHeaViewDetailButtonHight);
    }];
}

- (void)setMail:(MCMailModel *)mail {
    _mail = mail;
    //同步本地联系人名称信息
    NSMutableArray *addresses = [NSMutableArray new];
    if (mail.from.email) {
      [addresses addObject:mail.from];
    }
    [addresses addObjectsFromArray:mail.to];
    [addresses addObjectsFromArray:mail.cc];
    [self contactModelsWithMailAddess:addresses];
    
    self.star = mail.isStar;
    _mcSubjectLabel.text = mail.subject;
    //主标题大小调整
    CGSize  actualsize = [_mcSubjectLabel.text mcStringSizeWithBoldFont:kMCMailDetailHeadViewSubjectFont
                                    maxWidth:(ScreenWidth - kMCMailDetailHeadViewMargin - 30) maxHight:MAXFLOAT];
    _mcSubjectLabel.frame = CGRectMake(kMCMailDetailHeadViewMargin ,kMCMailDetailHeadViewMargin, actualsize.width, actualsize.height);
    
    //子标题大小调整
    _mcSubTitleView.frame = CGRectMake(kMCMailDetailHeadViewMargin,kMCMailDetailHeadViewSpace + CGRectGetMaxY(_mcSubjectLabel.frame), ScreenWidth - kMCMailDetailHeaViewDetailButtonWidth - kMCMailDetailHeadViewMargin, 14.0);
    _mcSubTitleLable.text = [self subTitle];
    _mcTimeLable.text = [mail.receivedDate minuteDescription];
    CGSize timeSize = [_mcTimeLable.text mcStringSizeWithFont:kMCMailDetailHeadViewSubTitleFont];
    _mcTimeLable.frame = CGRectMake(_mcSubTitleView.frame.size.width - timeSize.width , 0, timeSize.width, 14.0);
    _mcSubTitleLable.frame = CGRectMake(0, 0, _mcSubTitleView.frame.size.width - _mcTimeLable.frame.size.width - kMCMailDetailHeadViewMargin, 14);
    
    //记录隐藏时的高度
    _mailHeadViewhihedHeight = CGRectGetMaxY(_mcSubTitleView.frame) + 10;
    //发件人
    _fromContactView = [self subViewWith:_mcSubTitleView.frame.origin.y
                                      titele:PMLocalizedStringWithKey(@"PM_Mail_MailFrom")
                                     content:mail.from.email? @[mail.from]:@"(无)"];
    _fromContactView.hidden = YES;
    [self addSubview:_fromContactView];
    
    if (mail.from) {
        [_from addObject:mail.from];
    }
    CGFloat y = CGRectGetMaxY(_fromContactView.frame) + 2*kMCMailDetailHeadViewContactButtonSpace;
    
    //收件人
    if (mail.to) {
        UIView*toView = [self subViewWith:y
                                   titele:PMLocalizedStringWithKey(@"PM_Mail_MailTo")
                                  content:mail.to];
        [self addSubview:toView];
        y = CGRectGetMaxY(toView.frame) + 2*kMCMailDetailHeadViewContactButtonSpace;
        [_to addObjectsFromArray:mail.to];
    }
    
    //抄送人
    if (mail.cc) {
        
        UIView*toView = [self subViewWith:y
                                   titele:PMLocalizedStringWithKey(@"PM_Mail_MailDetailCc")
                                  content:mail.cc];
        [self addSubview:toView];
        y = CGRectGetMaxY(toView.frame) + 2*kMCMailDetailHeadViewContactButtonSpace;
        [_cc addObjectsFromArray:mail.cc];
    }
    
    //时间
    NSDate *date = mail.receivedDate;
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    UIView*timeView = [self subViewWith:y
                                 titele:PMLocalizedStringWithKey(@"PM_Mail_MailTime")
                                content:[dateFormatter stringFromDate:date]];
    [self addSubview:timeView];

    //记录展示高度
    _mailHeadViewShowHeight = CGRectGetMaxY(timeView.frame) + kMCMailDetailHeadViewContactButtonSpace;
    
    self.frame = CGRectMake(0, 0, ScreenWidth,_mailHeadViewhihedHeight);
    [self loadViewWithAnimation:NO];
    if ([_delegate respondsToSelector:@selector(maildetailHeadView:contactDataFrom:to:cc:)]) {
        [_delegate maildetailHeadView:self contactDataFrom:_from to:_to cc:_cc];
    }
}

//构建邮件详情联系人视图
- (UIView*)subViewWith:(CGFloat)hight titele:(NSString*)titleStr  content:(id)content
{
    UIView*contactView = [[UIView alloc]init];
    UIColor *color = AppStatus.theme.fontTintColor;
    UILabel*title = [[UILabel alloc]initWithFrame:CGRectMake(kMCMailDetailHeadViewMargin, 0, kMCMailDetailHeadViewNoteWidth, kMCMailDetailHeadViewContactButtonHight)];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont systemFontOfSize:kMCMailDetailHeadViewSubTitleFont];
    title.textColor = [UIColor greenColor];
    title.text = titleStr;
    title.textColor = color;
    [contactView addSubview:title];
    
    int x = kMCMailDetailHeadViewNoteWidth + kMCMailDetailHeadViewMargin;;
    int y = 0;
    
    if ([content isKindOfClass:[NSString class]]) {
        
        UILabel*lable = [[UILabel alloc]initWithFrame:CGRectMake(kMCMailDetailHeadViewNoteWidth + kMCMailDetailHeadViewMargin, 0, ScreenWidth - kMCMailDetailHeadViewAttactmentButtonSize*2, kMCMailDetailHeadViewContactButtonHight)];
        lable.font = [UIFont systemFontOfSize:kMCMailDetailHeadViewSubTitleFont];
        lable.text = (NSString*)content;
        lable.textColor = color;
        [contactView addSubview:lable];
        
    } else {
        
        NSArray*array = (NSArray*)content;
        for (int i = 0 ; i < array.count; i++) {
            MCMailAddress *mcMailAddress = array[i];
            if (!mcMailAddress.name) {
                continue;
            }
            NSMutableString *name = [NSMutableString stringWithString:mcMailAddress.name];
            CGSize titleSize =  [name mcStringSizeWithFont:kMCMailDetailHeadViewSubTitleFont maxWidth:MAXFLOAT maxHight:30.0];
            if ((x + titleSize.width - 2*kMCMailDetailHeadViewContactButtonSpace) > _kMCMailDetailHeadViewContactViewMaxWidth) {
                
                if (x == kMCMailDetailHeadViewNoteWidth + kMCMailDetailHeadViewMargin) {
                    titleSize.width = _kMCMailDetailHeadViewContactViewMaxWidth -3*kMCMailDetailHeadViewContactButtonSpace;
                    
                } else {
                    x  = kMCMailDetailHeadViewNoteWidth + kMCMailDetailHeadViewMargin;
                    y += kMCMailDetailHeadViewContactButtonSpace + kMCMailDetailHeadViewContactButtonHight;
                }
            }
            MCMailAddressButton*button = [MCMailAddressButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake( x , y, titleSize.width + kMCMailDetailHeadViewContactButtonSpace, kMCMailDetailHeadViewContactButtonHight);
            button.backgroundColor = [UIColor colorWithHexString:@"eeeff3"];
            button.layer.cornerRadius = 2.0f;
            button.exclusiveTouch = YES;
            
            [button setTitle:name forState:UIControlStateNormal];
            [button setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:kMCMailDetailHeadViewSubTitleFont];
            [button addTarget:self action:@selector(didSelectContactInfo:) forControlEvents:UIControlEventTouchUpInside];
            UILongPressGestureRecognizer *loogPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(mcButtonLoogPress:)];
            [button addGestureRecognizer:loogPressGesture];
            
            _defaultTag += 1 ;
            button.tag = _defaultTag ;
            [contactView addSubview:button];
            x += (titleSize.width + 2*kMCMailDetailHeadViewContactButtonSpace);
        }
    }
    
    contactView.frame = CGRectMake(0, hight, ScreenWidth - kMCMailDetailHeaViewDetailButtonWidth, y + kMCMailDetailHeadViewContactButtonHight);
    
    contactView.tag = kMCMailDetailHeadViewContactViewTag;
    return contactView;
}

- (void)setStar:(BOOL)star {
    UIImage *image = star?AppStatus.theme.mailStyle.mailDetailRightSelectImage:AppStatus.theme.mailStyle.mailDetailRightDeSelectImage;
    [_starActionButton setImage:image forState:UIControlStateNormal];
}

#pragma mark - button action

- (void)didSelectContactInfo:(UIButton*)sender{
    
    if ([_delegate respondsToSelector:@selector(mailDetailHeadView:didSelectContact:)]) {
        [_delegate mailDetailHeadView:self didSelectContact:_contactArray[sender.tag -1]];
    }
}
//loogPress
- (void)mcButtonLoogPress:(UIGestureRecognizer*)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [gesture.view becomeFirstResponder];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *menuItem = [[UIMenuItem alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Message_CopyText") action:@selector(copyAddress)];
        menuController.menuItems = @[menuItem];
        [menuController setTargetRect:gesture.view.frame inView:gesture.view.superview];
        [menuController setMenuVisible:YES animated:YES];
        _didSelectIndex = gesture.view.tag -1;
       }
}

- (void)starMail:(UIButton*)sender {
    MCMailManager *mailmanger = [[MCMailManager alloc]initWithAccount:AppStatus.currentUser];
    BOOL mark = !self.mail.isStar;
    [mailmanger setStarFlag:mark forMails:@[self.mail] success:nil failure:nil];
    self.star = mark;
    //友盟统计事件
    [MCUmengManager addEventWithKey:mc_mail_detail_star];
}
//显示自定义UIMenuItem
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if (action == @selector(copyAddress)) {
        return YES;
    }
    return NO;
}
//复制
- (void)copyAddress {
    MCContactModel *model = _contactArray[_didSelectIndex];
    [UIPasteboard generalPasteboard].string = model.account;
}
//show Detail
- (void)detailButtonAction:(UIButton*)sender{

    _detailContactShow      = !_detailContactShow;
    _mcSubTitleView .hidden  = _detailContactShow;
    _fromContactView.hidden = !_detailContactShow;
    
    NSString*titlte = _detailContactShow?PMLocalizedStringWithKey(@"PM_Mail_HideMoreDetail"):PMLocalizedStringWithKey(@"PM_Mail_ShowMoreDetail");
    [sender setTitle:titlte forState:UIControlStateNormal];
    CGFloat hight = _detailContactShow?_mailHeadViewShowHeight:_mailHeadViewhihedHeight;
    
    if ([_delegate respondsToSelector:@selector(maildetailHeadView:didChangeFrame:)]) {
        [_delegate maildetailHeadView:self didChangeFrame:hight];
    }
    [self loadViewWithAnimation:YES];
}

//contact
- (void)contactModelsWithMailAddess:(NSArray*)addresses {
    
    for (MCMailAddress *mailAddress in addresses) {
        MCContactModel *contactModel;
        if (![mailAddress.email isEmail]) {
            contactModel = [MCContactModel contactWithEmail:mailAddress.email emailNickName:mailAddress.name];
        } else {
            contactModel = [[MCContactManager sharedInstance] getOrCreateContactWithEmail:mailAddress.email name:mailAddress.name];
            if (contactModel.displayName) {
                mailAddress.name = contactModel.displayName;
            }
        }
        
        [_contactArray addObject:contactModel];
    }
}
//TODO:副标题
- (NSString*)subTitle{
    NSString *subTitle;
    NSMutableArray * toNames = [NSMutableArray new];
    for (int i = 0; i < _contactArray.count; i ++) {
        MCContactModel *contactModel = _contactArray[i];
        if (_mail.from.email && (i == 0)) {
            subTitle = contactModel.displayName;
            continue;
         }
        [toNames addObject:contactModel.displayName];
    }
    subTitle = [NSString stringWithFormat:@"%@ %@ %@",subTitle?subTitle:@"",PMLocalizedStringWithKey(@"PM_Mail_To"),[toNames componentsJoinedByString:@"、"]];
    return subTitle;
}

- (void)reloadView {
    
    self.detailContactShow = NO;
    [self loadViewWithAnimation:NO];
    for (UIView *vi in self.subviews) {
        [vi removeFromSuperview];
    }
    
    [_contactArray removeAllObjects];
    [_from removeAllObjects];
    [_to removeAllObjects];
    [_cc removeAllObjects];
    
    [self setUp];
}
@end
