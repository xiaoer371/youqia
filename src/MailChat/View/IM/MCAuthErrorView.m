//
//  MCAuthErrorView.m
//  NPushMail
//
//  Created by swhl on 16/12/8.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAuthErrorView.h"
#import "MCAppStatus.h"

@interface MCAuthErrorView ()

@property (nonatomic,assign) AuthErrorType type;

@end

@implementation MCAuthErrorView

- (instancetype)initWithType:(AuthErrorType)type
{
    self = [super init];
    if (self) {
        self.type = type;
         self.backgroundColor = AppStatus.theme.backgroundColor;
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    CGRect rect = CGRectMake(0, 0, ScreenWidth, ScreenHeigth-49);
    self.frame = rect;
    
    NSString *text;
    switch (self.type) {
        case AuthErrorTypeMail:
        {
            text =[NSString stringWithFormat:@"您的邮箱账号:%@ 验证失败，为保证您的信息安全，已将消息内容隐藏，请检查账号密码是否正确。",AppStatus.currentUser.email];
        }
            break;
        case AuthErrorTypeOA:
        {
            text =[NSString stringWithFormat:@"fadsfadsjkfnadskjfnadsfadsfsadfadsfads:%@ 验证失败，为保证您的信息安全，已将消息内容隐藏，请检查账号密码是否正确。",AppStatus.currentUser.email];
        }
            break;
            
        default:
            break;
    }
    CGSize size = [text boundingRectWithSize:CGSizeMake(ScreenWidth -40, 1000)  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]} context:nil].size;

    CGRect labRect = CGRectMake(20, 60, size.width, size.height+10);
    UILabel *label = [[UILabel alloc] initWithFrame:labRect];
    label.textColor = [UIColor colorWithHexString:@"777777"];
    label.text = text;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:16.0f];
    [self addSubview:label];
    
    CGFloat authBtnY = CGRectGetMaxY(label.frame)+30;
    UIButton *reAuthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reAuthBtn.frame = CGRectMake(55, authBtnY, ScreenWidth-110, 44);
    reAuthBtn.layer.cornerRadius = 5.0f;
    [reAuthBtn setTitle:PMLocalizedStringWithKey(@"PM_Login_AccountReValidation") forState:UIControlStateNormal];
    reAuthBtn.backgroundColor =  AppStatus.theme.tintColor; //[UIColor colorWithHexString:@"6f9cdd"];
    [reAuthBtn addTarget:self action:@selector(reAuth:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:reAuthBtn];
    
    
    
    CGFloat helpBtnY = CGRectGetMaxY(reAuthBtn.frame)+10;
//    NSString *string =PMLocalizedStringWithKey(@"PM_Login_HelperText");
//    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:string];
//    NSRange range =[string rangeOfString:PMLocalizedStringWithKey(@"PM_Login_Helper")];
//    [attriString addAttribute:NSForegroundColorAttributeName value:AppStatus.theme.tintColor range:range];
    
    UIButton *helpBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    helpBtn.frame = CGRectMake(0 , helpBtnY, ScreenWidth, 20);
//    helpBtn.titleLabel.textColor = AppStatus.theme.fontTintColor;
//    [helpBtn setAttributedTitle:attriString forState:(UIControlStateNormal)];
    
    [helpBtn setTitle:PMLocalizedStringWithKey(@"PM_Login_Helper") forState:UIControlStateNormal];
    [helpBtn setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
    
    helpBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [helpBtn addTarget:self action:@selector(help:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:helpBtn];

}

- (void)help:(UIButton *)sender
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(conversationWithHelper:)]) {
        [self.delegate conversationWithHelper:self];
    }
}

- (void)reAuth:(UIButton *)sender
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(reAuth:)]) {
        [self.delegate reAuth:self];
    }
}

@end
