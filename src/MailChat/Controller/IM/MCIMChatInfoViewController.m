//
//  MCIMChatInfoViewController.m
//  NPushMail
//
//  Created by swhl on 16/3/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatInfoViewController.h"
#import "MCMessageViewController.h"
#import "MCIMChatSwitchView.h"
#import "MCIMChatContactView.h"
#import "MCIMChatContactCellModel.h"
#import "MCIMConversationModel.h"
#import "MCContactInfoViewController.h"
#import "MCContactManager.h"
#import "MCSelectedContactsRootViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCIMGroupModel.h"
#import "MCIMGroupManager.h"
#import "MCIMChatModifyGroupViewController.h"
#import "MCIMChatMemberViewController.h"
#import "MCIMGroupManager.h"
#import "MCIMSetGroupNameView.h"
#import "MCIMChatViewController.h"
#import "MCIMConversationManager.h"
#import "MCApnsPush.h"
#import "MCIMMessageManager.h"
#import "MCIMVoiceModel.h"
#import "MCIMChatFileManager.h"
#import "UIView+MCExpand.h"


const static NSInteger   kSubViewOriginPaddingTop = 20;
const static NSInteger   kSubViewInfoViewHeight = 44;
const static NSInteger   kSubViewTitleLabelPaddingW = 15.0f;
const static NSInteger   kSubViewTitleLabelFont = 17.0f;

@interface MCIMChatInfoViewController ()<MCIMChatContactViewDelegate,MCIMChatSwitchViewDelegate,UIActionSheetDelegate>
{

}
@property (nonatomic, strong) MCIMChatContactView *contactView;
@property (nonatomic, strong) UIScrollView        *bgScrollView;
//把群成员下面的子view 统一放到 downView ，方便调整坐标
@property (nonatomic, strong) UIView   *downView;
@property (nonatomic, strong) MCIMConversationModel  *conversationModel;
//显示群名称label
@property (nonatomic, strong) UILabel *titleInfo;

@end

@implementation MCIMChatInfoViewController

-  (void)dealloc
{
    
}

- (instancetype)initWithConversation:(MCIMConversationModel*)conversationModel
{
    self = [super init];
    if (self) {
        self.conversationModel = conversationModel;
        if (self.conversationModel.type  ==  MailChatConversationTypeGroup) {
            MCIMGroupModel *model = (MCIMGroupModel*)self.conversationModel.peer;
            NSArray *array = [[MCIMGroupManager shared] groupMembersWithGroupuid:model.uid];
            NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:array.count];
            for (MCIMGroupMember *member  in array) {
                if (member.isOwner) {
                    member.joinState = IMGroupMemberJoinStateJoined;
                    [newArray insertObject:member atIndex:0];
                    continue;
                }
                [newArray addObject:member];
            }
            model.members =newArray;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_Msg_Details");
    
    [self _initSubViews];
    
    
    //更新当前群组信息
    if (self.conversationModel.type  ==  MailChatConversationTypeGroup/*群*/) {
        MCIMGroupModel *model = (MCIMGroupModel*)self.conversationModel.peer;
        [[MCIMGroupManager shared] updateUserCurrentGroupWithGroupId:model.groupId Success:^(id response) {
            //
            [self updateCurrentGroupInfo];
            } failure:^(NSError *error) {
            
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _titleInfo.text = self.conversationModel.peer.peerName;
}


#pragma mark - SubViews
-(void)_initSubViews
{
    
    [self.view addSubview:self.bgScrollView];
    
    if (self.conversationModel.type  ==  MailChatConversationTypeGroup/*群*/) {
        UIView *aView = [self commonViewWithConversationType:2];
        
        _titleInfo = [[UILabel alloc] initWithFrame:CGRectMake(110,2, ScreenWidth-150, 40)];
        _titleInfo.text = self.conversationModel.peer.peerName;
        _titleInfo.textAlignment = NSTextAlignmentRight;
        _titleInfo.textColor = [UIColor lightGrayColor];
        _titleInfo.font = [UIFont systemFontOfSize:kSubViewTitleLabelFont];
        [aView addSubview:_titleInfo];
        
        if ([self isGroupOwner]) {
            UIImageView *nextImage = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth-25, 12, 20, 20)];
            nextImage.image = [UIImage imageNamed:@"cellArror.png"];
            [aView addSubview:nextImage];
        }
        
        UIButton *modifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        modifyBtn.backgroundColor = [UIColor clearColor];
        modifyBtn.frame = CGRectMake(0, 0, ScreenWidth, kSubViewInfoViewHeight);
        [modifyBtn addTarget:self action:@selector(modifyGroupName:) forControlEvents:UIControlEventTouchUpInside];
        [aView addSubview:modifyBtn];
        [self.bgScrollView addSubview:aView];
        
//        联系人view
        [self.bgScrollView addSubview:self.contactView];
        [self.bgScrollView addSubview:self.downView];
        
    }else{
            UIView *aView = [self commonViewWithConversationType:1];
            [self.bgScrollView addSubview:aView];
            [self.bgScrollView addSubview:self.contactView];
            [self.bgScrollView addSubview:self.downView];
    }
    CGFloat h = CGRectGetMaxY(self.downView.frame);
    _bgScrollView.contentSize = CGSizeMake(ScreenWidth, h);
    
}

-(UIView *)commonViewWithConversationType:(NSInteger)type
{
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, kSubViewOriginPaddingTop, ScreenWidth, kSubViewInfoViewHeight)];
    aView.backgroundColor =[UIColor whiteColor];

    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
    lineImage.backgroundColor = AppStatus.theme.tableViewSeparatorColor; //
    [aView addSubview:lineImage];

    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(kSubViewTitleLabelPaddingW, 2,type==1?150:100,40)];
    titleLab.text = type ==1?PMLocalizedStringWithKey(@"PM_Msg_SingleName"):PMLocalizedStringWithKey(@"PM_Msg_GroupName");
    titleLab.textColor = [UIColor blackColor];
    titleLab.font = [UIFont systemFontOfSize:17.0f];
    [aView addSubview:titleLab];

    UIImageView *lineImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(kSubViewTitleLabelPaddingW, kSubViewInfoViewHeight-0.5, ScreenWidth, 0.5)];
    lineImage2.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
    [aView addSubview:lineImage2];
    
    return aView;
}

