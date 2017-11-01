//
//  MCMailComposerHeadView.m
//  NPushMail
//
//  Created by zhang on 16/1/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMailComposerHeadView.h"
#import "UIColor+Hex.h"
#import "MCPopoverView.h"
@interface MCMailComposerHeadView ()<TITokenFieldDelegate,UITextFieldDelegate>

@property (nonatomic,assign)CGFloat currentHeight;
//addContact
@property (nonatomic,strong)UIButton *addContact;

@property (nonatomic)NSInteger currentTokenFieldIndex;

@end

const static CGFloat kMCMailComposerHeadViewAddcontactViewHight = 40.0;
const static CGFloat kMCMailComposerHeadViewAddcontactViewWidth = 50.0;
const static CGFloat kMCMailComposerHeadViewTokenFieldHight     = 45.0;
const static CGFloat kMCMailComposerHeadViewSpace               = 10.0;

@implementation MCMailComposerHeadView


- (id)init{
    return [self initWithFrame:CGRectMake(0, 0, ScreenWidth, kMCMailComposerHeadViewTokenFieldHight*2)];
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        self.currentHeight = frame.size.height;
        [self setUp];
    }
    return self;
}

- (void)setUp{
    
    [self addSubview:self.toTokenField];
    [self addSubview:self.ccTokenField];
    [self addSubview:self.bcTokenField];
    [self addSubview:self.subjectField];
    [self addSubview:self.addContact];
    
    self.currentTokenFieldIndex = ToTokenFieldTag;
}

