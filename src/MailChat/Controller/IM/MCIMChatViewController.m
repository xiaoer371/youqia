//
//  MCIMChatViewController.m
//  NPushMail
//
//  Created by swhl on 16/2/24.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatViewController.h"
#import "UIView+MCExpand.h"
#import "MCIMChatInputView.h"
#import "MCChatViewCell.h"
#import "MCIMModel.h"
#import "MCIMChatInfoViewController.h"
#import "MCContactInfoViewController.h"
#import "MCContactManager.h"
#import "MCIMConversationModel.h"
#import "MCIMModel.h"
#import "MCIMMessageManager.h"
#import "MCIMMessageSender.h"
#import "MJRefresh.h"
#import "MCIMChatViewModel.h"
#import "MCWebViewController.h"
#import "MCFileManager.h"
#import "MCFileBaseModel.h"
#import "MCIMChatNoticeCell.h"
#import "MCIMChatVoicePlayer.h"
#import "MCIMChatFileManager.h"
#import "UIImageView+WebCache.h"
#import "MCIMChatForwordViewController.h"
#import "MCAttachPreviewViewcontroller.h"
#import "HZPhotoBrowser.h"
#import "MCIMMessageManager.h"
#import "MCNotificationCenter.h"
#import "MCIMConversationManager.h"
#import "MCIMMoreMsgAlertView.h"
#import "MCIMGroupModel.h"
#import "MCIMLatestView.h"
#import "MCMailComposerViewController.h"



@interface MCIMChatViewController ()<MCIMChatInputViewDelegate,UITableViewDelegate,UIActionSheetDelegate,HZPhotoBrowserDelegate,MCIMMoreMsgAlertViewDelegate,MCIMLatestViewDelegate>
{
    CGFloat lastContentOffset;
    MCIMMessageManager *_imMessageManager;
    dispatch_queue_t  _messageQueue;
    NSUInteger  _number;
}

@property (nonatomic, strong) UITableView    *tableView;
@property (nonatomic, strong) MCIMChatInputView    *chatInputView;
@property (nonatomic, assign) CGFloat previousTextViewContentHeight;
@property (nonatomic, strong) MCIMConversationModel    *conversationModel;
@property (nonatomic, strong) MCIMChatViewModel    *viewModel;
@property (nonatomic, strong) NSDictionary *selectedLinkDic;
@property (nonatomic, weak) id notificationObj;
@property (nonatomic, strong) MCIMMoreMsgAlertView    *moreMsgAlertView;

@property (nonatomic, strong) MCIMLatestView    *latestView;


@end

@implementation MCIMChatViewController

-(void)dealloc
{
    [[MCIMChatVoicePlayer sharedInstance] stopSound];
  
    self.conversationModel.isChatting = NO;
    [self.chatInputView  removeObserver:self forKeyPath:@"frame"];
    if (self.notificationObj) {
         [[NSNotificationCenter defaultCenter] removeObserver:self.notificationObj];
    }
}

#pragma mark - Lifecycle