-(UIScrollView *)bgScrollView
{
    if (!_bgScrollView) {
        _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth -64)];
        _bgScrollView.backgroundColor =  AppStatus.theme.backgroundColor;
        _bgScrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeigth+64);
    }
    return _bgScrollView;
}


-(MCIMChatContactView *)contactView
{
    if (!_contactView) {
        CGFloat  originY = kSubViewInfoViewHeight+kSubViewOriginPaddingTop+0;
        
        MCIMChatContactViewType type;
        NSArray *array;
        if (self.conversationModel.type == MailChatConversationTypeGroup) {
            type = [self isGroupOwner]?MCIMChatContactViewTypeGroupDel:MCIMChatContactViewTypeGroupNoDel;
            MCIMGroupModel *model = (MCIMGroupModel*)self.conversationModel.peer;
            array = [MCIMChatContactCellModel contactModelWithMembers:model.members];
        }else
        {
            type = MCIMChatContactViewTypeSingle;
            MCIMChatContactCellModel *model =[MCIMChatContactCellModel contactModelWithConversationModel:self.conversationModel];
            array = @[model];
        }
        _contactView = [[MCIMChatContactView  alloc] initWithFrame:CGRectMake(0, originY, ScreenWidth, 0) dataSource:array type:type];
        _contactView.delegate = self;
        }
    return _contactView;
}

