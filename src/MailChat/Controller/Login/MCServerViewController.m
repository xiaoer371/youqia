//
//  MCSerVerViewController.m
//  NPushMail
//
//  Created by zhang on 16/1/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

const static CGFloat kMCSerVerSettingCellHight          = 42.0;
const static CGFloat kMCSerVerSettingTitleLabelFontSize = 14.0;
const static CGFloat kMCSerVerSettingTitleLabelWidth    = 68.0;
//const static CGFloat kMCSerVerSettingSSLSwichWidth      = 51.0;
//const static CGFloat kMCSerVerSettingSSLSwichHight      = 31.0;
const static CGFloat kMCSerVerSettingCellLeftSpace      = 17.0;
const static CGFloat kMCSerVerSettingContentTextFieldX  = 100.0;
static NSString *const kMCSerVerViewSettingCellId       = @"kMCSerVerViewSettingCellId";

#import "MCServerViewController.h"
#import "MCMailConfigManager.h"
#import "MCLoginManager.h"
#import "NSString+Extension.h"
#import "MailCore.h"
#import "MCAccountManager.h"
#import "MCMailProviderPool.h"
#import "MCCheckBoxView.h"
#import "MCPopoverView.h"

@interface MCSerVerSettingCell ()<MCCheckBoxViewDelegate>
@property (nonatomic,strong) UILabel     *titleLable;
@property (nonatomic,strong) UITextField *contentTextField;
@property (nonatomic,strong) UISwitch    *sslSwitch;
@property (nonatomic,strong) MCCheckBoxView   *checkBoxView;
@property (nonatomic,copy)void (^switchCallback)(NSInteger index);
@end

@implementation MCSerVerSettingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _titleLable = [[UILabel alloc]initWithFrame:CGRectMake(kMCSerVerSettingCellLeftSpace, 0, kMCSerVerSettingTitleLabelWidth, self.contentView.frame.size.height)];
        _titleLable.font = [UIFont systemFontOfSize:kMCSerVerSettingTitleLabelFontSize];
        [self addSubview:_titleLable];
        
        _contentTextField = [[UITextField alloc]initWithFrame:CGRectMake(kMCSerVerSettingContentTextFieldX, 0, ScreenWidth - kMCSerVerSettingContentTextFieldX -kMCSerVerSettingCellLeftSpace, _titleLable.frame.size.height)];
        _contentTextField.font = [UIFont systemFontOfSize:kMCSerVerSettingTitleLabelFontSize];
        _contentTextField.returnKeyType = UIReturnKeyNext;
        _contentTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self addSubview:_contentTextField];
        
//        _sslSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(ScreenWidth - kMCSerVerSettingCellLeftSpace - kMCSerVerSettingSSLSwichWidth, (self.contentView.frame.size.height - kMCSerVerSettingSSLSwichHight)/2, kMCSerVerSettingSSLSwichWidth, kMCSerVerSettingSSLSwichHight)];
//        [_sslSwitch addTarget:self action:@selector(switchChangValue:) forControlEvents:UIControlEventValueChanged];
//        _sslSwitch.hidden = YES;
//        [self addSubview:_sslSwitch];
        
        
        _checkBoxView =[[MCCheckBoxView alloc] initWithFrame:CGRectMake(kMCSerVerSettingContentTextFieldX, 0, ScreenWidth - kMCSerVerSettingContentTextFieldX -kMCSerVerSettingCellLeftSpace, self.contentView.frame.size.height) Titles:@[@"SSL/TLS",@"STARTTLS",@"None"]];
        _checkBoxView.delegate = self;
        [self addSubview:_checkBoxView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    
    return self;
}
//action
- (void)setShowSSLSwitch:(BOOL)showSSLSwitch{
    
    self.sslSwitch.hidden = !showSSLSwitch;
    self.contentTextField.hidden = showSSLSwitch;
}
//callback
//- (void)switchChangValue:(UISwitch*)sender{
//    
//    self.switchCallback(sender.on);
//}

- (void)didSelect:(MCCheckBoxView*)checkBoxView  index:(NSInteger)index
{
     self.switchCallback(index);
}

@end

#pragma mark - MCSerVerViewController

@interface MCServerViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong)UITableView  *mcTableView;
@property (nonatomic,strong)NSArray      *titles;
@property (nonatomic,strong)MCAccount    *mcAccount;
//验证成功回调
@property (nonatomic,copy) validationBlock validationComplete;
@property (nonatomic, assign) CGFloat  angle;
@property (nonatomic, strong) NSString *imapHostName;
@property (nonatomic, strong) NSString *smtpHostName;

