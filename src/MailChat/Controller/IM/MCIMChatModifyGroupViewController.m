//
//  MCIMChatModifyGroupViewController.m
//  NPushMail
//
//  Created by swhl on 16/4/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatModifyGroupViewController.h"
#import "MCIMConversationModel.h"
#import "UIView+MCExpand.h"
#import "MCIMGroupManager.h"

static const int limitCount =36;

@interface MCIMChatModifyGroupViewController ()

@property (nonatomic, strong) MCIMConversationModel  *conversationModel;
@property (strong, nonatomic) UITextField *groupNameTextField;

@end

@implementation MCIMChatModifyGroupViewController

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UITextFieldTextDidChangeNotification
                                                 object:_groupNameTextField];
}

- (instancetype)initWithMCModifyInfoType:(MCModifyInfoType)modifyInfoType
                                 withObj:(id)obj
{
    self = [super init];
    if (self) {
        switch (modifyInfoType) {
            case MCModifyInfoTypeGroupName:
                self.conversationModel = obj;
                break;
            case MCModifyInfoTypeNickName:
//                self.conversationModel = obj;
                break;
            case MCModifyInfoTypeRemark:
//                self.conversationModel = obj;
                break;
            default:
                break;
        }
    }
    return self;
}

- (instancetype)initWithConversation:(MCIMConversationModel*)conversationModel
{
    self = [super init];
    if (self) {
        self.conversationModel = conversationModel;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    switch (self.modifyInfoType) {
        case MCModifyInfoTypeGroupName:
        self.navBarTitleLable.text = self.conversationModel.peer.peerName;
            break;
        default:
            self.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_Msg_NickName");
            break;
    }
    self.currentUserLable.text = @"";
    self.currentUserLable.frame = CGRectZero;
    [self.navBarTitleLable moveoffSetY:6.0f];
    
    self.rightNavigationBarButtonItem.title = PMLocalizedStringWithKey(@"PM_Msg_GroupNameSave");
    
    [self.view addSubview:self.groupNameTextField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(limitTextField:) name:UITextFieldTextDidChangeNotification object:_groupNameTextField];
}

-(void)rightNavigationBarButtonItemAction:(id)sender
{
    switch (self.modifyInfoType) {
        case MCModifyInfoTypeGroupName:
            [self modifyGroupName];
            break;
        case MCModifyInfoTypeNickName:
            [self modifyGroupNickName];
            break;
        case MCModifyInfoTypeRemark:
            [self modifyGroupRemark];
            break;
        default:
            break;
    }
}

//修改群名称
-(void)modifyGroupName
{
    MCIMGroupManager *manager =[MCIMGroupManager shared];
    
    if (_groupNameTextField.text.length<1) {
        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_IMChat_GroupErrorName")];
        return;
    }

    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_IMChat_GroupModifyName") maskType:SVProgressHUDMaskTypeClear];

    [manager changeGroup:self.conversationModel.peer withNewName:_groupNameTextField.text success:^{
        //
        [SVProgressHUD showSuccessWithStatus:PMLocalizedStringWithKey(@"PM_IMChat_GroupModifySuc")];
        
        MCIMGroupModel *groupModel = (MCIMGroupModel *)self.conversationModel.peer;
        groupModel.groupName = _groupNameTextField.text;
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
        //
        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_IMChat_GroupModifyErr")];
    }];

}
//修改昵称
-(void)modifyGroupNickName
{
    
}
//修改备注名
-(void)modifyGroupRemark
{
    
}


-(UITextField *)groupNameTextField
{
    if (!_groupNameTextField) {
        _groupNameTextField  = [[UITextField alloc] initWithFrame:CGRectMake(15, 16, ScreenWidth-30, 43)];
        _groupNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        testLabel.text = @"36";
        testLabel.textColor=[UIColor grayColor];
        _groupNameTextField.rightViewMode = UITextFieldViewModeAlways;
        _groupNameTextField.placeholder = self.conversationModel.peer.peerName;
        _groupNameTextField.text = self.conversationModel.peer.peerName;
        _groupNameTextField.rightView = testLabel;
    }
    return _groupNameTextField;
}

#pragma mark - touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark -UITextFieldDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length >= limitCount && text.length > range.length) {
        return NO;
    }
    return YES;
}

-(void)limitTextField:(NSNotification *)obj{
    
    NSUInteger textLength = _groupNameTextField.text.length;
    UILabel *label =(UILabel*)_groupNameTextField.rightView;
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
        }
    }
}

#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