- (instancetype)initWithConversationModel:(MCIMConversationModel*)conversationModel
{
    self = [super init];
    if (self) {
        self.conversationModel = conversationModel;
        self.conversationModel.isChatting = YES;
        self.isCurrentVC = YES;
        _number = 0;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _messageQueue = dispatch_queue_create("MCIMChat.com", NULL);

    [self _initSubViews];
    self.navBarTitleLable.text = self.conversationModel.peer.peerName;
    if (self.conversationModel.type == MailChatConversationTypeGroup) {
        self.currentUserLable.text = @"";
        self.currentUserLable.frame = CGRectZero;
        [self.navBarTitleLable moveoffSetY:6.0f];
        
    }else{
        self.currentUserLable.text = self.conversationModel.peerId;
    }
    _viewModel =[[MCIMChatViewModel alloc] initWithConversation:self.conversationModel  tableView:self.tableView];
    _viewModel.moreMsgAlertView = self.moreMsgAlertView;
    [self.tableView reloadData];
    //滑到底部
    [self scrollToBottomAnimated:YES];
    
    __weak typeof(self) weakSelf = self;
    self.notificationObj = [[NSNotificationCenter defaultCenter] addObserverForName:MCNotificationDidKickedOut object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @synchronized (weakSelf) {
            //被踢出群
            NSArray *array = (NSArray*) note.object;
            MCIMGroupModel *group = array [0];
            NSString *email = array[1];
            if([group.groupId isEqualToString:weakSelf.conversationModel.peerId] && [email isEqualToString:AppStatus.currentUser.email]){
                
                UIViewController *vc = [weakSelf.navigationController.viewControllers lastObject];
                if (vc.presentedViewController) {
                    [vc.presentedViewController dismissViewControllerAnimated:YES completion:nil];
                }
                [weakSelf.navigationController.navigationBar setBackgroundImage:AppStatus.theme.navbarBgImage
                                                               forBarMetrics:UIBarMetricsDefault];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isCurrentVC = YES;
    self.navBarTitleLable.text = self.conversationModel.peer.peerName;
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.isCurrentVC = NO;
    if ([_chatInputView.inputTextView.text trim].length >0  || self.conversationModel.draft.length >0) {
        self.conversationModel.draft = _chatInputView.inputTextView.text;
        [[MCIMConversationManager shared] updateConversation:self.conversationModel];
    }
}

- (void)clearMessagesAche
{
    [_viewModel.msgList removeAllObjects];
    [self.tableView reloadData];
    [self resignResponderModifyFrame];
}

#pragma mark - init SubViews
-(void)_initSubViews
{
    self.view.exclusiveTouch = YES;
    [self.rightNavigationBarButtonItem setImage:AppStatus.theme.chatStyle.chatNavRightImage];
    
    [self.view addSubview:self.tableView];
    [self addTableViewRefreshHeader];
    
    [self.view addSubview:self.chatInputView];
    self.previousTextViewContentHeight = 36;
    
    [self.chatInputView addObserver:self
                         forKeyPath:@"frame"
                            options:NSKeyValueObservingOptionOld
                            context:nil];
    
    self.chatInputView.inputTextView.text = self.conversationModel.draft.length>0?self.conversationModel.draft:@"";
}

-(void)addTableViewRefreshHeader
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadHistoryData方法）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadHistoryData)];

    header.arrowView.hidden = YES;
    header.arrowView.image = nil;
    
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;

    // 设置刷新控件
    self.tableView.header = header;
}
-(void)loadHistoryData
{
    __weak typeof(MCIMChatViewModel*) weakSelf = _viewModel;
    dispatch_async(_messageQueue, ^{
        NSInteger currentCount = [weakSelf.msgList count];
        [weakSelf loadMoreData];
        
        NSInteger newCount = [weakSelf.msgList count];
        if (newCount ==currentCount) {
            [self.tableView.header endRefreshing];
            return ;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.msgList count]==0) return;
            [self.tableView reloadData];
            NSIndexPath *indexPath =[NSIndexPath indexPathForRow:[weakSelf.msgList count] - currentCount inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        });
    });
    [self.tableView.header endRefreshing];
}