#pragma mark - subViews
//收件人
- (TITokenField*)toTokenField{
    
    if (!_toTokenField) {
        
        _toTokenField = [[TITokenField alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, kMCMailComposerHeadViewTokenFieldHight)];
        _toTokenField.keyboardType = UIKeyboardTypeEmailAddress;
        [_toTokenField addTarget:self action:@selector(tokenFieldFrameWillChange:) forControlEvents:(UIControlEvents)TITokenFieldControlEventFrameWillChange];
        [_toTokenField addTarget:self action:@selector(tokenFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [_toTokenField addTarget:self action:@selector(tokenFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_toTokenField addTarget:self action:@selector(tokenFieldTextDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        _toTokenField.tag = ToTokenFieldTag;
        [_toTokenField setPromptText:[NSString stringWithFormat:@"%@:",PMLocalizedStringWithKey(@"PM_Mail_MailTo")]];
        _toTokenField.delegate = self;
        
        UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        _toTokenField.rightView = rightView;
        _toTokenField.rightViewMode = UITextFieldViewModeAlways;
        
    }
    return _toTokenField;
}

// 抄送地址
- (TITokenField*)ccTokenField{
    if (!_ccTokenField) {
        
        _ccTokenField = [[TITokenField alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, kMCMailComposerHeadViewTokenFieldHight)];
        _ccTokenField.keyboardType = UIKeyboardTypeEmailAddress;
        [_ccTokenField addTarget:self action:@selector(tokenFieldFrameWillChange:) forControlEvents:(UIControlEvents)TITokenFieldControlEventFrameWillChange];
        [_ccTokenField addTarget:self action:@selector(tokenFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [_ccTokenField addTarget:self action:@selector(tokenFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_ccTokenField addTarget:self action:@selector(tokenFieldTextDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        _ccTokenField.tag = CcTokenFieldTag;
        _ccTokenField.hidden = YES;
        [_ccTokenField setPromptText:[NSString stringWithFormat:@"%@:",PMLocalizedStringWithKey(@"PM_Mail_MailCc")]];
        _ccTokenField.delegate = self;
        
        UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        _ccTokenField.rightView = rightView;
        _ccTokenField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _ccTokenField;
}
//密送人
- (TITokenField*)bcTokenField{
    
    if (!_bcTokenField) {
        _bcTokenField = [[TITokenField alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, kMCMailComposerHeadViewTokenFieldHight)];
        _bcTokenField.keyboardType = UIKeyboardTypeEmailAddress;
        _bcTokenField.hidden = YES;
        _bcTokenField.tag = BcTokenFieldTag;
        [_bcTokenField addTarget:self action:@selector(tokenFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [_bcTokenField
         addTarget:self action:@selector(tokenFieldFrameWillChange:) forControlEvents:(UIControlEvents)TITokenFieldControlEventFrameWillChange];
        [_bcTokenField addTarget:self action:@selector(tokenFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_bcTokenField addTarget:self action:@selector(tokenFieldTextDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [_bcTokenField setPromptText:[NSString stringWithFormat:@"%@:",PMLocalizedStringWithKey(@"PM_Mail_Mialbcc")]];
        _bcTokenField.delegate = self;
        
        UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        _bcTokenField.rightView = rightView;
        _bcTokenField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _bcTokenField;
    
}

- (UITextField*)subjectField{
    if (!_subjectField) {
        
        _subjectField = [[UITextField alloc]initWithFrame:CGRectMake(0, kMCMailComposerHeadViewTokenFieldHight +_toTokenField.frame.origin.y, ScreenWidth, kMCMailComposerHeadViewTokenFieldHight )];
        _subjectField.textColor = [UIColor colorWithHexString:@"777777"];
        
        UIView*lefteView = [[UIView alloc]init];
        lefteView.backgroundColor = [UIColor clearColor];
        
        UILabel*subTitleLab = [[UILabel alloc]init];
        subTitleLab.text = [NSString stringWithFormat:@"%@:",PMLocalizedStringWithKey(@"PM_Mail_MailSubject")];
        subTitleLab.textAlignment = NSTextAlignmentLeft;
        subTitleLab.textColor = _subjectField.textColor;
        subTitleLab.font = [UIFont systemFontOfSize:17.0f];
        NSDictionary *attribute = @{NSFontAttributeName: subTitleLab.font};
        CGSize size = [subTitleLab.text boundingRectWithSize:CGSizeMake(60, 60) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        subTitleLab.frame = CGRectMake(kMCMailComposerHeadViewSpace, 0, size.width, kMCMailComposerHeadViewTokenFieldHight);
        [lefteView addSubview:subTitleLab];
        lefteView.frame = CGRectMake(0, 0, kMCMailComposerHeadViewSpace + size.width + 5, kMCMailComposerHeadViewTokenFieldHight);
        [_subjectField setLeftView:lefteView];
        _subjectField.leftViewMode = UITextFieldViewModeAlways;
        _subjectField.delegate = self;
        _subjectField.tag = subjectFieldTag;
        _subjectField.font = [UIFont systemFontOfSize:17.0f];
        [_subjectField addTarget:self action:@selector(tokenFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_subjectField addTarget:self action:@selector(tokenFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
        UIView*spLine = [[UIView alloc]initWithFrame:CGRectMake(kMCMailComposerHeadViewSpace, kMCMailComposerHeadViewTokenFieldHight - 2, ScreenWidth - kMCMailComposerHeadViewSpace, 0.5)];
        spLine.backgroundColor = AppStatus.theme.toolBarSeparatorColor;
        [_subjectField addSubview:spLine];
        
        UIView*leftView = [[UIView alloc]initWithFrame:CGRectMake(kMCMailComposerHeadViewSpace, 0, 20, kMCMailComposerHeadViewTokenFieldHight)];
        leftView.backgroundColor = [UIColor clearColor];
        
        _subjectField.rightView = leftView;
        _subjectField.rightViewMode = UITextFieldViewModeAlways;
        
    }
    return _subjectField;
    
}

- (UIButton*)addContact{
    //添加联系人btn
    
    if (!_addContact) {
        _addContact = [UIButton buttonWithType:UIButtonTypeCustom];
        _addContact.frame = CGRectMake(ScreenWidth - kMCMailComposerHeadViewAddcontactViewWidth, 3, kMCMailComposerHeadViewAddcontactViewWidth, kMCMailComposerHeadViewAddcontactViewHight);
        [_addContact addTarget:self action:@selector(selectContacts:) forControlEvents:UIControlEventTouchUpInside];
        [_addContact setImage:[UIImage imageNamed:@"mc_mailWrite_more.png"] forState:UIControlStateNormal];
    }
    return _addContact;
}


//调整界面
- (void)layoutSubviews{
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.ccTokenField.frame;
        rect.origin.y = self.toTokenField.frame.size.height;
        self.ccTokenField.frame = rect;
        rect = self.bcTokenField.frame ;
        rect.origin.y = self.ccTokenField.hidden?self.toTokenField.frame.size.height:self.ccTokenField.frame.size.height+self.ccTokenField.frame.origin.y;
        self.bcTokenField.frame = rect;
        
        rect = self.subjectField.frame;
        CGFloat currentY = self.toTokenField.frame.size.height;
        if (self.ccTokenField.hidden == NO) {
            currentY += self.ccTokenField.frame.size.height;
        }
        if (self.bcTokenField.hidden == NO) {
            currentY += self.bcTokenField.frame.size.height;
        }
        rect.origin.y = currentY;
        self.subjectField.frame = rect;
        
        rect = self.frame;
        rect.size.height = self.subjectField.frame.size.height  +self.subjectField.frame.origin.y;
        self.frame = rect;
        
        rect = self.addContact.frame;
        if (_currentTokenFieldIndex == ToTokenFieldTag) {
            rect.origin.y = self.toTokenField.frame.origin.y+3;
        }else if (_currentTokenFieldIndex == CcTokenFieldTag){
            rect.origin.y = self.ccTokenField.frame.origin.y+3;
        }else if (_currentTokenFieldIndex == BcTokenFieldTag){
            rect.origin.y = self.bcTokenField.frame.origin.y+3;
        }else{
            rect.origin.y = -100;
        }
        self.addContact.frame = rect;
        
    }  completion:^(BOOL finished) {
        
        if (self.currentHeight != self.frame.size.height) {
            
            if ([_delegate respondsToSelector:@selector(composerHeadView:didChangeFrame:)]) {
                [_delegate composerHeadView:self didChangeFrame:self.frame.size.height];
            }
            _currentHeight = self.frame.size.height;
        }
        
    }];
    
}

//add cc or bc or select contact
- (void)selectContacts:(UIButton*)sender{
    
    [self.superview endEditing:YES];
    if (self.currentTokenFieldIndex == ToTokenFieldTag || self.currentTokenFieldIndex == subjectFieldTag) {
//        [self.toTokenField becomeFirstResponder];
        CGPoint point = CGPointMake(sender.frame.origin.x + sender.frame.size.width/2, sender.frame.origin.y + sender.frame.size.height + kMCMailComposerHeadViewTokenFieldHight+3);
        NSArray *titles = @[PMLocalizedStringWithKey(@"PM_Mail_MailCc"),PMLocalizedStringWithKey(@"PM_Mail_Mialbcc"),PMLocalizedStringWithKey(@"PM_Main_Tab_Contact_Email")];
        MCPopoverView *mcPopoverView = [MCPopoverView new];
        mcPopoverView.menuTitles = titles;
        [mcPopoverView showFromPoint:point popoverViewStyle:MCPopoverViewStyleUp selected:^(NSInteger index) {
            
            switch (index) {
                case 0:{
                    //友盟事件统计
                    [MCUmengManager addEventWithKey:mc_mail_detail_write_cc];
                    [self.ccTokenField becomeFirstResponder];
                }
                    break;
                case 1:{
                    //友盟事件统计
                    [MCUmengManager addEventWithKey:mc_mail_detail_write_bcc];
                    [self.bcTokenField becomeFirstResponder];
                }
                    break;
                case 2:{
                    
                    if ([_delegate respondsToSelector:@selector(composerHeadView:selectContactForTokenField:)]) {
                        //友盟事件统计
                        [MCUmengManager addEventWithKey:mc_mail_detail_write_contact];
                        [_delegate composerHeadView:self selectContactForTokenField:self.toTokenField];
                    }
                    
                }
                    break;
                default:
                    break;
            }
        }];
        
    } else {
        //友盟事件统计
        [MCUmengManager addEventWithKey:mc_mail_detail_write_contact];
        
        if ([_delegate respondsToSelector:@selector(composerHeadView:selectContactForTokenField:)]) {
            if (_currentTokenFieldIndex == CcTokenFieldTag) {
                [_delegate composerHeadView:self selectContactForTokenField:self.ccTokenField];
            } else {
                [_delegate composerHeadView:self selectContactForTokenField:self.bcTokenField];
            }
        }
        
    }
    
}

#pragma mark - tokenField

- (void)tokenFieldFrameWillChange:(TITokenField*)tokenField{
    
    [self setNeedsLayout];
    
    if ([_delegate respondsToSelector:@selector(composerHeadView:tokenFieldFrameWillChange:)]) {
        [_delegate composerHeadView:self tokenFieldFrameWillChange:tokenField];
    }
    
}

- (void)tokenFieldDidBeginEditing:(TITokenField*)tokenField{
    
    TITokenField*cc = (TITokenField*)[self viewWithTag:CcTokenFieldTag];
    TITokenField*bc = (TITokenField*)[self viewWithTag:BcTokenFieldTag];
    if ( (cc.text.length > 1) ||(_cc&&_cc.count > 0) || cc.tokens.count > 0) {
        _cc = nil;
        cc.hidden = NO;
    } else {
        cc.hidden = YES;
    }
    
    if ( (bc.text.length > 1) ||(_bcc&&_bcc.count > 0)||bc.tokens.count > 0) {
        _bcc = nil;
        bc.hidden = NO;
    } else {
        bc.hidden = YES;
    }
    switch (tokenField.tag) {
            
        case CcTokenFieldTag:{
            self.ccTokenField.hidden = NO;
        }
            break;
        case BcTokenFieldTag:{
            self.bcTokenField.hidden = NO;
        }
            break;
            
        default:
            break;
    }
    _currentTokenFieldIndex = tokenField.tag;
    [self setNeedsLayout];
    
    if ([_delegate respondsToSelector:@selector(composerHeadView:tokenFieldDidBeginEditing:)]) {
        
        [_delegate composerHeadView:self tokenFieldDidBeginEditing:tokenField];
    }
    
}

- (void)tokenFieldTextDidChange:(TITokenField*)tokenField{
    
    if ([_delegate respondsToSelector:@selector(composerHeadView:tokenFieldTextDidChange:)]) {
        [_delegate composerHeadView:self tokenFieldTextDidChange:tokenField];
    }
}
- (void)tokenFieldTextDidEndEditing:(TITokenField*)tokenField {
    if ([_delegate respondsToSelector:@selector(composerHeadView:endEditing:)]) {
        [_delegate composerHeadView:self endEditing:tokenField];
    }
}

#pragma mark - tokenField Delegate

- (BOOL)tokenField:(TITokenField *)tokenField willAddToken:(TIToken *)token{
    
    if ([_delegate respondsToSelector:@selector(composerHeadView:tokenField:willAddToken:)]) {
        [_delegate composerHeadView:self tokenField:tokenField willAddToken:token];
    }
    return YES;
}
- (void)tokenField:(TITokenField *)tokenField didAddToken:(TIToken *)token{
    if ([_delegate respondsToSelector:@selector(composerHeadView:tokenField:didAddToken:)]) {
        [_delegate composerHeadView:self tokenField:tokenField didAddToken:token];
    }
}
- (BOOL)tokenField:(TITokenField *)tokenField willRemoveToken:(TIToken *)token{
    
    if ([_delegate respondsToSelector:@selector(composerHeadView:tokenField:willRemoveToken:)]) {
        [_delegate composerHeadView:self tokenField:tokenField willRemoveToken:token];
    }
    return YES;
}
- (void)tokenField:(TITokenField *)tokenField didRemoveToken:(TIToken *)token{
//    if ([_delegate respondsToSelector:@selector(composerHeadView:tokenField:didRemoveToken:)]) {
//        [_delegate composerHeadView:self tokenField:tokenField didRemoveToken:token];
//    }
}
- (void)tokenField:(TITokenField *)tokenField didTouchUpInsideToken:(TIToken *)token{
    if ([_delegate respondsToSelector:@selector(composerHeadView:tokenField:didTouchUpInsideToken:)]) {
        [_delegate composerHeadView:self tokenField:tokenField didTouchUpInsideToken:token];
    }
}


#pragma mark - public

- (void)addtoken:(NSArray *)titles tokenIndex:(NSInteger)tokenIndex{
    
    TITokenField*tokenField = (TITokenField*)[self viewWithTag:tokenIndex];
    [tokenField addTokensWithTitleArray:titles];
    [tokenField becomeFirstResponder];
    [self setNeedsLayout];
}


- (void)setCc:(NSArray *)cc{
    
    if (cc&&cc.count>0) {
        _cc = cc;
        [self.ccTokenField addTokensWithTitleArray:cc];
        [self.ccTokenField setHidden:NO];
        [self.ccTokenField didEndEditing];
        [self setNeedsLayout];
    }
    
}

- (void)setBcc:(NSArray *)bcc{
    if (bcc&&bcc.count > 0) {
        _bcc = bcc;
        [self.bcTokenField addTokensWithTitleArray:bcc];
        [self.bcTokenField setHidden:NO];
        [self.bcTokenField didEndEditing];
        [self setNeedsLayout];
    }
    
}

- (void)setTo:(NSArray *)to
{
    [self.toTokenField addTokensWithTitleArray:to];
    [self.toTokenField didEndEditing];
    [self setNeedsLayout];
}

- (void)setSubject:(NSString *)subject{
    
    self.subjectField.text = subject;
}
@end