-(UIView *)downView
{
    if (!_downView) {
        CGFloat  originY = CGRectGetMaxY(self.contactView.frame) + kSubViewOriginPaddingTop;
        _downView = [[UIView alloc] initWithFrame:CGRectMake(0, originY , ScreenWidth, kSubViewInfoViewHeight * 6)];
        
        UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
        lineImage.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [_downView addSubview:lineImage];
        
        MCIMChatSwitchView *remindView = [[MCIMChatSwitchView alloc] initWithFrame:CGRectMake(0, 0.5, ScreenWidth, kSubViewInfoViewHeight) WithTitle:PMLocalizedStringWithKey(@"PM_Message_No_Push") swithon:self.conversationModel.isShield];
        remindView.tag = 100;
        remindView.delegate = self;
        [_downView addSubview:remindView];
        
        MCIMChatSwitchView *topView = [[MCIMChatSwitchView alloc] initWithFrame:CGRectMake(0, kSubViewInfoViewHeight+0.5, ScreenWidth, kSubViewInfoViewHeight) WithTitle:PMLocalizedStringWithKey(@"PM_Message_SetTop") swithon:self.conversationModel.onTopTime==0?NO:YES];
        topView.tag = 101;
        topView.delegate = self;
        [_downView addSubview:topView];
        
        if (self.conversationModel.type == MailChatConversationTypeGroup) {
             MCIMGroupModel *model = (MCIMGroupModel*)self.conversationModel.peer;
            MCIMChatSwitchView *saveGroupView = [[MCIMChatSwitchView alloc] initWithFrame:CGRectMake(0, kSubViewInfoViewHeight*2+0.5, ScreenWidth, kSubViewInfoViewHeight) WithTitle:PMLocalizedStringWithKey(@"PM_Message_ContactSave") swithon:model.isSaved];
            saveGroupView.tag = 102;
            saveGroupView.delegate = self;
            [_downView addSubview:saveGroupView];
        }
        
        NSInteger heightarg =2;
        if (self.conversationModel.type == MailChatConversationTypeGroup) {
            heightarg = 3;
        }
        
        UIImageView *lineBottom= [[UIImageView alloc] initWithFrame:CGRectMake(0, heightarg*kSubViewInfoViewHeight, 15, 0.5)];
        lineBottom.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [_downView addSubview:lineBottom];
        
        
        UIImageView *lineclear1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, kSubViewInfoViewHeight*heightarg+kSubViewOriginPaddingTop-0.5, ScreenWidth, 0.5)];
        lineclear1.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [_downView addSubview:lineclear1];
        
        UIView *clearView = [[UIView alloc] initWithFrame:CGRectMake(0,kSubViewInfoViewHeight*heightarg+kSubViewOriginPaddingTop, ScreenWidth, kSubViewInfoViewHeight)];
        clearView.backgroundColor = [UIColor whiteColor];
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(kSubViewTitleLabelPaddingW, 7, 300, 30)];
        titleLab.text = PMLocalizedStringWithKey(@"PM_Msg_DeleteHisBtnTitle");
        [clearView addSubview:titleLab];
        UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        clearBtn.frame = CGRectMake(0, 0, ScreenWidth, kSubViewInfoViewHeight);
        [clearBtn addTarget:self action:@selector(clearMessagesHistorycache:) forControlEvents:UIControlEventTouchUpInside];
        [clearView addSubview:clearBtn];
        [_downView addSubview:clearView];
        
        UIImageView *lineclear2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, kSubViewInfoViewHeight*(heightarg+1)+kSubViewOriginPaddingTop+0.5, ScreenWidth, 0.5)];
        lineclear2.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [_downView addSubview:lineclear2];
        
         if (self.conversationModel.type == MailChatConversationTypeGroup) {
             CGFloat clearOriginY = CGRectGetMaxY(clearView.frame) + kSubViewOriginPaddingTop;
             UIButton *dissolveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
             dissolveBtn.backgroundColor = [UIColor colorWithHexString:@"f54e46"]; //RGBACOLOR(239, 54, 54, 1);
             dissolveBtn.layer.cornerRadius = 4.0f;
             [dissolveBtn addTarget:self action:@selector(dissolveGroup:) forControlEvents:UIControlEventTouchUpInside];
             NSString *title =[self isGroupOwner]?PMLocalizedStringWithKey(@"PM_Msg_GroupBreak"):PMLocalizedStringWithKey(@"PM_Msg_GroupExit");
             [dissolveBtn setTitle:title forState:UIControlStateNormal];
             dissolveBtn.frame = CGRectMake(8, clearOriginY, ScreenWidth-16, kSubViewInfoViewHeight-2);
             [_downView addSubview:dissolveBtn];
         }
    }
    return _downView;
}


#pragma mark - MCIMChatContactViewDelegate

-(BOOL)deleteWihthItemModel:(MCIMChatContactCellModel *)model
{
    return YES;
}