#pragma mark -KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (object == self.chatInputView && [keyPath isEqualToString:@"frame"]) {
        
        if (self.tableView.contentSize.height <= self.tableView.frame.size.height) {
            DDLogVerbose(@"frame changed");
            //CGRect rect = self.tableView.frame;
            UIView *view = (UIView *)object;
            DDLogVerbose(@"Frame : %@",NSStringFromCGRect(view.frame));
            CGFloat offset = self.tableView.frame.size.height - view.frame.origin.y;
            DDLogVerbose(@"offset y : %f", offset);
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, offset, 0);
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
        }else{
            self.tableView.scrollIndicatorInsets =UIEdgeInsetsMake(0, 0, 0, 0);
            self.tableView.contentInset= UIEdgeInsetsMake(0, 0, 0, 0);
            [UIView animateWithDuration:0.25 animations:^{
                [self.tableView moveToY:-(ScreenHeigth - _chatInputView.frame.origin.y- _chatInputView.frame.size.height -64)];
            }];

        }
        [self scrollToBottomAnimated:YES];
    }
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCIMMessageModel *msg = (MCIMMessageModel *)[_viewModel.msgList objectAtIndex:indexPath.row];
    
    if (msg.cellHeight > 0) {
        return msg.cellHeight;
    }
    
    if (msg.type == IMMessageTypeNotice) {
        msg.cellHeight =  [MCIMChatNoticeCell  cellHeightWithMessageModel:msg showTime:NO];
        return msg.cellHeight;
    }
    
    msg.cellHeight = [MCChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MCIMMessageModel *)msg isShowTime: msg.isShowTime?:[_viewModel showTimeLabel:indexPath]];
    return msg.cellHeight;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self resignResponderModifyFrame];
    _latestView.hidden = YES;
}

-(void)resignResponderModifyFrame
{
    [self reFrameWithInputView];
    [self.chatInputView dismissKeyboardWithscrollSelectItem];
}

- (void)reFrameWithInputView
{
    [self.chatInputView.inputTextView resignFirstResponder];
    CGFloat a = CGRectGetMaxY(self.chatInputView.frame);
    if (a + NAVIGATIONBARHIGHT == ScreenHeigth ) {
        return;
    }
    [UIView animateWithDuration:0.32 animations:^{
        CGRect rect = self.chatInputView.frame;
        CGFloat inputHeight = CGRectGetHeight(self.chatInputView.frame);
        rect.origin.y = ScreenHeigth-inputHeight-64;
        self.chatInputView.frame = rect;
    }];
}

#pragma mark - MCIMChatInputViewDelegate
- (void)inputTextHiddenKeyboard:(MCChatTextView *)inputTextView
{
    [self resignResponderModifyFrame];
    _latestView.hidden = YES;
}

- (void)didSelectMoreButtonActtion:(BOOL)hidden;
{
    if (hidden ==NO) {
        if (!_latestView) {
            [self.view addSubview:self.latestView];
        }else {
            [_latestView isShowLatestImage];
        }
    }else
    {
        _latestView.hidden =YES;
    }
}

//小助手账号的话，添加一键发送日志。
- (BOOL)iSHelperAccount
{
    if ([self.conversationModel.peerId isEqualToString:kMailChatHelper]||[self.conversationModel.peerId isEqualToString:kMailChatHelperAndroid]) {
        return YES;
    }else return NO;
}

- (void)sendLogToHelper
{
    //发送日志文件
    MCFileBaseModel *fileModel = [[MCFileCore sharedInstance] saveFileInDbWithModel:@"log"];
    [[MCIMMessageSender shared] sendFileWithModel:fileModel fileName:fileModel.displayName toConversation:self.conversationModel success:nil failure:nil];
}

//text
-(void)chatInputView:(MCIMChatInputView*)chatInputView
         sendMessage:(NSString *)messageStr
{
    [self addContactWeights];
    chatInputView.inputTextView.text = @"";
    [[MCIMMessageSender shared] sendText:messageStr toConversation:self.conversationModel success:nil failure:nil];
}
//images
- (void)chatInputView:(MCIMChatInputView *)chatInputView
         sendPictures:(NSArray *)images
{
    [self addContactWeights];
    for (UIImage *image in images) {
        [[MCIMMessageSender shared] sendImage:image toConversation:self.conversationModel success:nil failure:nil];
    }
}
//files
- (void)chatInputView:(MCIMChatInputView *)chatInputView
            sendFiles:(NSArray *)files
{
    [self addContactWeights];
    //友盟统计
    [MCUmengManager addEventWithKey:mc_im_sendfile];
    for (MCFileBaseModel *file in files) {
        [[MCIMMessageSender shared] sendFileWithModel:file fileName:file.displayName toConversation:self.conversationModel success:nil failure:nil];
    }
}

