//
//  MCMailDetailViewController.m
//  NPushMail
//
//  Created by zhang on 15/12/23.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCMailDetailViewController.h"
#import "MCMailDetailWebView.h"
#import "MCMailDetailHeadView.h"
#import "MCMailToolBar.h"
#import "MCMailAttachListView.h"
#import "MCMailComposerViewController.h"
#import "MCAttachPreviewViewcontroller.h"
#import "NSString+Extension.h"
#import "MCBaseNavigationViewController.h"
#import "MCMailMoveViewController.h"
#import "MCMailSearchViewController.h"
#import "MCContactInfoViewController.h"
#import "MCWebViewController.h"
#import "UIAlertView+Blocks.h"
#import "UIActionSheet+Blocks.h"
#import "MCIMConversationManager.h"
#import "MCIMChatViewController.h"
#import "MCPopoverView.h"
#import "MCSelectedContactsRootViewController.h"
#import "MCIMGroupManager.h"
#import "MCFeaturesGuideHelper.h"
#import "MCAppSetting.h"
#import "MCModelConversion.h"
#import "MCAdjustFontSizeView.h"
#import "MCRepealView.h"
#import "MCMailBoxManager.h"
#import "UIView+MCExpand.h"
@interface MCMailDetailViewController ()<MCMailDetailHeadViewDelegate,MCMailToolBarDelegate,MCMailAttachListViewDelegate,MCMailToolBarDelegate,UIWebViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) MCMailDetailHeadView *mailDetailHeadView;
@property (nonatomic,strong) MCMailAttachListView *mailAttachListView;
@property (nonatomic,strong) MCMailDetailWebView  *mailDetailWebView;
@property (nonatomic,strong) MCMailToolBar        *mailToolBar;
//dataSource
@property (nonatomic,strong) NSArray  *attachments;
@property (nonatomic,strong) NSArray  *inlineAttachments;
@property (nonatomic,strong) NSArray  *toArray;
@property (nonatomic,strong) NSArray  *ccArray;
@property (nonatomic,strong) NSArray  *fromArray;
@property (nonatomic,strong) NSMutableArray  *toAndCcContacts;

@property (nonatomic,strong) UIButton *attachCountView;
@property (nonatomic,strong) UILabel  *attachCountLabel;
@property (nonatomic,strong) MCMailManager *mailManager;
@property (nonatomic,assign) MCHandelMailSet handelSet;
@property (nonatomic,weak)id <MCMailDetailViewControllerDelegate> delegate;

@property (nonatomic,strong)MCRepealView *repealView;

@end

@implementation MCMailDetailViewController

- (id)initWithMail:(MCMailModel *)mailModel manager:(MCMailManager *)mailManager delegate:(id)delegate{
    
    if (self = [super init]) {
        _mailManager = mailManager;
        _mailModel = mailModel;
        _mailModel.attachments = [_mailManager getAttachmentsWithMailId:mailModel.uid];
        _mailModel.inlineAttachments = [_mailManager getInlineAttachmetsWithMailId:mailModel.uid];
        _delegate = delegate;
        
     }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_repealView) {
        [_repealView dismiss];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadViews];
    [self loadMailContent];
    [self addWeightForContactWithMail:self.mailModel];
}

- (void)loadViews{
    
    self.navBarTitleLable.text = self.mailModel.from.name;
    self.currentUserLable.text = self.mailModel.from.email;
    [self.view addSubview:self.mailDetailWebView];
    [self.view addSubview:self.mailToolBar];
    //上一封下一封按钮
    NSMutableArray *items = [NSMutableArray new];
    for (int i = 0 ; i < 2; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*40,0, 30, 40);
        button.tag = i + 100;
        [button addTarget:self action:@selector(upOrDownMails:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:i==0?@"mc_mailReaderUp.png":@"mc_mailReaderDown.png"] forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
        [items insertObject:item atIndex:0];
    }
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -5;
    [items insertObject:negativeSpacer atIndex:0];
    [items insertObject:negativeSpacer atIndex:2];
    self.navigationItem.rightBarButtonItems = items;
    self.navigationBarTitleView.mc_width = kMCBaseViewNavBarTitleViewWidth;
    self.currentUserLable.mc_width = kMCBaseViewNavBarTitleViewWidth;
    self.navBarTitleLable.mc_width = kMCBaseViewNavBarTitleViewWidth;
    self.navigationItem.titleView = nil;
    self.navigationItem.titleView = self.navigationBarTitleView;
}