-(void)didSelectItem:(MCIMChatContactCellModel *)model
{
    MCContactModel *contactModel =[[MCContactManager sharedInstance] getContactWithEmail:model.account];
    if (!contactModel || contactModel.deleteFlag) {
        [[[UIAlertView alloc] initWithTitle:nil message:PMLocalizedStringWithKey(@"PM_Contact_DeleteOrNot") delegate:nil cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Sure") otherButtonTitles:nil, nil] show];
        return;
    }
    MCContactInfoViewController *vc = [[MCContactInfoViewController alloc] initFromType:fromChat contactModel:contactModel canEditable:NO isEnterprise:NO];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)addDataSourceItem
{
    [self addContactToChatWithNewCreat:NO];
}

-(void)deleteDataSourceItem
{
    
    if (![self isGroupOwner]) return;
    
     MCIMGroupModel *model = (MCIMGroupModel*)self.conversationModel.peer;
    if (model.members.count == 1 /*只剩群主*/) {
        [SVProgressHUD showErrorWithStatus:@"没有成员可删除"];
        return;
    }
    
    MCIMChatMemberViewController *vc = [[MCIMChatMemberViewController alloc] initWithConversation:self.conversationModel selectedModelsBlock:^(id models) {
        //
        NSArray*contacts = (NSArray*)models;
        if (contacts.count<1) return ;
        MCIMGroupModel *model = (MCIMGroupModel*)self.conversationModel.peer;

        [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_Deleting")];
        MCIMGroupManager *groupManager = [MCIMGroupManager shared];
        [groupManager removeMembers:contacts fromGroup:model success:^{
            //
            NSMutableArray *members = [[NSMutableArray alloc] initWithCapacity:contacts.count];
            for (MCContactModel *model in contacts) {
                MCIMChatContactCellModel *member =[[MCIMChatContactCellModel alloc] init];
                member.account = model.account;
                [members addObject:member];
            }
            [_contactView deleteItemsWithModels:members];
            
            //更新成员 数据
            [self updateCurrentGroupInfo];
            
            [SVProgressHUD dismiss];
        } failure:^(NSError *error) {
            //
            [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Msg_DeleteErr_re")];
        } ];
        
    } ChatMemberType:ChatMemberTypeDelete];
    __weak MCIMChatInfoViewController *weakSelf = self;
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:vc];
    
    
    [weakSelf presentViewController:navigationController animated:YES completion:nil];
}

-(void)didSelectAddContactToGroup
{
    //单聊转群聊
    [self addContactToChatWithNewCreat:YES];
}

-(void)addContactToChatWithNewCreat:(BOOL)isNewCreat
{
    if ([self currentEmailUnable]) return;
    NSArray *array;
    if (isNewCreat) {
         MCContactModel *contactModel1 =[[MCContactManager sharedInstance] getOrCreateContactWithEmail:self.conversationModel.peerId  name:self.conversationModel.peerId];
        MCContactModel *contactModel2 =[[MCContactManager sharedInstance] getOrCreateContactWithEmail:AppStatus.currentUser.email name:AppStatus.currentUser.email];
        array = @[contactModel1,contactModel2];
    }else{
        array = [self getContactsWithMembers];
    }
    
    __weak MCIMChatInfoViewController *weakSelf = self;
    MCSelectedContactsRootViewController *selectedContactsViewCottroller = [[MCSelectedContactsRootViewController alloc]initWithSelectedModelsBlock:^(id models) {
        NSArray*contacts = (NSArray*)models;
        if (contacts.count<1) {
            [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Msg_ErrNoContacts")];
            return;
        }
        if (isNewCreat) {
            // 把当前聊天对象加进去。
            NSMutableArray *allArray = [NSMutableArray arrayWithArray:contacts];
            
            if (![self.conversationModel.peerId isEqualToString:AppStatus.currentUser.email]) {
                [allArray addObject:[array firstObject]];
            }
            [self creatNewGroup:allArray];
            
        }else{
            [self inviteNewGroupMembers:contacts];
        }
    } selectedMsgGroupModelBlock:nil formCtrlType:SelectedContactChatInfo alreadyExistsModels:array];
    
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:selectedContactsViewCottroller];
    
    
    [weakSelf presentViewController:navigationController animated:YES completion:nil];
}

-(void)didSelectGroupMembers
{
    //点击查看群组成员
    MCIMChatMemberViewController *vc = [[MCIMChatMemberViewController alloc] initWithConversation:self.conversationModel selectedModelsBlock:^(id models) {
        
    } ChatMemberType:ChatMemberTypeNormal];
    __weak MCIMChatInfoViewController *weakSelf = self;
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:vc];
    [weakSelf presentViewController:navigationController animated:YES completion:nil];
    
}

-(void)didReloadDataSourceFrame:(CGRect)newFrame
{
    //frame 有变化时调用，调整UI
    CGFloat originY = CGRectGetMaxY(newFrame);
    CGRect downRect = self.downView.frame;
    downRect.origin.y = originY +kSubViewOriginPaddingTop;
    self.downView.frame = downRect;
    CGFloat originY2 = CGRectGetMaxY(downRect);
    self.bgScrollView.contentSize = CGSizeMake(ScreenWidth, originY2);
}

#pragma mark - Update GroupInfo
-(void)updateCurrentGroupInfo
{
    MCIMGroupModel *model = (MCIMGroupModel*)self.conversationModel.peer;
    NSArray *array = [[MCIMGroupManager shared] groupMembersWithGroupuid:model.uid];
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (MCIMGroupMember *member  in array) {
        if (member.isOwner) {
            [newArray insertObject:member atIndex:0];
            continue;
        }
        [newArray addObject:member];
    }
    model.members =newArray;
}


#pragma mark - 单聊转群聊 creatNewGroup
-(void)creatNewGroup:(NSArray*)contacts
{
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

-(void)inviteNewGroupMembers:(NSArray*)contacts
{
    //友盟统计
    [MCUmengManager addEventWithKey:mc_im_addMember];
    MCIMGroupManager *groupManager = [MCIMGroupManager shared];
    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_GroupInviting")];
    [groupManager inviteContacts:contacts toGroup:self.conversationModel.peer success:^{
        [_contactView addItemsWithModels:[MCIMChatContactCellModel contactModelWithContactModels:contacts]];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Msg_GroupInviteErr")];
    }];
}

#pragma mark - MCIMChatSwitchViewDelegate
- (void)swithAction:(UISwitch *)switchView
{
    if ([self currentEmailUnable]) return;
    switch (switchView.tag) {
        case 100:
            // [开启消息提醒]
            [self setPushNoticeWithSwitch:switchView];
            break;
        case 101:
            // [消息置顶]
            [self setCurrentConversation:switchView.on];
            break;
        case 102:
            // [保存消息群组到联系人列表]
            [self saveCurrentGroup:switchView.on];
            break;
        default:
            break;
    }
}

#pragma mark - PushNotice
- (void)setPushNoticeWithSwitch:(UISwitch*)switchView
{
    MCApnsPush *apnsPush = [[MCApnsPush alloc] init];
    NSString *topic;
    if (self.conversationModel.type ==MailChatConversationTypeSingle) {
        topic = [NSString stringWithFormat:@"from:%@",self.conversationModel.peerId];
    }else if (self.conversationModel.type == MailChatConversationTypeGroup)
    {
        topic = self.conversationModel.peerId;
    }else if (self.conversationModel.type == MailChatConversationTypeApp)
    {
        topic = [NSString stringWithFormat:@"%@/a",self.conversationModel.peerId];
    }else{
        topic = self.conversationModel.peerId;
    }
    //友盟统计
    [MCUmengManager addEventWithKey:mc_im_disturb];
    [apnsPush setPushOnOrOffWithTopic:topic on:switchView.on resultBlock:^(BOOL result) {
        //
        if(result){
            self.conversationModel.isShield = switchView.on;
            [[MCIMConversationManager shared] updateConversation:self.conversationModel];
        }else{
            switchView.on = !switchView.on;
        }
    }];
}

#pragma mark - settop
- (void)setCurrentConversation:(BOOL)setTop
{
    //友盟统计
    [MCUmengManager addEventWithKey:mc_im_top];
    self.conversationModel.onTopTime = setTop?[[NSDate new] timeIntervalSince1970]:0;
    [[MCIMConversationManager shared] updateConversation:self.conversationModel];
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[MCMessageViewController class]]) {
            MCMessageViewController *msgvc = (MCMessageViewController*)vc;
            [msgvc.messageViewModel setTop:self.conversationModel];
            break;
        }
    }
}