//voice
- (void)chatInputView:(MCIMChatInputView *)chatInputView
            sendVoice:(NSData *)voice
                 time:(NSInteger)second
                 name:(NSString*)voiceName
{
    [self addContactWeights];
    //友盟统计
    [MCUmengManager addEventWithKey:mc_im_sendvoice];
    [[MCIMMessageSender shared] sendVoiceWithData:voice seconds:second name:voiceName toConversation:self.conversationModel success:nil failure:nil];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if ([self.tableView numberOfSections] > 0) {
        NSInteger lastSectionIndex = [self.tableView numberOfSections] - 1;
        NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex] - 1;
        if (lastRowIndex &&lastRowIndex > 0) {
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
            [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition: UITableViewScrollPositionBottom animated:animated];
        }
    }
    self.moreMsgAlertView.hidden = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ((floor (scrollView.contentOffset.y)+_tableView.contentInset.bottom) >= (ceil(scrollView.contentSize.height) - scrollView.frame.size.height-30)) {
        
        self.moreMsgAlertView.hidden = YES;
    }
}

#pragma mark - UIResponder actions
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    DDLogVerbose(@"eventName ---%@",eventName);
   MCIMMessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]||[eventName isEqualToString:kRouterEventTextNumTapEventName])
    {
         [self resignResponderModifyFrame];
        NSMutableDictionary *linkDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
        [linkDictionary setObject:eventName forKey:@"eventName"];
        [linkDictionary setObject:userInfo[@"link"] forKey:@"link"];
        self.selectedLinkDic = linkDictionary;
        [self loadUrlOrCallphoneNum:eventName withLinkDic:linkDictionary];

    }else if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName])
    {
        [self.viewModel.controlImageSources removeAllObjects];
        self.viewModel.controlImageSources =nil;
        UIImageView *imageView = userInfo[@"imgView"];
        HZPhotoBrowser *browserVc = [[HZPhotoBrowser alloc] init];
        browserVc.sourceImagesContainerView = imageView;
        browserVc.imageCount = self.viewModel.controlImageSources.count; // 图片总数
        NSInteger index =[self.viewModel.controlImageSources indexOfObject:model];
        browserVc.currentImageIndex = index ==NSNotFound?0:index;
        browserVc.delegate = self;
        [browserVc show];
    }
    else if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName])
    {
        //语音
        model.isRead = YES;
        MCIMMessageManager *messageManager =[[MCIMMessageManager alloc] init];
        [messageManager updateMessage:model];
    }
    else if ([eventName isEqualToString:kRouterEventFileBubbleTapEventName])
    {
        //文件
        MCAttachPreviewViewcontroller *vc =[[MCAttachPreviewViewcontroller alloc] initWithFile:model manager:nil fileSourceFrom:MCFileSourceFromChat];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([eventName isEqualToString:kRouterEventChatHeadImageTapEventName])
    {
        //查看联系人
        if ([model.from isEmail]) {
            [self goToContactInfoWithModel:model];
      }
    }
    else if([eventName isEqualToString:kResendButtonTapEventName])
    {
        //重发
        [self.viewModel deleteMessageModel:model];
        [[MCIMMessageSender shared] resendMessage:model toConversation:self.conversationModel success:^{
        } failure:^(NSError *error) {
        }];
        self.moreMsgAlertView.hidden = YES;
    }
    else if([eventName isEqualToString:kRouterEventChatCellForwordEvent])
    {
         [self resignResponderModifyFrame];
        MCIMChatForwordViewController *vc =[[MCIMChatForwordViewController alloc] initWithMessageModel:model];
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([eventName isEqualToString:kRouterEventChatCellDeleteEvent])
    {
        [self.viewModel deleteMessageModel:model];
    }else if([eventName isEqualToString:kRouterEventAudioBubblePlayNext]){
        [self playNextUnreadVoice:model];
    }else{
        
    }
}

#pragma mark HZPhotoBrowserDelegate
- (UIImage *)photoBrowser:(HZPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    if (self.viewModel.controlImageSources.count >index &&index>=0) {
        MCIMImageModel *messageModel = self.viewModel.controlImageSources[index];
        if (messageModel.thumbnailImg) {
            return messageModel.thumbnailImg;
        }else{
            UIImageView *imageView = (UIImageView *)browser.sourceImagesContainerView;
            return imageView.image;
        }
    }
    return nil;
   
}
- (NSURL *)photoBrowser:(HZPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    if (self.viewModel.controlImageSources.count >index &&index>=0) {
        MCIMImageModel *messageModel = self.viewModel.controlImageSources[index];
        
        NSURL *localUrl = [NSURL URLWithString:messageModel.localPath];
        if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:localUrl]) {
            return localUrl;
        }
        return [NSURL URLWithString:messageModel.path];
    }
    return nil;
}
- (BOOL)photoBrowser:(HZPhotoBrowser *)browser deleteImageForIndex:(NSInteger)index
{
    browser.imageCount -=1;
    [self.viewModel.controlImageSources removeObjectAtIndex:index];
    if (self.viewModel.controlImageSources.count>0) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - Bubble Actions
//文本处理
-(void)loadUrlOrCallphoneNum:(NSString *)eventName withLinkDic:(NSDictionary*)LinkDic
{
  
    NSString *openTypeString;
    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        
        NSURL *url  =self.selectedLinkDic[@"link"];
        NSString *urlStr = url.absoluteString;
        NSArray *urlStrs =[urlStr componentsSeparatedByString:@":"]; // mailto:email
        if ([urlStr isEmail] || [[urlStrs lastObject] isEmail]) {
            openTypeString = PMLocalizedStringWithKey(@"PM_Contact_WriteMail");
        }else openTypeString = PMLocalizedStringWithKey(@"PM_Message_LoadURL");
        
    } else if ([eventName isEqualToString:kRouterEventTextNumTapEventName]) {
        openTypeString =PMLocalizedStringWithKey(@"PM_Message_CallTel");
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:PMLocalizedStringWithKey(@"PM_Message_CopyText") ,openTypeString, nil];
    [sheet showInView:self.view];
}

 //查看联系人