- (MCRepealView*)repealView {
    if (!_repealView) {
       _repealView = [MCRepealView shared];
    }
    return _repealView;
}

- (void)loadMailContent{
    //read
    NSString*path = [[NSBundle mainBundle] pathForResource:@"read" ofType:@"html"] ;
    NSString*readHtml = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    if (_mailModel.messageContentHtml) {
        [self.mailDetailWebView loadHTMLString:[NSString stringWithFormat:readHtml,_mailModel.messageContentHtml] baseURL:nil];
    } else {
        [self.mailDetailWebView loading];
        __block typeof(self)weakSelf = self;
        [self.mailManager loadMailContent:_mailModel inFolder:self.mailbox urgent:YES success:^(id response) {
            [weakSelf.mailDetailWebView stopLoading];
           if ([response isKindOfClass:[MCMailModel class]]) {
               [self reloadMail:response];
           } else {
               [self loadMailContent];
           }
        } failure:^(NSError *error){
          [weakSelf.mailDetailWebView stopLoading];
        }];
    }
}

- (void)reloadMail:(MCMailModel*)mail {
    self.mailModel = mail;
    [self.mailDetailHeadView reloadView];
    [self.mailToolBar resetBacklogItemView];
    self.mailDetailHeadView.mail = mail;
    self.mailDetailWebView.headerView = self.mailDetailHeadView;
    [self loadMailContent];
    if (mail.hasAttachment && mail.attachments.count > 0) {
        self.mailAttachListView.mailAttachments = mail.attachments;
        self.mailDetailWebView.footerView = self.mailAttachListView;
         self.attachCountView.hidden = NO;
        self.attachCountLabel.text = [NSString stringWithFormat:@"%ld",(long)mail.attachments.count];
    } else {
        self.mailDetailWebView.footerView = nil;
        if (_attachCountView) {
           self.attachCountView.hidden = YES;
        }
    }
    self.navBarTitleLable.text = mail.from.name;
    self.currentUserLable.text = mail.from.email;
}

#pragma mark - views
//views
- (MCMailDetailHeadView*)mailDetailHeadView{
    
    if (!_mailDetailHeadView) {
        _mailDetailHeadView = [[MCMailDetailHeadView alloc]initWithMail:self.mailModel setDelegate:self];
    }
    return _mailDetailHeadView;
}

- (MCMailDetailWebView*)mailDetailWebView
{
    if (!_mailDetailWebView) {
        _mailDetailWebView = [[MCMailDetailWebView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth- NAVIGATIONBARHIGHT - self.mailToolBar.frame.size.height)];
        _mailDetailWebView.backgroundColor = [UIColor whiteColor];
        _mailDetailWebView.delegate = self;
        _mailDetailWebView.scalesPageToFit = YES;
        _mailDetailWebView.scrollView.delegate = self;
        _mailDetailWebView.headerView = self.mailDetailHeadView;
        _mailDetailWebView.scalesPageToFit = YES;
        if (_mailModel.hasAttachment) {
            _mailDetailWebView.footerView = self.mailAttachListView;
        }
    }
    return _mailDetailWebView;
}

- (MCMailAttachListView*)mailAttachListView{
    
    if (!_mailAttachListView) {
        _mailAttachListView = [[MCMailAttachListView alloc]initWithMCMailAttachment:_mailModel.attachments];
        _mailAttachListView.delegate = self;
    }
    return _mailAttachListView;
}

- (MCMailToolBar*)mailToolBar{
    
    if (!_mailToolBar) {
        _mailToolBar = [[MCMailToolBar alloc]initWithDelegate:self];
        _mailToolBar.mailBox = self.mailbox;
    }
    return _mailToolBar;
}

