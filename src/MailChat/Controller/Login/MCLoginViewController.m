//
//  MCLoginViewController.m
//  NPushMail
//
//  Created by zhang on 2016/11/25.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCLoginViewController.h"
#import "MCImapHelpNoteViewController.h"
#import "MCServerViewController.h"
#import "MCLoginExtensionView.h"
#import "UIAlertView+Blocks.h"
#import "MCAppDelegate.h"
#import "MCLoginManager.h"
#import "MCAppStatus.h"
#import "MCSetAvatorViewController.h"
#import "MCAvatorInviteModel.h"
#import "MCServerAPI+Account.h"
#import "MailCore.h"
#import "MCMailManager.h"
#import "MCIMService.h"
#import "MCAppSetting.h"
#import "MCContactManager.h"
#import "MCIMChatViewController.h"
#import "MCIMConversationManager.h"
#import "MCAccountManager.h"
#import "MCAccountConfig.h"
#import "MCWebViewController.h"
#import "UIAlertView+Blocks.h"
#import "MCLoginQQAuthViewController.h"
#import "UIView+MCExpand.h"
#import "MCGmailLoginViewController.h"

@interface MCLoginViewController ()<MCLoginAuthViewControllerDelegate>

@property (nonatomic,strong)NSString *email;
@property (nonatomic,strong)NSString *passWord;

@end

@implementation MCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)loginAccountEmail:(NSString*)email
                 passWord:(NSString*)passWord
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure {
    
    _email = email;
    _passWord = passWord;
    
    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Login_AccountValidating") maskType:SVProgressHUDMaskTypeClear];
    // 延迟调用，否则的话HUD有时候会显示不出来
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MCLoginManager*loginManager = [MCLoginManager new];
        [loginManager loginWithUserName:email
                               password:passWord
                                success:^(id response) {
                                    if ([email isQQEmail]) {
                                        [MCUmengManager addEventWithKey:mc_qq_loginSuc];
                                    }
                                    if (success) {
                                        success(response);
                                    }
                                } failure:^(NSError *error) {
                                    if (failure) {
                                        failure(error);
                                    }
                                    [SVProgressHUD dismiss];
                                    [self showErrorAlertWithError:error];
                                }];
    });
}
//登录Gmail
- (void)loginGmailEmail:(NSString*)email{
   
    MCGmailLoginViewController *gmailLoginViewController = [[MCGmailLoginViewController alloc]init];
    gmailLoginViewController.delegate = self;
    gmailLoginViewController.email = email;
    [self.navigationController pushViewController:gmailLoginViewController animated:NO];
}

#pragma mark - MCLoginAuthViewControllerDelegate
- (void)authViewController:(UIViewController *)vc didAuthWithAccount:(MCAccount *)account
{
    MCLoginManager *loginManager = [[MCLoginManager alloc] init];
    [loginManager loginWithValidatedAccount:account success:^(id response) {
        [self loadMainViewController];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Login_LoginError")];
    }];
}

- (void)authViewController:(UIViewController *)vc didFailedWithError:(NSError *)error
{
    [vc dismissViewControllerAnimated:YES completion:nil];
    [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Login_LoginError")];
}

#pragma mark - error
//显示错误信息
- (void)showErrorAlertWithError:(NSError*)error
{
    //密码或账号错误
    //TODO: 定义错误码
    if (error.code == MCOErrorAuthentication) {
        [self mcLoginError:error];
    } else {//其他错误
        RIButtonItem *imapButton = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Login_IMAPSetting") action:^{
            MCServerViewController *mcServerController = [[MCServerViewController alloc]initWithEmail:self.email passWord:self.passWord validationComplete:^(MCAccount *accout) {
                [self.loginManager loginWithUserName:accout.email password:accout.password customConfig:accout.config success:^(id response) {
                    [self loginSuccessAcccount:accout];
                } failure:^(NSError *error) {
                    [self mcLoginError:error];
                }];
                
            }];
            [self.navigationController pushViewController:mcServerController animated:YES];
        }];
        
        NSString*message = error.userInfo[MCOIMAPResponseKey];
        UIAlertView*alertView = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Login_AccountValidationFail") message:message cancelButtonItem:[RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Sure")] otherButtonItems:imapButton,nil];
        [alertView show];
    }
}