-(void)goToContactInfoWithModel:(MCIMMessageModel*)model
{
    MCContactModel *contactModel = [[MCContactManager sharedInstance] getOrCreateContactWithEmail:model.from name:model.from];
    if (contactModel.deleteFlag) {
        [[[UIAlertView alloc] initWithTitle:nil message:PMLocalizedStringWithKey(@"PM_Contact_DeleteOrNot") delegate:nil cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Sure") otherButtonTitles:nil, nil] show];
        return;
    }
    MCContactInfoViewController *vc = [[MCContactInfoViewController alloc] initFromType:fromChat contactModel:contactModel canEditable:NO isEnterprise:NO];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!self.selectedLinkDic) {
        return;
    }
    switch (buttonIndex)
    {
        case 0:
        {
            NSString *str;
            if ([self.selectedLinkDic[@"eventName"] isEqualToString:kRouterEventTextURLTapEventName]) {
                NSURL *url  =self.selectedLinkDic[@"link"];
                str= [url.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            } else if ([self.selectedLinkDic[@"eventName"] isEqualToString:kRouterEventTextNumTapEventName]) {
                str = self.selectedLinkDic[@"link"];
            }
            [UIPasteboard generalPasteboard].string =str;
            break;
        }
        case 1:
        {
            
            if ([self.selectedLinkDic[@"eventName"] isEqualToString:kRouterEventTextURLTapEventName]) {
                NSURL *url  =self.selectedLinkDic[@"link"];
                [self openURL:url.absoluteString];
            } else if ([self.selectedLinkDic[@"eventName"] isEqualToString:kRouterEventTextNumTapEventName]) {
                [self callTel:[NSString stringWithFormat:@"tel://%@",self.selectedLinkDic[@"link"]]];
            }
            break;
        }
    }
}

#pragma mark - Text:phone/link。
-(void)openURL:(NSString  *)urlStr
{
    NSArray *urlStrs =[urlStr componentsSeparatedByString:@":"]; // urlStr maybe --> mailto:email
    NSString *emailStr = [urlStr isEmail]?urlStr:[urlStrs lastObject];
    if ([emailStr isEmail]) {
        MCContactModel *contactModel = [[MCContactManager sharedInstance]getOrCreateContactWithEmail:emailStr name:emailStr];
        MCMailComposerViewController*composerViewController = [[MCMailComposerViewController alloc]initWithContent:contactModel composerType:MCMailComposerNew];
        self.isCurrentVC = NO;
        [self.navigationController pushViewController:composerViewController animated:YES];
        
    }else{
        MCWebViewController *webController = [[MCWebViewController alloc] initWithUrl:[NSURL URLWithString:urlStr]];
        [self.navigationController pushViewController:webController animated:YES];
    }
}

//打电话
-(void)callTel:(NSString *)tel
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat inputY =CGRectGetMaxY(self.chatInputView.frame);
    if (ScreenHeigth != inputY+64) {
        [self resignResponderModifyFrame];
    }
}

#pragma mark - MCIMChatInputViewDelegate
-(void)layoutAndAnimateMessageInputTextView:(UITextView*)textView
{
    CGFloat maxHeight = [MCIMChatInputView  maxHeight];
    CGFloat contentH = [self getTextViewContentH:textView];
    BOOL isShrinking = contentH < self.previousTextViewContentHeight;
    CGFloat changeInHeight = contentH - _previousTextViewContentHeight;
    if (!isShrinking && (self.previousTextViewContentHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^{
//                             [self setTableViewInsetsWithBottomValue:self.tableView.contentInset.bottom + changeInHeight];
//                 4014            [self scrollToBottomAnimated:NO];
                             if (isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.previousTextViewContentHeight = MIN(contentH, maxHeight);
                                 }
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [_chatInputView adjustTextViewHeightBy:changeInHeight];
                             }
                             CGRect inputViewFrame = _chatInputView.frame;
                             _chatInputView.frame = CGRectMake(0.0f,inputViewFrame.origin.y - changeInHeight,
                                                        inputViewFrame.size.width,
                                                        inputViewFrame.size.height + changeInHeight);
                             if (!isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.previousTextViewContentHeight = MIN(contentH, maxHeight);
                                 }
                                 // growing the view, animate the text view frame AFTER input view frame
                                 [_chatInputView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        self.previousTextViewContentHeight = MIN(contentH, maxHeight);
    }
    // Once we reached the max height, we have to consider the bottom offset for the text view.
    // To make visible the last line, again we have to set the content offset.
    if (self.previousTextViewContentHeight == maxHeight) {
        CGPoint bottomOffset = CGPointMake(0.0f, contentH - textView.bounds.size.height);
        [textView setContentOffset:bottomOffset animated:NO];
    }
}

- (CGFloat)getTextViewContentH:(UITextView *)textView {
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        return ceilf([textView sizeThatFits:textView.frame.size].height);
//    } else {
        return textView.contentSize.height;
//    }
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.bottom = bottom;
    return insets;
}

//输入框刚好开始编辑
- (void)inputTextViewDidBeginEditing:(MCChatTextView *)inputTextView{
    //动态设置输入框大小
    if (!self.previousTextViewContentHeight)
        self.previousTextViewContentHeight = [self getTextViewContentH:inputTextView];
}

#pragma mark - SubViews
-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, ScreenWidth, ScreenHeigth-64-50) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor colorWithHexString:@"eeeff2"];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableView:)];
        [_tableView addGestureRecognizer:tapGesture];
    }
    return _tableView;
}

