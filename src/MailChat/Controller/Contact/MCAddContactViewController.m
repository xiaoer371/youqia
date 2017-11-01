//
//  MCAddContactViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/8/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAddContactViewController.h"
#import "MCAddContactCellDataSource.h"
#import "MCAddContactBaseInfoCell.h"
#import "MCGestureManagerCell.h"
#import "MCContactManager.h"
#import "UIAlertView+Blocks.h"

@interface MCAddContactViewController ()<UITableViewDelegate, textFieldDelegate, UITextFieldDelegate>

@property(nonatomic, strong) UITableView *mainTableView;
@property(nonatomic, strong) NSMutableArray *baseInfos;
@property(nonatomic, strong) NSMutableArray *phones;
@property(nonatomic, assign) BOOL importantFlag;
@property(nonatomic, assign) MCContactEditType contactEditType;
@property(nonatomic, assign) MCContactModel *contactModel;

@end

static const CGFloat KeyboardHeight = 264;

@implementation MCAddContactViewController {
    MCAddContactCellDataSource *_tableViewDataSource;
}

- (id)initWithContactEditType:(MCContactEditType)type contactModel:(MCContactModel *)model {
    if (self = [super init]) {
        _contactEditType = type;
        _contactModel = model;
        _importantFlag = model.importantFlag;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_contactEditType == editContactInfo) {
        self.viewTitle = PMLocalizedStringWithKey(@"PM_Contact_editContactInfo");
    }else {
        self.viewTitle = PMLocalizedStringWithKey(@"PM_Contact_AddContact");
        [self.rightNavigationBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0],NSForegroundColorAttributeName:[UIColor colorWithRed:149 green:181 blue:231 alpha:0.6]} forState:UIControlStateNormal];
        [self.rightNavigationBarButtonItem setEnabled:NO];
    }
    [self.leftNavigationBarButtonItem setImage:nil];
    [self.leftNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
    [self.rightNavigationBarButtonItem setTitle:[NSString stringWithFormat:@"%@",PMLocalizedStringWithKey(@"PM_Msg_GroupNameSave")]];
    [self initSubViews];
    // Do any additional setup after loading the view from its nib.
}

- (void)initSubViews {
    __weak MCAddContactViewController *weakSelf = self;
    TableViewCellConfigureBlock configureSearchCell = ^(id model, id cell, NSIndexPath *indexPath) {
        [weakSelf configureContactTableViewCellWithModel:model cell:cell indexPath:indexPath];
    };
    commitEditingCellBlock commitEditingCellBlock = ^(UITableView *tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath) {
        [weakSelf commitEditingCellWithTableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    };
    _tableViewDataSource = [[MCAddContactCellDataSource alloc] initWithBaseInfos:self.baseInfos phones:self.phones baseInfoCellIdentifier:@"MCAddContactBaseInfoCell" settingCellIdentifier:@"MCGestureManagerCell" configureCellBlock:configureSearchCell commitEditingCellBlock:commitEditingCellBlock];
    if (_contactEditType == editContactInfo) {
        if (!_contactModel.isCompanyUser) {
            _tableViewDataSource.enableDeleteFlag = YES;
        }
    }
    _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT) style:UITableViewStyleGrouped];
    _mainTableView.delegate = self;
    _mainTableView.backgroundColor = AppStatus.theme.backgroundColor;
    _mainTableView.dataSource = _tableViewDataSource;
    _mainTableView.tableFooterView = [[UIView alloc] init];
    _mainTableView.sectionFooterHeight = 0.0f;
    _mainTableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    [_mainTableView registerNib:[UINib nibWithNibName:@"MCAddContactBaseInfoCell" bundle:nil] forCellReuseIdentifier:@"MCAddContactBaseInfoCell"];
    [_mainTableView registerNib:[UINib nibWithNibName:@"MCGestureManagerCell" bundle:nil] forCellReuseIdentifier:@"MCGestureManagerCell"];
    _mainTableView.allowsSelection = YES;
    _mainTableView.allowsSelectionDuringEditing = YES;
    [_mainTableView setEditing:YES];
    [self.view addSubview:_mainTableView];
}