#pragma mark - Error alert
- (void)alertMessageWithImapButtonItem:(RIButtonItem*)imapButtonItem passWordButton:(RIButtonItem*)passWordButton   alertMessage:(NSString*)alertMessage errorMessage:(NSString*)errorMessage {
    
    if (errorMessage) {
        alertMessage = [alertMessage stringByAppendingString:@"\n"];
        alertMessage = [alertMessage stringByAppendingString:errorMessage];
    }
    UIAlertView*alertView = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Login_LoginError") message:alertMessage cancelButtonItem:[RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Sure")] otherButtonItems:imapButtonItem,passWordButton,nil];
    [alertView show];
    
}

- (void)alertMessageWithImapButtonItem:(RIButtonItem*)imapButtonItem helpButton:(RIButtonItem*)helpButton   alertMessage:(NSString*)alertMessage errorMessage:(NSString*)errorMessage {
    
    if (errorMessage) {
        alertMessage = [alertMessage stringByAppendingString:@"\n"];
        alertMessage = [alertMessage stringByAppendingString:errorMessage];
    }
    UIAlertView*alertView = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Login_LoginError") message:alertMessage cancelButtonItem:helpButton otherButtonItems:imapButtonItem,nil];
    [alertView show];
    
}

- (void)mcLoginError:(NSError*)error {
    
    NSString *message = error.userInfo[MCOIMAPResponseKey];
    //imap Note
    RIButtonItem* imapButtonItem;
    if (self.emailType  == MCMailTypeQQ) {
        imapButtonItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Login_GetQQAuth") action:^{
            [MCUmengManager addEventWithKey:mc_qq_loginAuth];
            MCLoginQQAuthViewController *vc = [[MCLoginQQAuthViewController alloc] initWithEmail:self.email];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }else{
        imapButtonItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Login_IMAPSetting") action:^{
            MCImapHelpNoteViewController *mcImapHelpNoteViewController = [[MCImapHelpNoteViewController alloc]initWithSelectEmailIndex:self.emailType showPassWordNote:NO];
            UINavigationController*navigationController = [[UINavigationController alloc]initWithRootViewController:mcImapHelpNoteViewController];
            [self presentViewController:navigationController animated:YES completion:^{}];
        }];
    }
    
    if (self.emailType == MCMailType163) {
        //授权码note
        RIButtonItem* passWordButton = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Login_NetEasePasswordNote") action:^{
            
            MCImapHelpNoteViewController *mcImapHelpNoteViewController = [[MCImapHelpNoteViewController alloc]initWithSelectEmailIndex:self.emailType showPassWordNote:YES];
            UINavigationController*navigationController = [[UINavigationController alloc]initWithRootViewController:mcImapHelpNoteViewController];
            [self presentViewController:navigationController animated:YES completion:^{}];
            
        }];
        [self alertMessageWithImapButtonItem:imapButtonItem helpButton:passWordButton alertMessage:PMLocalizedStringWithKey(@"PM_Login_LoginNetEastNoteWithIndependentPassword") errorMessage:message];
        
    } else if (self.emailType == MCMailTypeQQ) {
        
        RIButtonItem *helpBtn =  [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Login_HelperName") action:^{
            [self connectHelp];
            
        }];
        [self alertMessageWithImapButtonItem:imapButtonItem helpButton:helpBtn alertMessage:PMLocalizedStringWithKey(@"PM_Login_LoginNoteWithIndependentPassword") errorMessage:message];
        
    } else if (self.emailType == MCMailTypeSina) {
        [self alertMessageWithImapButtonItem:imapButtonItem passWordButton:nil alertMessage:PMLocalizedStringWithKey(@"PM_Login_LoginErrorNote") errorMessage:message];
    } else {
        [self alertMessageWithImapButtonItem:nil passWordButton:nil alertMessage:PMLocalizedStringWithKey(@"PM_Login_Login35NoteWithIndependentPassword") errorMessage:message];
    }
}

//help
- (void)connectHelp
{
    [self.view endEditing:YES];
    [self.loginManager loginAnonymousUserIfNeeded];
    
    //友盟统计
    if (self.emailType == MCMailTypeQQ) {
        [MCUmengManager addEventWithKey:mc_login_helper attributes:@{@"qq" : @"helper"}];
    }else [MCUmengManager addEventWithKey:mc_login_helper attributes:@{@"qq" : @"other"} ];
    
    MCContactModel *helperContact = [[MCContactManager sharedInstance] helperContact];
    MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForContact:helperContact];
    MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