#pragma mark - 上下封翻页阅读
- (void)upOrDownMails:(UIButton*)button {
    
    MCMailModel *mail = nil;
    if ([self.delegate respondsToSelector:@selector(mailDetailViewReadOtherFromMail:toNext:)]) {
       mail = [self.delegate mailDetailViewReadOtherFromMail:self.mailModel toNext:button.tag == 101?YES:NO];
    }
    if (!mail) {
        return;
    }
    mail.attachments = [_mailManager getAttachmentsWithMailId:mail.uid];
    mail.inlineAttachments = [_mailManager getInlineAttachmetsWithMailId:mail.uid];
    MCMailBoxManager*boxManager = [MCMailBoxManager new];
    MCMailBox *box = [boxManager getMailBoxWithAccount:self.mailbox.accountId path:mail.folder];
    self.mailbox = box;
    //标记已读
    if ([_delegate respondsToSelector:@selector(mailDetailViewHandleMail:setRead:)]) {
        if (!mail.isRead) {
            [_delegate mailDetailViewHandleMail:self.mailModel setRead:YES];
        }
    }
    [self reloadMail:mail];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%@';", AppSettings.mailAdjust];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
    
    __weak UIWebView *weakWebView = webView;
    [self.mailManager loadInlineAttachment:_mailModel.inlineAttachments success:^(id response) {
        //WebView必须用weak，不然在下载完成之前退出，更新内嵌资源的时候会崩溃
        NSString*jsString = (NSString*)response;
        [weakWebView stringByEvaluatingJavaScriptFromString:jsString];
    } failure:nil];
    
//    [webView stringByEvaluatingJavaScriptFromString:@"resizeTables();"];
    //TODO:处理有cid 的非内嵌图片
    if (_mailModel.inlineAttachments.count > 0) {
        for (MCMailAttachment *attachment in _mailModel.inlineAttachments) {
            NSRange mcRange = [_mailModel.messageContentHtml rangeOfString:[NSString stringWithFormat:@"cid:%@",attachment.cid]];
            if (mcRange.location == NSNotFound) {
                DDLogDebug(@"----发现有cid的非内嵌附件----");
                //TODO:作为非内嵌附件处理
                NSMutableArray *attachments = [NSMutableArray new];
                [attachments addObject:attachment];
                [attachments addObjectsFromArray:_mailModel.attachments];
                _mailModel.attachments = attachments;
                self.mailAttachListView = nil;
                self.mailDetailWebView.footerView = self.mailAttachListView;
                //更新attachment
                [self.mailManager updataAttachmentInfo:attachment mail:_mailModel];
            }
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = [request URL];
        NSString *linkStr =[[[NSString stringWithFormat:@"%@",url] componentsSeparatedByString:@":"] lastObject];
        if ([linkStr isEmail]){
            
            MCContactModel *contactModel = [[MCContactManager sharedInstance]getOrCreateContactWithEmail:linkStr name:linkStr];
            [MCUmengManager addEventWithKey:mc_contact_info_write];
            MCContactInfoViewController *contactInfoViewController = [[MCContactInfoViewController alloc]initFromType:fromReadMail contactModel:contactModel canEditable:YES isEnterprise:contactModel.isCompanyUser];
            [self.navigationController pushViewController:contactInfoViewController animated:YES];
            
        } else if ([linkStr isPhone]||[linkStr validateMobile]){
            NSString *phoneNumber = [[[NSString stringWithFormat:@"%@",url] componentsSeparatedByString:@":"] lastObject];
            RIButtonItem *doButtonItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_PhoneCall") action:^{
               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber]]];
            }];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:phoneNumber message:nil cancelButtonItem:[RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel") ] otherButtonItems:doButtonItem, nil];
            [alertView show];
            
        } else {
            MCWebViewController *webController = [[MCWebViewController alloc] initWithUrl:url];
            [self.navigationController pushViewController:webController animated:YES];
        }
        return NO;
    }
    return YES;
}

#pragma mark - MCMailDetailHeadViewDelegate