#pragma mark - saveGroup
- (void)saveCurrentGroup:(BOOL)isSave
{
    MCIMGroupModel *model = (MCIMGroupModel*)self.conversationModel.peer;
    model.isSaved = isSave;
    [[MCIMGroupManager shared] updateGroup:model];
}

#pragma mark - clearMessagesHistorycache
- (void)clearMessagesHistorycache:(UIButton*)sender
{
    // 清除缓存
    //友盟统计
    [MCUmengManager addEventWithKey:mc_im_clear];
    UIActionSheet *actionSheet =[[UIActionSheet alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Msg_DeleteHisBtnTitle") delegate:self cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel")  destructiveButtonTitle:nil otherButtonTitles:PMLocalizedStringWithKey(@"PM_Common_Sure"), nil];
    actionSheet.tag =202;
    [actionSheet showInView:self.view];

}

#pragma mark - dissolveGroup
- (void)dissolveGroup:(UIButton *)sender
{
    NSString *str;
    NSInteger tag =0;
    if ([self isGroupOwner]) {
        //解散群
        str = PMLocalizedStringWithKey(@"PM_Msg_GroupBreak");;
        tag = 200;
    }else
    {
        str = PMLocalizedStringWithKey(@"PM_Msg_GroupExit");
        tag = 201;
        //离开群
    }
    UIActionSheet *actionSheet =[[UIActionSheet alloc] initWithTitle:str delegate:self cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel")  destructiveButtonTitle:nil otherButtonTitles:PMLocalizedStringWithKey(@"PM_Common_Sure"), nil];
    actionSheet.tag =tag;
    [actionSheet showInView:self.view];

}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case 200:
            if(buttonIndex ==0){
                [self dissolveGroup];
            }else{
                
            }
            break;
        case 201:
            if(buttonIndex ==0){
                [self leaveGroup];
            }else{
                
            }
            break;
        case 202:
            if(buttonIndex ==0){
                [self clearHistory];
            }else{
                
            }
            break;
        default:
            break;
    }

}