- (NSMutableArray *)baseInfos {
    if (!_baseInfos) {
        _baseInfos = [NSMutableArray arrayWithObjects:@"", @"", nil];
        if (_contactEditType == editContactInfo) {
            if (_contactModel) {
                NSString *noteName = _contactModel.noteDisplayName ? _contactModel.noteDisplayName:@"";
                NSString *emailAddress = _contactModel.account;
                _baseInfos = [NSMutableArray arrayWithObjects:noteName, emailAddress, nil];
            }
        }
    }
    return _baseInfos;
}

- (NSMutableArray *)phones {
    if (!_phones) {
        _phones = [NSMutableArray arrayWithCapacity:0];
        if (_contactEditType == editContactInfo) {
            if (_contactModel) {
                if (_contactModel.notePhoneNumbers) {
                    _phones = [[_contactModel.notePhoneNumbers componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]] mutableCopy];
                    NSInteger count = _phones.count;
                    while (count) {
                        NSString *phoneStr = [_phones objectAtIndex:count - 1];
                        if ([[phoneStr trim] length] == 0) {
                            [_phones removeObject:phoneStr];
                        }
                        count --;
                    }
                }
            }
        }
    }
    return _phones;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] init];
    return v;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == _phones.count) {
            [self addRowsWithTableView:tableView indexPath:indexPath];
        }
    }
    if (indexPath.section == 3) {
        //删除联系人
        __weak MCAddContactViewController *weakSelf = self;
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
        RIButtonItem *sureItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Msg_DelMsgCell") action:^{
            [[MCContactManager sharedInstance] deleteContacts:@[weakSelf.contactModel]];
            //友盟统计事件
            [MCUmengManager addEventWithKey:mc_contact_delete label:@"联系人删除"];
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Contact_deleteNotice") cancelButtonItem:cancelItem otherButtonItems:sureItem, nil];
        [alertV show];
    }
}

- (void)commitEditingCellWithTableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteRowsWithTableView:tableView indexPath:indexPath];
    }else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self addRowsWithTableView:tableView indexPath:indexPath];
    }

}

- (void)deleteRowsWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath  {
    [_phones removeObjectAtIndex:indexPath.row];
    NSIndexPath* currentRfreshItemPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    NSMutableArray* currentRfreshItemPathArray = [NSMutableArray arrayWithCapacity:0];
    [currentRfreshItemPathArray addObject:currentRfreshItemPath];
    [tableView deleteRowsAtIndexPaths:currentRfreshItemPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addRowsWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath  {
    if (_phones.count == maxPhonesCanAdd) {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Contact_maxPhonesCanAdd") delegate:nil cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel") otherButtonTitles:nil, nil];
        [alertV show];
        return;
    }
    NSIndexPath* currentRfreshItemPath = [NSIndexPath indexPathForRow:_phones.count inSection:indexPath.section];
    [_phones addObject:@""];
    NSMutableArray* currentRfreshItemPathArray = [NSMutableArray arrayWithCapacity:0];
    [currentRfreshItemPathArray addObject:currentRfreshItemPath];
    [tableView insertRowsAtIndexPaths:currentRfreshItemPathArray withRowAnimation:
     UITableViewRowAnimationAutomatic];
    MCAddContactBaseInfoCell *cell = [tableView cellForRowAtIndexPath:currentRfreshItemPath];
    [cell.textField becomeFirstResponder];

}

#pragma  mark - UITableViewDelegate
//当table进入编辑模式时，回调该方法获取应该是哪种编辑模式：插入，删除，none(移动)。模式不实现系统是使用删除模式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == (self.phones.count)) {
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
}

//当出现删除按钮时，回调该方法显示删除按钮的名字，默认不实现是delete
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return PMLocalizedStringWithKey(@"PM_Msg_DelMsgCell");
}