-(MCIMChatInputView *)chatInputView
{
    if (!_chatInputView) {
        _chatInputView = [[MCIMChatInputView alloc] initWithViewControll:self];
        _chatInputView.delegate = self;
    }
    return _chatInputView;
}

- (MCIMMoreMsgAlertView *)moreMsgAlertView
{
    if (!_moreMsgAlertView) {
        _moreMsgAlertView = [[MCIMMoreMsgAlertView alloc] initWithNumString:@"0"];
        _moreMsgAlertView.delegate = self;
        _moreMsgAlertView.hidden = YES;
        [self.view addSubview:_moreMsgAlertView];
    }
    return _moreMsgAlertView;
}

- (MCIMLatestView *)latestView
{
    if (!_latestView) {
        CGFloat h = CGRectGetHeight(self.chatInputView.frame);
        //y的值  一个是moreview的高103，一个103是本身的高 64是导航栏的高 h 是输入框的高  距离边框5  距离输入框2
        _latestView = [[MCIMLatestView alloc] initWithOrigin:CGPointMake(ScreenWidth-64-5,ScreenHeigth-h-2*103-64 -2)];
        _latestView.delegate = self;
    }
    return _latestView;
}

#pragma mark - MCIMLatestViewDelegate
- (void)selectLastImage:(UIImage *)image
{
    [self addContactWeights];
    [[MCIMMessageSender shared] sendImage:image toConversation:self.conversationModel success:^{
            [self scrollToBottomAnimated:YES];
        } failure:^(NSError *error) {
    }];
}