- (void)mailDetailHeadView:(MCMailDetailHeadView*)mailDetailHeadView didSelectContact:(MCContactModel*)contactModel{
    MCContactInfoViewController *mCContactInfoViewController = [[MCContactInfoViewController alloc]initFromType:fromReadMail contactModel:contactModel canEditable:YES isEnterprise:contactModel.isCompanyUser];
    [self.navigationController pushViewController:mCContactInfoViewController animated:YES];
}

- (void)maildetailHeadView:(MCMailDetailHeadView*)mailDetailHeadView didChangeFrame:(CGFloat)height{
    
    [self.mailDetailWebView headerViewHeightChange:height animated:YES];
}

- (void)maildetailHeadView:(MCMailDetailHeadView*)mailDetailHeadView didTouchAttachShow:(BOOL)show{
    
    CGPoint offset = CGPointMake(0, _mailDetailWebView.scrollView.contentSize.height - _mailDetailWebView.frame.size.height + _mailAttachListView.frame.size.height);
    if (offset.y <= 0) {
        return;
    }
    [_mailDetailWebView.scrollView setContentOffset:offset animated:YES];
}

- (void)maildetailHeadView:(MCMailDetailHeadView *)mailDetailHeadView contactDataFrom:(NSArray *)from to:(NSArray *)to cc:(NSArray *)cc {
    
    self.fromArray = from;
    self.toArray   = to;
    self.ccArray   = cc;
}
#pragma mark - MCMailToolBarDelegate