@end

@implementation MCServerViewController

- (id)initWithAccount:(MCAccount*)account {
    if (self = [super init]) {
        _mcAccount = [[MCAccount alloc] init];
        _mcAccount.email = [account.email copy];
        _mcAccount.password = [account.password copy];
        _mcAccount.authType = account.authType;
        _mcAccount.authData = [account.authData copy];
        _mcAccount.type = account.type;
        _mcAccount.config = [account.config copy];
        _imapHostName = _mcAccount.config.imap.hostName;
        _smtpHostName = _mcAccount.config.smtp.hostName;
        [self.mcTableView reloadData];
    }
    return self;
}

- (id)initWithEmail:(NSString *)email passWord:(NSString *)passWord validationComplete:(validationBlock)validationComplete {
    
    if (self = [super init]) {
       _validationComplete = validationComplete;
        _mcAccount = [MCAccount new];
        _mcAccount.email = email;
        _mcAccount.password = passWord;
        _mcAccount.config = [MCMailConfigManager defaultConfigForMail:email ssl:NO];
        _imapHostName = _mcAccount.config.imap.hostName;
        _smtpHostName = _mcAccount.config.smtp.hostName;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Login_ServerSetting");
    self.rightNavigationBarButtonItem.title = PMLocalizedStringWithKey(@"PM_Common_Complite");
    [self.mcTableView reloadData];
    //键盘通知
    [self registerNotification];
}

- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (UITableView*)mcTableView {
    
    if (!_mcTableView) {
        _mcTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT)];
        _mcTableView.delegate   = self;
        _mcTableView.dataSource = self;
        _mcTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
        line.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        _mcTableView.tableFooterView     = line;
        _mcTableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
        _mcTableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_mcTableView];
    }
    return _mcTableView;
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titles.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray*array = self.titles[section];
    return array.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCSerVerSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kMCSerVerViewSettingCellId];
    if (!cell) {
        cell = [[MCSerVerSettingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMCSerVerViewSettingCellId];
    }
    NSArray*array = self.titles[indexPath.section];
    cell.titleLable.text = array[indexPath.row];
    cell.contentTextField.delegate = self;
    cell.contentTextField.enabled = YES;
    MCMailConfigItem *configItem = indexPath.section == 0?self.mcAccount.config.imap:self.mcAccount.config.smtp;
    switch (indexPath.row) {
        case 0:{
            cell.contentTextField.text = configItem.hostName;
        } break;
        case 1:{
            cell.contentTextField.text = self.mcAccount.email;
            cell.contentTextField.enabled = NO;
        } break;
        case 2:{
            cell.contentTextField.text = self.mcAccount.password;
            cell.contentTextField.secureTextEntry = YES;
        } break;
        case 3:{
            NSString *sslStr;
            if (configItem.ssl == MCMailEncryptSSL) {
                cell.checkBoxView.selectIndex = 0;
            }else if ( configItem.ssl == MCMailEncryptTLS)
            {
                cell.checkBoxView.selectIndex = 1;
            }else {
                cell.checkBoxView.selectIndex = 2;
            }
            cell.contentTextField.text = sslStr;
        } break;
        case 4:{
            cell.contentTextField.text = [NSString stringWithFormat:@"%ld",(long)configItem.port];
        }
            break;
    }
    
    cell.checkBoxView.hidden = indexPath.row == 3?NO:YES;
    cell.contentTextField.hidden =indexPath.row == 3?YES:NO;
    cell.contentTextField.secureTextEntry = indexPath.row == 2?YES:NO;
    cell.switchCallback = ^(NSInteger index){
        MCSerVerSettingCell*weakCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:indexPath.section]];
        
        if (indexPath.section == 0) {
             weakCell.contentTextField.text = index == 0?@"993":@"143";
        }else{
            if (index == 0) {
                weakCell.contentTextField.text = @"465";
            }else  weakCell.contentTextField.text = index == 1?@"587":@"25";
        }
        configItem.port = [weakCell.contentTextField.text integerValue];
        if (index ==0 ) {
            configItem.ssl  = MCMailEncryptSSL;
        }else configItem.ssl  = index ==1? MCMailEncryptTLS:MCMailEncryptNone;
    };
    
    return cell;
}
//delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kMCSerVerSettingCellHight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 27.0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *sectionHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 27)];
    sectionHeadView.backgroundColor = [UIColor colorWithHexString:@"f7f7f9"];
    UILabel*titleLable = [[UILabel alloc]initWithFrame:CGRectMake(17, 0, 200, 27)];
    titleLable.font = [UIFont systemFontOfSize:12.0];
    titleLable.text = section ==0?PMLocalizedStringWithKey(@"PM_ServerSetting_imap"):PMLocalizedStringWithKey(@"PM_ServerSetting_smtp");
    [sectionHeadView addSubview:titleLable];
    if (section == 1) {
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
        line.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [sectionHeadView addSubview:line];
    }
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, sectionHeadView.frame.size.height - 0.5, ScreenWidth, 0.5)];
    line.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
    [sectionHeadView addSubview:line];
    
    return sectionHeadView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section ==1) {
        return 50.0f;
    }
    return 0.0f;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
{
    if (section ==1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 50.0f)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(16, 2, 280, 24)];
        label1.text = PMLocalizedStringWithKey(@"PM_SmartServer_title");
        [view addSubview:label1];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(ScreenWidth- 70, 2, 60, 30);
        MCMailConfigItem *imap = self.mcAccount.config.imap;
        MCMailConfigItem *smtp = self.mcAccount.config.smtp;
        NSString *btnTitle;
        if ([imap.hostName isEqualToString:@"35.mailchat.cn"]&&[smtp.hostName isEqualToString:@"35.mailchat.cn"]) {
            btnTitle = PMLocalizedStringWithKey(@"PM_SmartServer_itemA");
        }else if ([imap.hostName isEqualToString:@"w.cn4e.com"]&&[smtp.hostName isEqualToString:@"w.cn4e.com"]){
            btnTitle =  PMLocalizedStringWithKey(@"PM_SmartServer_itemB");
        }else{
            btnTitle = PMLocalizedStringWithKey(@"PM_Login_EventClose");
        }
        [btn setTitle:btnTitle forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        btn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [btn setTitleColor:AppStatus.theme.fontTintColor forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"mc_mailListNote.png"] forState:UIControlStateNormal];
        self.angle = M_PI;
        btn.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        
        btn.titleEdgeInsets = UIEdgeInsetsMake(0,-(btn.currentBackgroundImage.size.width),
                                          0,
                                          (btn.currentBackgroundImage.size.width ));
        
        btn.imageEdgeInsets =UIEdgeInsetsMake(0,
                                          (btn.titleLabel.frame.size.width)+20,
                                          0,
                                          0);
        
        [btn addTarget:self action:@selector(selectServer:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        
        
        CGFloat y = CGRectGetMaxY(label1.frame) + 2;
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(16, y, 280, 20)];
        label2.text = PMLocalizedStringWithKey(@"PM_SmartServer_subTitle");
        label2.font = [UIFont systemFontOfSize:14.0f];
        label2.textColor = AppStatus.theme.fontTintColor;
        [view addSubview:label2];
        
        
        return view;
    }
    return nil;

}
- (void)selectServer:(UIButton *)sender
{
    
    [self arrowAnimation:sender];
    
    CGFloat y = (CGRectGetMaxY(sender.superview.frame));
    __block MCServerViewController *weak = self;
    CGPoint point = CGPointMake(CGRectGetMaxX(sender.frame),y);
    MCPopoverView *mcPopverView = [MCPopoverView new];
    NSArray *titles = @[PMLocalizedStringWithKey(@"PM_SmartServer_itemA"),PMLocalizedStringWithKey(@"PM_SmartServer_itemB"),PMLocalizedStringWithKey(@"PM_Login_EventClose")];
    mcPopverView.menuTitles = titles;
    mcPopverView.dissmissCallBack = ^{
        
        [weak arrowAnimation:sender];
    };
    
    [mcPopverView showFromPoint:point popoverViewStyle:MCPopoverViewStyleDown  selected:^(NSInteger index) {
        
        if (index ==0) {
            self.mcAccount.config.imap.hostName = @"35.mailchat.cn";
            self.mcAccount.config.smtp.hostName = @"35.mailchat.cn";
        }else if (index ==1){
            self.mcAccount.config.imap.hostName = @"w.cn4e.com";
            self.mcAccount.config.smtp.hostName = @"w.cn4e.com";
        }else{
            self.mcAccount.config.imap.hostName = self.imapHostName;
            self.mcAccount.config.smtp.hostName = self.smtpHostName;
        }
        [self arrowAnimation:sender];
        [self.mcTableView reloadData];
    }];
}

