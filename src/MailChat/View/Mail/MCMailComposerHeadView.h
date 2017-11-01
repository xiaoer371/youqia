//
//  MCMailComposerHeadView.h
//  NPushMail
//
//  Created by zhang on 16/1/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

#define ToTokenFieldTag   10
#define CcTokenFieldTag   11
#define BcTokenFieldTag   12
#define subjectFieldTag   13

#import <UIKit/UIKit.h>
#import "TITokenField.h"

@class MCMailComposerHeadView;

@protocol MCMailComposerHeadViewDelegate <NSObject>

@optional
//tokenField frame 改变时调用
- (void)composerHeadView:(MCMailComposerHeadView*)headView tokenFieldFrameWillChange:(TITokenField*)tokenField ;
//tokenField 开始编辑时调用
- (BOOL)composerHeadView:(MCMailComposerHeadView*)headView tokenFieldDidBeginEditing:(TITokenField*)tokenField ;
//tokenField 编辑过程 调用
- (void)composerHeadView:(MCMailComposerHeadView*)headView tokenFieldTextDidChange:(id)field ;
//tokenField 添加token 时调用
- (void)composerHeadView:(MCMailComposerHeadView*)headView tokenField:(TITokenField *)tokenField didAddToken:(TIToken *)token;

- (void)composerHeadView:(MCMailComposerHeadView*)headView tokenField:(TITokenField *)tokenField willAddToken:(TIToken *)token;

//tokenField 移除token时调用
- (void)composerHeadView:(MCMailComposerHeadView*)headView tokenField:(TITokenField *)tokenField willRemoveToken:(TIToken *)token;
//tokenField token被点击时调用
- (void)composerHeadView:(MCMailComposerHeadView*)headView tokenField:(TITokenField *)tokenField didTouchUpInsideToken:(TIToken *)token;
- (void)composerHeadView:(MCMailComposerHeadView*)headView didChangeFrame:(CGFloat)height;

- (void)composerHeadView:(MCMailComposerHeadView *)headView selectContactForTokenField:(TITokenField *)tokenField;
- (void)composerHeadView:(MCMailComposerHeadView *)headView endEditing:(TITokenField*)tokenField;
@end

@interface MCMailComposerHeadView : UIView

@property(nonatomic,weak)id <MCMailComposerHeadViewDelegate>delegate;

//收件人
@property(nonatomic,strong)TITokenField *toTokenField;
//抄送人
@property(nonatomic,strong)TITokenField *ccTokenField;
//密送人
@property(nonatomic,strong)TITokenField *bcTokenField;
//主题
@property(nonatomic,strong)UITextField  *subjectField;


@property(nonatomic,strong)NSArray *to;
@property(nonatomic,strong)NSArray *cc;
@property(nonatomic,strong)NSArray *bcc;
@property(nonatomic,strong)NSString*subject;

- (id)init;

- (void)addtoken:(NSArray*)titles tokenIndex:(NSInteger)tokenIndex;


@end
