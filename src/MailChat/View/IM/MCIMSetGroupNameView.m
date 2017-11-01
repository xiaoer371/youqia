//
//  MCIMSetGroupNameView.m
//  NPushMail
//
//  Created by swhl on 16/4/20.
//  Copyright © 2016年 sprite. All rights reserved.


#import "MCIMSetGroupNameView.h"
static const int limitCount =36;

@interface MCIMSetGroupNameView () <UITextFieldDelegate>

@end

@implementation MCIMSetGroupNameView

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UITextFieldTextDidChangeNotification
                                                 object:_groupName];
}

-(instancetype)initWithFrame:(CGRect)frame withSure:(sureBlock)sureBlock withCancel:(cancelBlock)cancelBlock
{
    self =[super initWithFrame:frame];
    if (self)
    {
        self.clipsToBounds = YES;
        self.sureBlock = sureBlock;
        self.cancelBlock = cancelBlock;
        self.backgroundColor =[UIColor whiteColor];
        self.layer.cornerRadius = 8;
        [self _initSubView:frame];
    }
    return self;
}

-(void)_initSubView:(CGRect)frame
{
    CGRect rect =frame;
    //
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, rect.size.width, 30)];
    titleLab.text = @"设置群名";
    titleLab.textColor =[UIColor colorWithHexString:@"333333"];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor =[UIColor blackColor];
    [self addSubview:titleLab];
    
    _groupName =[[UITextField alloc] initWithFrame:CGRectMake(20, 40, rect.size.width-40, 30)];
    _groupName.delegate = self;
    _groupName.layer.borderWidth =1;
    [_groupName becomeFirstResponder];
    _groupName.layer.borderColor =[[UIColor colorWithHexString:@"bbbbbb"] CGColor];
    _groupName.borderStyle = UITextBorderStyleLine;
    [self addSubview:_groupName];
    
    
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    testLabel.text = @"36";
    testLabel.textColor=[UIColor grayColor];
    _groupName.rightViewMode = UITextFieldViewModeAlways;
    _groupName.rightView = testLabel;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(limitTextField:) name:UITextFieldTextDidChangeNotification object:_groupName];
    
    
    UIButton *cancelBtn =[UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.layer.borderWidth =1;
    cancelBtn.layer.borderColor =[[UIColor colorWithHexString:@"dddddd"] CGColor];
    cancelBtn.frame =CGRectMake(0, rect.size.height-37, rect.size.width/2, 37);
    [cancelBtn setTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithHexString:@"0793da"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
    UIButton *sureBtn =[UIButton buttonWithType:UIButtonTypeSystem];
    sureBtn.layer.borderWidth =1;
    sureBtn.layer.borderColor =[[UIColor colorWithHexString:@"dddddd"] CGColor];
    sureBtn.frame =CGRectMake(rect.size.width/2, rect.size.height-37, rect.size.width/2, 37);
    [sureBtn setTitle:PMLocalizedStringWithKey(@"PM_Common_Sure") forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor colorWithHexString:@"0793da"] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sureBtn];
    
}

-(void)limitTextField:(NSNotification *)obj{
    
    NSUInteger textLength = _groupName.text.length;
    UILabel *label =(UILabel*)_groupName.rightView;
    if (limitCount - textLength>0 && limitCount - textLength<37 ) {
        label.text= [NSString stringWithFormat:@"%lu",limitCount - textLength];
    }else label.text =@"0";
    
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    //   [UITextInputMode currentInputMode]
    NSString *lang = [ [textField textInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > limitCount) {
                textField.text = [toBeString substringToIndex:limitCount];
//                showAler(PMLocalizedStringWithKey(@"PM_Mine_NickNameLengthWrong"));
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > limitCount) {
            textField.text = [toBeString substringToIndex:limitCount];
//            showAler(PMLocalizedStringWithKey(@"PM_Mine_NickNameLengthWrong"));
        }
    }
}

-(void)cancelBtnAction:(UIButton*)sender
{
    if (self.cancelBlock) {
        self.cancelBlock();
    };
}

-(void)sureBtnAction:(UIButton*)sender
{
    if (self.sureBlock) {
        self.sureBlock(_groupName.text);
    };
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (self.sureBlock) {
        self.sureBlock(_groupName.text);
    };
    return YES;
}

@end