- (void)mailToolBar:(MCMailToolBar *)mailToolBar mCHandelMailSet:(MCHandelMailSet)mCHandelMailSet{
    _handelSet = mCHandelMailSet;
    switch (mCHandelMailSet) {
        case MCHandelMailSetToMessage:{
            //TODO:make chat
            MCMailAddress *chatAddress;
            if (_mailbox.type == MCMailFolderTypeSent) {
                [self sendMessagesInsendedMail];
                return;
            }else{
                if (_fromArray.count > 0) {
                    chatAddress = [_fromArray firstObject];
                }
                if (self.toAndCcContacts.count == 1 ) {
                    if (chatAddress.email) {
                        [self makeChatWithMailAddress:chatAddress];
                    }
                    return;
                }
            }
            RIButtonItem *singleChatItem;
            UIActionSheet *actionSheet;
            RIButtonItem *gropChatItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_GroupChat") action:^{
                [self makeGropChat:NO];
            }];
            RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
            // TODO: 发件人不存在的情况
            if (chatAddress.name) {
               singleChatItem = [RIButtonItem itemWithLabel:chatAddress.name action:^{
                    [self makeChatWithMailAddress:chatAddress];
                }];
                actionSheet  = [[UIActionSheet alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Msg_AddChats") cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:singleChatItem,gropChatItem, nil];
            }else{
                actionSheet  = [[UIActionSheet alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Msg_AddChats") cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:gropChatItem, nil];
            }
           
            [actionSheet showInView:self.view];
        }
            break;
        case MCHandelMailSetToReAll:{
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_detail_reall];
            [self composerWithMail:self.mailModel composerType:MCMailComposerReplyAll];
        }
            break;
        case MCHandelMailSetToReSingle:{
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_detail_re];
            [self composerWithMail:self.mailModel composerType:MCMailComposerReplySingle];
        }
            break;
        case MCHandelMailSetToForward:{
            
            if (self.mailModel.hasAttachment) {
                
                RIButtonItem *attachItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_ForwardWithAtt") action:^{
                    //友盟事件统计
                    [MCUmengManager addEventWithKey:mc_mail_detail_re_att];
                    
                    [self composerWithMail:self.mailModel composerType:MCMailComposerForward];
                }];
                RIButtonItem *unAttachItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_ForwardWithOutAtt") action:^{
                    //友盟事件统计
                    [MCUmengManager addEventWithKey:mc_mail_detail_re_noatt];
                    
                    [self composerWithMail:self.mailModel composerType:MCMailComposerForwardWithoutAttachment];
                }];
                RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
                
                UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Mail_EditOptionForward") cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:attachItem,unAttachItem, nil];
                [actionSheet showInView:self.view];
                
            } else {
                //友盟事件统计
                [MCUmengManager addEventWithKey:mc_mail_detail_forward];
                
                [self composerWithMail:self.mailModel composerType:MCMailComposerForward];
            }
        }
            break;
        case MCHandelMailSetMove:{
            
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_detail_more_move];
            
            MCMailMoveViewController *mailMoveViewController = [[MCMailMoveViewController alloc]initWithCurrentMailBox:_mailbox manager:self.mailManager moveComplete:^(MCMailBox *boxModel) {
                if ([_delegate respondsToSelector:@selector(mailDetailViewHandleMail:from:moveTo:)]) {
                    [_delegate mailDetailViewHandleMail:self.mailModel from:self.mailbox moveTo:boxModel];
                }
            }];
            mailMoveViewController.selectBoxCallBack = ^{
                [self popAnimated:NO];
            };
            MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:mailMoveViewController];
            [self presentViewController:navigationController animated:YES completion:nil];
        }
            break;
        case MCHandelMailSetDelete:{
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_detail_more_delete];
             [self popAnimated:YES];
            self.navigationController.delegate = self;
        }
            break;
        case MCHandelMailSetUnRead :{
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_detail_more_read];
            [self popAnimated:YES];
        }
            break;
        case MCHandelMailToEditAgain : {
            [self composerWithMail:self.mailModel composerType:MCMailComposerFromDraft];
        }
            break;
        case MCHandelMailToMarkBacklog:{
            if ([self.delegate respondsToSelector:@selector(mailDetailViewHandleMail:tag:mark:)]) {
                BOOL backlog = self.mailModel.tags&MCMailTagBacklog;
                if (!backlog) {
                    self.repealView.message = PMLocalizedStringWithKey(@"PM_Mail_BacklogSmartNote");
                    self.repealView.doItemTitle = @"";
                    [self.repealView showWithUndoBlock:^{} commitBlock:^{}];
                }
                [self.delegate mailDetailViewHandleMail:self.mailModel tag:MCMailTagBacklog mark:!backlog];
                [MCUmengManager backlogEvent:backlog?mc_mail_backlog_detailBacklog:mc_mail_backlog_detailUnBacklog];
            }
        }
            break;
        case MCHandelMailToMarkVip: {
            if ([self.delegate respondsToSelector:@selector(mailDetailViewHandleMail:tag:mark:)]) {
                [self.delegate mailDetailViewHandleMail:self.mailModel tag:MCMailTagImportant mark:!(self.mailModel.tags&MCMailTagImportant)];
            }
        }
            break;
        case MCHandelMailAdjustFont: {
            __weak typeof(self)weakSelf = self;
            [MCAdjustFontSizeView ShowWithValue:[AppSettings.mailAdjust percentString] adjustFontBlock:^(NSString *fontSize) {
                NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%@';", fontSize];
                [weakSelf.mailDetailWebView stringByEvaluatingJavaScriptFromString:jsString];
            }];
        }
           break;
        default:
            break;
    }
}

- (MCMailTags)toMarkTags {
   return  self.mailModel.tags;
}
#pragma mark - MCMailToChat 
- (void)sendMessagesInsendedMail {
    
    if (self.toAndCcContacts.count == 1) {
        MCMailAddress *address = self.toAndCcContacts[0];
        [self makeChatWithMailAddress:address];
    } else {
        [self makeGropChat:YES];
    }
}