//将要出现删除按钮时的回调，调整subview的位置
-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
//删除按钮消失后的回调，用于重新调整subview到原来位置
-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //编辑完成
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //关键代码，可以防止键盘升起时避免挡住textField
    [_mainTableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, KeyboardHeight, 0)];
    [_mainTableView setContentInset:UIEdgeInsetsMake(0, 0, KeyboardHeight, 0)];
    UITableViewCell *cell = EGOVersion_iOS8 ? (UITableViewCell *) textField.superview.superview : (UITableViewCell *) textField.superview.superview.superview;
    NSIndexPath *indexPath = [_mainTableView indexPathForCell:cell];
    [_mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - valueTextFieldDelegate
-(void) valueTextFieldDidChange:(UITextField *)textField {
    MCAddContactBaseInfoCell *cell = EGOVersion_iOS8 ? (MCAddContactBaseInfoCell *) textField.superview.superview : (MCAddContactBaseInfoCell *) textField.superview.superview.superview;
    NSIndexPath *indexPath = [_mainTableView indexPathForCell:cell];
    NSString* value = textField.text;
    switch (indexPath.section) {
        case 0: {
            [_baseInfos replaceObjectAtIndex:indexPath.row withObject:value];
            if (indexPath.row == 1) {
                if ([value length] > 0) {
                    [self.rightNavigationBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0],NSForegroundColorAttributeName:AppStatus.theme.navgationBarTitleTextColor} forState:UIControlStateNormal];
                    [self.rightNavigationBarButtonItem setEnabled:YES];
                }else {
                    [self.rightNavigationBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0],NSForegroundColorAttributeName:[UIColor colorWithRed:149 green:181 blue:231 alpha:0.6]} forState:UIControlStateNormal];
                    [self.rightNavigationBarButtonItem setEnabled:NO];
                }
            }
            break;
        }
        case 1:
            [_phones replaceObjectAtIndex:indexPath.row  withObject:value];
            break;
        default:
            break;
    }
}

#pragma mark - 配置cell
- (void)configureContactTableViewCellWithModel:(id)model cell:(id)cell indexPath:(NSIndexPath *)indexPath {
    __weak MCAddContactViewController *weakSelf = self;
    if ([cell isMemberOfClass:[MCAddContactBaseInfoCell class]]) {
        MCAddContactBaseInfoCell *baseInfoCell = (MCAddContactBaseInfoCell *)cell;
        baseInfoCell.valueTextFieldDelegate = self;
        baseInfoCell.textField.delegate = self;
        baseInfoCell.textField.keyboardType = UIKeyboardTypeDefault;
        baseInfoCell.textField.enabled = YES;
        baseInfoCell.textField.font = [UIFont systemFontOfSize:14.0f];
        baseInfoCell.textField.textColor = [UIColor blackColor];
        if (indexPath.section == 0) {
            if (_contactEditType == editContactInfo) {
                if (_contactModel) {
                    if (_contactModel.isCompanyUser) {
                        if (indexPath.row == 1) {
                            baseInfoCell.textField.enabled = NO;
                        }
                    }
                }
            }
        }
        if (indexPath.section == 1) {
            baseInfoCell.textField.keyboardType = UIKeyboardTypePhonePad;
            if (indexPath.row == _phones.count) {
                baseInfoCell.textField.enabled = NO;
                baseInfoCell.textField.textColor = AppStatus.theme.tintColor;
            }
        }
        if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                baseInfoCell.textField.enabled = NO;
                baseInfoCell.textField.font = [UIFont systemFontOfSize:17.0f];
                baseInfoCell.textField.textColor = [UIColor redColor];
            }
        }
        [baseInfoCell configureCellWithModel:model indexPath:indexPath];
    }
    if ([cell isMemberOfClass:[MCGestureManagerCell class]]) {
        MCGestureManagerCell *settingCell = (MCGestureManagerCell *)cell;
        settingCell.setAddContactSettingBlock = ^(BOOL flag) {
            weakSelf.importantFlag = flag;
        };
        [settingCell configureAddContactCellWithTitle:model importantFlag:_importantFlag];
    }
}

- (void)leftNavigationBarButtonItemAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightNavigationBarButtonItemAction:(id)sender {
    NSString *name = [_baseInfos objectAtIndex:0];
    NSString *emailAddress = [_baseInfos objectAtIndex:1];
    emailAddress = [emailAddress trim];
    if ([emailAddress length] == 0) {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Contact_InputEmailAddress") delegate:nil cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Sure") otherButtonTitles:nil, nil];
        [alertV show];
        return;
    }
    if (![emailAddress isEmail]) {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Login_AccountError") delegate:nil cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Sure") otherButtonTitles:nil, nil];
        [alertV show];
        return;
    }
    /**
     *  备注的电话号码，字符串形式存储
     */
    NSInteger phonesCount = _phones.count;
    while (phonesCount > 0) {
        NSString *phone = [_phones objectAtIndex:phonesCount - 1];
        if ([[phone trim] length] == 0) {
            [_phones removeObjectAtIndex:phonesCount - 1];
        }
        phonesCount --;
    }
    NSString *phoneNumbers = [_phones componentsJoinedByString:@","];
    
    if (_contactEditType == editContactInfo) {
        if (_contactModel) {
            if (![_contactModel.account isEqualToString:emailAddress]) {
                MCContactModel *tempModel = [[MCContactManager sharedInstance] getContactWithEmail:emailAddress];
                if (tempModel) {
                    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Edit_ContactEmailExisted") delegate:nil cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Sure") otherButtonTitles:nil, nil];
                    [alertV show];
                    return;
                }else {
                    //新的邮箱地址，需要把旧的那个缓存中的联系人删除掉
                    [[MCContactManager sharedInstance] deleteCacheContacts:@[_contactModel]];
                }
            }
            _contactModel.notePhoneNumbers = phoneNumbers;
            _contactModel.account = emailAddress;
            _contactModel.deleteFlag = NO;
            if ([[name trim] length] > 0) {
                _contactModel.noteDisplayName = name;
            }
            NSString *displayName = _contactModel.displayName;
            _contactModel.pinyin = [MCContactModel getPinyin:displayName];
            _contactModel.pinyinFirstChar = [MCContactModel getPinYinFirstCharWith:displayName];
            _contactModel.importantFlag = self.importantFlag;
            [[MCContactManager sharedInstance] updateContactWithNoteInfo:_contactModel];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        return;
    }

    MCContactModel *contactModel = [[MCContactManager sharedInstance] getContactWithEmail:emailAddress];
    if (contactModel) {
        if (!contactModel.deleteFlag) {
            //本地已存在该联系人，提示是否更新信息
            __weak MCAddContactViewController *weakSelf = self;
            RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel") action:^{
                
            }];
            RIButtonItem *sureItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Sure") action:^{
                if ([contactModel.notePhoneNumbers length] > 0) {
                    if ([phoneNumbers length] > 0) {
                        contactModel.notePhoneNumbers = [contactModel.notePhoneNumbers stringByAppendingFormat:@",%@", phoneNumbers];
                    }else {
                        contactModel.notePhoneNumbers = phoneNumbers;
                    }
                }else {
                    contactModel.notePhoneNumbers = phoneNumbers;
                }
                NSArray *notePhones = [contactModel.notePhoneNumbers componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
                if (notePhones.count > maxPhonesCanAdd) {
                    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Contact_maxPhonesCanAdd") delegate:nil cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel") otherButtonTitles:nil, nil];
                    [alertV show];
                    return;
                }
                [weakSelf updateContactNoteInfo:contactModel phoneNumbers:phoneNumbers name:name];
                [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Contact_updateContactNoteInfo") cancelButtonItem:cancelItem otherButtonItems:sureItem, nil];
            [alertV show];

        }else {
            contactModel.notePhoneNumbers = nil;
            [self updateContactNoteInfo:contactModel phoneNumbers:phoneNumbers name:name];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        
    }else {
        contactModel = [MCContactModel contactWithEmail:emailAddress emailNickName:emailAddress];
        contactModel.notePhoneNumbers = phoneNumbers;
        contactModel.importantFlag = self.importantFlag;
        contactModel.deleteFlag = NO;
        if ([name length] > 0) {
            contactModel.noteDisplayName = name;
            contactModel.pinyin = [MCContactModel getPinyin:name];
            contactModel.pinyinFirstChar = [MCContactModel getPinYinFirstCharWith:name];
        }
        [[MCContactManager sharedInstance] insertContact:contactModel];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)updateContactNoteInfo:(MCContactModel *)contactModel phoneNumbers:(NSString *)phoneNumbers name:(NSString *)name {
    contactModel.noteDisplayName = nil;
    contactModel.notePhoneNumbers = phoneNumbers;
    if ([name length] > 0) {
        contactModel.noteDisplayName = name;
        contactModel.pinyin = [MCContactModel getPinyin:name];
        contactModel.pinyinFirstChar = [MCContactModel getPinYinFirstCharWith:name];
    }
    contactModel.importantFlag = self.importantFlag;
    contactModel.deleteFlag = NO;
    [[MCContactManager sharedInstance] updateContactWithNoteInfo:contactModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