- (void)arrowAnimation:(UIButton *)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        sender.imageView.transform = CGAffineTransformMakeRotation(self.angle==M_PI?0:M_PI);
    } completion:^(BOOL finished) {
        if (self.angle != 0) {
            self.angle = 0;
        } else {
            self.angle = M_PI;
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat sectionHeaderHeight = 40;
    //固定section 随着cell滚动而滚动
    if (scrollView.contentOffset.y <= sectionHeaderHeight&&scrollView.contentOffset.y >= 0) {
        scrollView.contentInset = UIEdgeInsetsMake(- scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(- sectionHeaderHeight, 0, 0, 0);
    }
}


#pragma mark KeyBoardShowOrHide

- (void)keyboardWillShow:(NSNotification*)info {
    
    NSValue *keyboardEndBounds = [[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect  endRect = [keyboardEndBounds CGRectValue];
    CGFloat keyBoardHeight = CGRectGetHeight(endRect);
    CGRect  rect = self.mcTableView.frame;
    rect.size.height = ScreenHeigth - NAVIGATIONBARHIGHT - keyBoardHeight;
    self.mcTableView.frame = rect;
}
- (void)keyboardWillHide:(NSNotification*)info {
    
    CGRect rect = self.mcTableView.frame;
    rect.size.height = ScreenHeigth - NAVIGATIONBARHIGHT ;
    self.mcTableView.frame = rect;
}

#pragma mark UITextFiledDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    MCSerVerSettingCell*cell = EGOVersion_iOS8 ?(MCSerVerSettingCell*)textField.superview:(MCSerVerSettingCell*)textField.superview.superview;
    NSIndexPath*indexPath = [self.mcTableView indexPathForCell:cell];
    
    if ([string isEqualToString:@"\n"]) {
        
        if (indexPath.row < 3) {
            NSIndexPath*ind = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            
            cell = [self.mcTableView cellForRowAtIndexPath:ind];
            
            [cell.contentTextField becomeFirstResponder];
        } else {
            [cell.contentTextField resignFirstResponder];
        }
        
        return NO;
    }
    NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    MCMailConfigItem *configItem = indexPath.section == 0?self.mcAccount.config.imap:self.mcAccount.config.smtp;
    switch (indexPath.row) {
        case 0:{
            configItem.hostName = updatedString;
        } break;
        case 1:{
            self.mcAccount.email = updatedString;
        } break;
        case 2:{
            self.mcAccount.password = updatedString;
            cell.contentTextField.secureTextEntry = YES;
        } break;
        case 3:{
            configItem.port = [updatedString integerValue];
        } break;
    }
    
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    _mcAccount.password = @"";
    return YES;
}
//titles

- (NSArray*)titles {
    if (!_titles) {
        _titles = @[@[PMLocalizedStringWithKey(@"PM_ServerSetting_Server"),
                      PMLocalizedStringWithKey(@"PM_ServerSetting_Account"),
                      PMLocalizedStringWithKey(@"PM_ServerSetting_password"),
                      @"SSL",PMLocalizedStringWithKey(@"PM_ServerSetting_Port")],
                    @[PMLocalizedStringWithKey(@"PM_ServerSetting_Server"),
                      PMLocalizedStringWithKey(@"PM_ServerSetting_Account"),
                      PMLocalizedStringWithKey(@"PM_ServerSetting_password"),
                      @"SSL",PMLocalizedStringWithKey(@"PM_ServerSetting_Port")]];
    }
    return _titles;
}

//验证
- (void)rightNavigationBarButtonItemAction:(id)sender {
   
   [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Login_AccountValidating") maskType:SVProgressHUDMaskTypeClear];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id<MCMailProviderProtocol> provider = [MCMailProviderPool createProviderWithAccount:self.mcAccount];
        [provider loginSuccess:^{
            if (_validationComplete) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:NO];
                    _validationComplete(self.mcAccount);
                });
            } else {
                MCLoginManager *loginMgr = [[MCLoginManager alloc] init];
                [loginMgr updateAccountInfo:self.mcAccount success:^(MCAccount *updatedAccount) {
                    // 刷新已有provider 的验证信息
                    id<MCMailProviderProtocol> localProvider = [[MCMailProviderPool shared] providerForAccount:updatedAccount];
                    [localProvider refreshAuthentication];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showSuccessWithStatus:PMLocalizedStringWithKey(@"PM_Login_AccountSuccess")];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    });
                } failure:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Login_SMTPSettingError")];
                    });
                }];
                
            }
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.code == MCOErrorAuthentication) {
                      [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Login_Login35NoteWithIndependentPassword")];
                    //账号或密码错误
                } else {
                    //服务器配置错误
                        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Login_SMTPSettingError")];
                }
            });
        }];
    });
}

- (void)leftNavigationBarButtonItemAction:(id)sender {
    
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