- (void)makeChatWithMailAddress:(MCMailAddress *)address
{
    //友盟事件统计
    [MCUmengManager addEventWithKey:mc_mail_detail_im_single];
    
    MCContactModel *contactModel =[[MCContactManager sharedInstance] getOrCreateContactWithEmail:address.email name:address.name];
    MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForContact:contactModel];
    MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)makeGropChat:(BOOL)isInsend
{
    //友盟事件统计
    [MCUmengManager addEventWithKey:mc_mail_detail_im_group];
    
    NSMutableArray *array =[self getContactsWithToCc:NO];
    __weak MCMailDetailViewController *weakSelf = self;
    MCSelectedContactsRootViewController *selectedContactsViewCottroller = [[MCSelectedContactsRootViewController alloc]initWithSelectedModelsBlock:^(id models) {
        
        NSArray*contacts = (NSArray*)models;
        NSSet *set = [NSSet setWithArray:contacts];
        NSMutableArray *allArray = [NSMutableArray arrayWithArray:set.allObjects];
        if (allArray.count < 2) {
            for ( MCContactModel *contactModel  in allArray) {
                if ([contactModel.account isEqualToString:AppStatus.currentUser.email]) {
                     if (allArray.count < 3) {
                         [SVProgressHUD showSuccessWithStatus:PMLocalizedStringWithKey(@"PM_IMChat_memberLack")];
                         return ;
                     }
                }
            }
            [SVProgressHUD showSuccessWithStatus:PMLocalizedStringWithKey(@"PM_IMChat_memberLack")];
            return ;
        }
        [self creatNewGroup:allArray];
        
    } selectedMsgGroupModelBlock:^(id model) {
        MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForGroup:model];
        MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    } formCtrlType:SelectedContactFromMailSendMsgs alreadyExistsModels:array];
    
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:selectedContactsViewCottroller];
    [weakSelf presentViewController:navigationController animated:YES completion:nil];
}

//TODO:聊天
- (void)creatNewGroup:(NSArray*)contacts
{
    //友盟事件统计
    [MCUmengManager addEventWithKey: mc_mail_detail_im_group];
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_GroupCreating")];
    MCIMGroupManager *groupManager =[MCIMGroupManager shared];
    [groupManager createGroupWithGroupName:nil members:contacts success:^(id response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MCIMGroupModel *group = (MCIMGroupModel* )response;
            MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForGroup:group];
            MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
            [weakSelf.navigationController pushViewController:vc animated:YES];
            [SVProgressHUD dismiss];
        });
    } failure:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Msg_GroupCreatErr")];
    }];
}

- (NSMutableArray *)getContactsWithToCc:(BOOL)isInsend
{
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (MCMailAddress *address in self.toAndCcContacts) {
        
        if ([address.email isEqualToString:AppStatus.currentUser.email]) {
            continue;
        }
        MCContactModel *contactModel =[[MCContactManager sharedInstance] getOrCreateContactWithEmail:address.email name:address.email];
        if (contactModel) {
            [tempArr addObject:contactModel];
        }
    }
    if (isInsend == NO) {
        MCMailAddress *chatAddress;
        if (_fromArray.count > 0) {
            chatAddress = [_fromArray firstObject];
            if (chatAddress.email) {
                MCContactModel *contactModel =[[MCContactManager sharedInstance] getOrCreateContactWithEmail:chatAddress.email name:chatAddress.email];
                [tempArr addObject:contactModel];
            }
           
        }
    }
    
    NSSet *set = [NSSet setWithArray:tempArr];
    NSMutableArray *array = [NSMutableArray arrayWithArray:set.allObjects];
    return array;
}
//抄送人与收件人
- (NSMutableArray*)toAndCcContacts
{
    if (!_toAndCcContacts){
        _toAndCcContacts = [[NSMutableArray alloc] initWithCapacity:0];
        [_toAndCcContacts addObjectsFromArray:self.toArray];
        [_toAndCcContacts addObjectsFromArray:self.ccArray];
    }
    return _toAndCcContacts;
}

#pragma mark - MCMailAttchListViewDelegate
- (void)mailAttachListView:(MCMailAttachListView*)mailAttachListView didSelectAttach:(MCMailAttachment*)mailAttachment{

    MCAttachPreviewViewcontroller * attachmentPreview = [[MCAttachPreviewViewcontroller alloc]initWithFile:mailAttachment manager:self.mailManager fileSourceFrom:MCFileSourceFromMail];
    [self.navigationController pushViewController:attachmentPreview animated:YES];
}