#pragma mark - MCIMMoreMsgAlertViewDelegate
- (void) lookNewMessages
{
    [self scrollToBottomAnimated:YES];
}

#pragma mark - RightItemAction

-(void)rightNavigationBarButtonItemAction:(id)sender
{
    if (!EGOVersion_iOS8) {
        [self resignResponderModifyFrame];
    }
    
    MCIMChatInfoViewController *vc = [[MCIMChatInfoViewController alloc] initWithConversation:self.conversationModel];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - contact/  联系人权重
- (void)addContactWeights
{
    if (_number == 0) {
        if (self.conversationModel.type  ==  MailChatConversationTypeSingle /*单聊*/) {
            MCContactModel *contactModel = [[MCContactManager sharedInstance] getOrCreateContactWithEmail:self.conversationModel.peerId name:self.conversationModel.peerId];
            [[MCContactManager sharedInstance] addWeight:kMailChatContactWeightChat toContact:contactModel];;
        }
        _number =1;
    }
}

- (void)tapTableView:(id)sender
{
    [self.view endEditing:YES];
    [self resignResponderModifyFrame];
    _latestView.hidden = YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (EGOVersion_iOS7) {
        if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            return YES;
        }
    }
    if ([touch.view isKindOfClass:[UITableView class]]) {
        return YES;
    }
    return  NO;
}

#pragma mark - playNextUnreadVoice
- (void)playNextUnreadVoice:(MCIMMessageModel *)model
{
    NSInteger index = [_viewModel.msgList indexOfObject:model];
    index += 1;
    if (index < _viewModel.msgList.count) {
        MCIMMessageModel *model = [_viewModel.msgList objectAtIndex:index];
        if (!model) return;
        if (model.type == IMMessageTypeVoice && model.isRead ==NO) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            MCChatViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if ([cell.bubbleView isKindOfClass:[MCIMChatVoiceBubbleView class]]) {
                MCIMChatVoiceBubbleView *voiceBubbleView = (MCIMChatVoiceBubbleView* )cell.bubbleView;
                [voiceBubbleView bubbleViewPressed:nil];
            }else{
                MCIMVoiceModel *voiceModel = (MCIMVoiceModel *)model;
                if(!voiceModel.data){
                    voiceModel.data = [MCIMChatFileManager wavDataWithFileName:voiceModel.localPath];
                }
                if (voiceModel.data) {
                    voiceModel.isRead = YES;
                    [[MCIMChatVoicePlayer sharedInstance] playSongWithData:voiceModel.data];
                }
            }
        }
    }
}

- (void)stopRecording
{
    [self.chatInputView recordButtonTouchUpOutside];
}

#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