- (void)clearHistory
{
    MCIMMessageManager *messageManager =[[MCIMMessageManager alloc] init];
    
    NSArray *array =[messageManager getVoiceNameWithConversationId:self.conversationModel.uid];
 
    for (MCIMVoiceModel *model  in array) {
        DDLogVerbose(@"content === %@",model.localPath);
        //清除语音文件
        [MCIMChatFileManager deleteVoiceFileWithMessageId:model.messageId];
    }
    [messageManager clearMessagesWithConversationId:self.conversationModel.uid];
    
    self.conversationModel.content = @"";
    [[MCIMConversationManager shared] updateConversation:self.conversationModel];
    
    
    NSMutableArray *arraytem =[[NSMutableArray alloc] initWithCapacity:0];
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[MCIMChatViewController class]]){
            [arraytem addObject:vc];
        }
    }
    MCIMChatViewController *chatVC =(MCIMChatViewController*)[arraytem lastObject];
    [chatVC clearMessagesAche];
    [SVProgressHUD showSuccessWithStatus:PMLocalizedStringWithKey(@"PM_Mine_ClearCacheSuccess")];
}

-(void)dissolveGroup
{
    //友盟统计
    [MCUmengManager addEventWithKey:mc_im_exit];
    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_GroupBreaking")];
    MCIMGroupManager *groupManager = [MCIMGroupManager shared];
    [groupManager dismissGroup:self.conversationModel.peer success:^(id response) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Msg_GroupBreakErr")];
        
    }];
}

-(void)leaveGroup
{
    //友盟统计
    [MCUmengManager addEventWithKey:mc_im_exit];
    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_GroupExiting")];
    MCIMGroupManager *groupManager = [MCIMGroupManager shared];
    [groupManager leaveGroup:self.conversationModel.peer success:^(id response) {
        //
        [self.navigationController popToRootViewControllerAnimated:YES];
        [SVProgressHUD dismiss];
        
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Msg_GroupExitErr")];
    }];
}

#pragma mark - modifyGroupName
-(void)modifyGroupName:(UIButton *)sender
{
    //群主才能修改权限
    if([self isGroupOwner]){
        MCIMChatModifyGroupViewController *vc =[[MCIMChatModifyGroupViewController alloc] initWithMCModifyInfoType:MCModifyInfoTypeGroupName withObj:self.conversationModel];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - isGroupOwner 
-(BOOL)isGroupOwner
{
    MCIMGroupModel *model = (MCIMGroupModel*)self.conversationModel.peer;
    for (MCIMGroupMember *member in model.members) {
        if (member.isOwner)
        {
            return [AppStatus.currentUser.email isEqualToString:member.userId];
        }
    }
    return NO;
}

-(BOOL)currentEmailUnable
{
    if (![AppStatus.currentUser.email isEmail]) {
        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_IMChat_emailUnable")];
        return YES;
    }else {
        return NO;
    }
}

-(NSArray*)getContactsWithMembers
{
    MCIMGroupModel *model = (MCIMGroupModel*)self.conversationModel.peer;
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (MCIMGroupMember *member in model.members) {
        MCContactModel *contactModel =[[MCContactManager sharedInstance] getContactWithEmail:member.userId];
        if (contactModel) {
            [tempArr addObject:contactModel];
        }
    }
    return tempArr;
}

#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