//TODO:写信
- (void)composerWithMail:(MCMailModel*)mail
            composerType:(MCMailComposerOptionType)composerType {
    
    MCMailComposerViewController *mailComposerViewController = [[MCMailComposerViewController alloc]initWithMail:mail mailComposerOptionType:composerType];
    mailComposerViewController.mailManager = self.mailManager;
    [self.navigationController pushViewController:mailComposerViewController animated:YES];
}

//TOOD:attach show
- (UIButton*)attachCountView {
    if (!_attachCountView &&self.mailModel.hasAttachment) {
        UIImage *image = [UIImage imageNamed:@"attachment.png"];
        _attachCountView = [UIButton buttonWithType:UIButtonTypeCustom];
        _attachCountView.frame = CGRectMake(ScreenWidth - 20 - image.size.width, ScreenHeigth - TOOLBAR_HEIGHT - NAVIGATIONBARHIGHT - image.size.height - 20, image.size.width, image.size.height);
        [_attachCountView addTarget:self action:@selector(goToAttachListView:) forControlEvents:UIControlEventTouchUpInside];
        [_attachCountView setImage:image forState:UIControlStateNormal];
        [self.view addSubview:_attachCountView];
        _attachCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(image.size.width - 12, image.size.height - 12, 12, 12)];
        _attachCountLabel.backgroundColor = [UIColor clearColor];
        _attachCountLabel.textAlignment = NSTextAlignmentCenter;
        _attachCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_mailModel.attachments.count];
        _attachCountLabel.font = [UIFont fontWithName:@"Helvetica" size:9];
        _attachCountLabel.textColor = AppStatus.theme.titleTextColor;
        [_attachCountView addSubview:_attachCountLabel];
    }
    return _attachCountView;
}
//TODO:mcShowAttachmentList
- (void)goToAttachListView:(UIButton*)sender {
    
    CGPoint offset = CGPointMake(0, _mailDetailWebView.scrollView.contentSize.height - _mailDetailWebView.frame.size.height + _mailAttachListView.frame.size.height);
    [_mailDetailWebView.scrollView setContentOffset:offset animated:YES];
}
#pragma mark -UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_repealView) {
        [_repealView dismiss];
    }
    
    if (scrollView.frame.size.height == scrollView.contentSize.height) {
        dispatch_async(dispatch_get_main_queue(), ^{
           self.attachCountView.hidden = YES;
        });
    } else {
        CGFloat height = scrollView.frame.size.height;
        CGFloat contetYoffset = scrollView.contentOffset.y + 40;
        CGFloat contentSizeHeght = scrollView.contentSize.height;
        CGFloat didtaceFromAttachList = contentSizeHeght - contetYoffset;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!_mailModel.hasAttachment || self.mailModel.attachments.count == 0) {
                return ;
            }
            if (didtaceFromAttachList < height) {
                self.attachCountView.hidden = YES;
            } else {
                self.attachCountView.hidden = NO;
            }
        });
    }
}

//TODO:添加联系人权重
- (void)addWeightForContactWithMail:(MCMailModel*)mail {
    if (!mail.from.email) {
        return;
    }
    MCContactModel *contact = [MCModelConversion contactModelWithMailAddress:mail.from];
    [[MCContactManager sharedInstance] addWeight:1 toContact:contact];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([_delegate respondsToSelector:@selector(mailDetailViewHandleMail:from:moveTo:)]) {
        [_delegate mailDetailViewHandleMail:self.mailModel from:self.mailbox moveTo:nil];
    }
     navigationController.delegate = nil;
}

//prative
- (void)popAnimated:(BOOL)animated {
    [self.navigationController popViewControllerAnimated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_handelSet != MCHandelMailSetMove && _handelSet != MCHandelMailSetDelete) {
        if (_handelSet == MCHandelMailSetUnRead) {
            if ([_delegate respondsToSelector:@selector(mailDetailViewHandleMail:setRead:)]) {
                [_delegate mailDetailViewHandleMail:_mailModel setRead:NO];
            }
        } else if (!_mailModel.isRead) {
            if ([_delegate respondsToSelector:@selector(mailDetailViewHandleMail:setRead:)]) {
                [_delegate mailDetailViewHandleMail:_mailModel setRead:YES];
            }
        }
    }
}
@end
