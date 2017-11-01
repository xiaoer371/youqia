//
//  MCIMChatForwordViewController.m
//  NPushMail
//
//  Created by swhl on 16/5/4.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatForwordViewController.h"
#import "MCIMMessageModel.h"
#import "MCIMConversationManager.h"
#import "MCIMConversationCell.h"
#import "MCIMMessageSender.h"
#import "MCIMImageModel.h"
#import "MCIMFileModel.h"
#import "MCSelectedContactsRootViewController.h"
#import "MCIMChatViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCIMSetGroupNameView.h"
#import "MCIMGroupManager.h"
#import "MCMailComposerViewController.h"


static const  CGFloat MCIMForwordCellHeight = 44.0f;
static const  CGFloat MCIMForwordSectionHeight = 27.0f;
//static const  CGFloat MCIMForwordConversatCellHeight = 57.0f;

@interface MCIMChatForwordViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) MCIMMessageModel *messageModel;
@property (nonatomic, strong) NSMutableArray   *dataSource;
@property (nonatomic, strong) UITableView      *tableView;

@property (nonatomic, strong) NSArray   *files;

@end

@implementation MCIMChatForwordViewController{
    MCIMConversationModel *_currentConversation;
}
- (instancetype)initWithMessageModel:(MCIMMessageModel *)messageModel
{
    self = [super init];
    if (self) {
        self.messageModel = messageModel;
    }
    return self;
}

- (instancetype)initWithFiles:(NSArray *)files
{
    self = [super init];
    if (self) {
        self.files = [NSArray arrayWithArray:files];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navBarTitleLable.text =PMLocalizedStringWithKey(@"PM_FORWARD_ForwardTo");
    [self _initSubView];
}

-(void)_initSubView
{
    [self.view addSubview:self.tableView];
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth-64)style:UITableViewStylePlain];
        _tableView.backgroundColor=[UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView =[[UIView alloc] init];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource -UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.dataSource[section];
    if (section==0) {
        if(self.messageModel){
             return arr.count;
        }else {
            return 1;
        }
    }else{
        return arr.count;
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *forwardCellType = @"forwardCellType";
    static NSString *forwardCellContact = @"MCIMConversationCell";
    
    
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:forwardCellType];
    if(!cell){
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:forwardCellType];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    MCIMConversationCell *contactCell=[tableView dequeueReusableCellWithIdentifier:forwardCellContact];
    if (!contactCell){
        NSArray *array=[[NSBundle mainBundle] loadNibNamed:@"MCIMConversationCell" owner:nil options:nil];
        for (id obj in array){
            if ([obj isKindOfClass:[MCIMConversationCell class]]){
                contactCell=obj;
                contactCell.accessoryType = UITableViewCellAccessoryNone;
                break;
            }
        }
    }
    
    if (indexPath.section==0) {
        NSArray *arr = self.dataSource[indexPath.section];

        if (indexPath.row==0 && arr.count==2) {
            cell.imageView.image =[UIImage imageNamed:@"forwardMail.png"];
        }else {
            cell.imageView.image =[UIImage imageNamed:@"forwardContact.png"];
        }
        
        cell.textLabel.text = arr[indexPath.row];
        return cell;
    }else{
        NSArray *conversationArr =self.dataSource[indexPath.section];
         MCIMConversationModel *conversation =[conversationArr objectAtIndex:indexPath.row];
        [contactCell subViewWithConversation:conversation];
        return contactCell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        if (self.messageModel) {
            
            switch (self.messageModel.type) {
                case IMMessageTypeText:
                {
                    if (indexPath.row == 0) {
                        id obj ;
                        MCMailComposerOptionType composerType;
                        if (_messageModel.type == IMMessageTypeText) {
                            obj = _messageModel.content;
                            composerType = MCMailComposerFromMessageText;
                        } else {
                            obj = _messageModel;
                            composerType = MCMailComposerFromMessageFile;
                        }
                        
                        MCMailComposerViewController *mailComposerViewController = [[MCMailComposerViewController alloc]initWithContent:obj composerType:composerType];
                        [self.navigationController pushViewController:mailComposerViewController animated:YES];
                    }else{
                        [self forwardMessageWithIM];
                    }
                }
                    break;
                case IMMessageTypeImage:
                case IMMessageTypeFile:
                {
                    [self forwardMessageWithIM];
                }
                    break;
                default:
                    break;
            }
        }else{
            [self forwardMessageWithIM];
        }
    }else{
        NSArray *conversationArr =self.dataSource[indexPath.section];
        MCIMConversationModel *conversation =[conversationArr objectAtIndex:indexPath.row];
        _currentConversation = conversation;
        UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_FORWARD_ForwardSure") message: conversation.peer.peerName?:conversation.peerId delegate:self cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel") otherButtonTitles:PMLocalizedStringWithKey(@"PM_Common_Sure"), nil];
        [alertView show];
    }
}

-(void)forwardMessageWithIM
{
    __weak MCIMChatForwordViewController *weakSelf = self;
    MCSelectedContactsRootViewController *selectedContactsViewCottroller = [[MCSelectedContactsRootViewController alloc]initWithSelectedModelsBlock:^(id models) {
        
        NSArray*contacts = (NSArray*)models;
        if (contacts.count==0)return;
        [weakSelf creatChatWithContacts:contacts];
        
    } selectedMsgGroupModelBlock:nil formCtrlType:SelectedContactForwordChat alreadyExistsModels:nil];
    
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:selectedContactsViewCottroller];
    
    [weakSelf presentViewController:navigationController animated:YES completion:nil];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==1) {
        return MCIMForwordSectionHeight;
    }else{
        return 0.0f;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return MCIMForwordCellHeight;
    }else{
         return 66.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==1) {
        UIView *aView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, MCIMForwordSectionHeight)];
        aView.backgroundColor = [UIColor colorWithHexString:@"f7f7f9"];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 4, ScreenWidth-16, 16)];
        label.text = PMLocalizedStringWithKey(@"PM_FORWARD_ForwardRecently");
        label.font = [UIFont systemFontOfSize:12.0f];
        label.textColor = [UIColor colorWithHexString:@"777777"];
        [aView addSubview:label];
        
        return aView;
    }else return nil;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        [self sendForwordMessage];
    }else{
        DDLogVerbose(@"cancle");
    }
}

-(void)creatChatWithContacts:(NSArray *)contacts
{
    if (contacts.count == 1) {
        MCContactModel *contactModel = contacts[0];
        MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForContact:contactModel];
        _currentConversation = conversationModel;
        [self sendForwordMessage];

    } else {

        [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_GroupCreating")];

        MCIMGroupManager *groupManager =[MCIMGroupManager shared];
        [groupManager createGroupWithGroupName:nil members:contacts success:^(id response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                MCIMGroupModel *group = (MCIMGroupModel* )response;
                MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForGroup:group];
                [SVProgressHUD dismiss];
                _currentConversation = conversationModel;

                [self sendForwordMessage];
            });
        } failure:^(NSError *error) {
            
            [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Msg_GroupCreatErr")];
        }];
    }
}


-(void)sendForwordMessage
{
    if (self.messageModel) {
        [[MCIMMessageSender shared] forwardMessage:self.messageModel toConversation:_currentConversation success:^{
            //
            [SVProgressHUD showSuccessWithStatus:PMLocalizedStringWithKey(@"PM_Mail_MailSendScc")];
        } failure:^(NSError *error) {
            //
            [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Mail_MailSendFail")];
        }];

    }else{
        for (MCFileBaseModel *file in self.files) {
            [[MCIMMessageSender shared] sendFileWithModel:file fileName:file.displayName toConversation:_currentConversation success:^{
                [SVProgressHUD showSuccessWithStatus:PMLocalizedStringWithKey(@"PM_Mail_MailSendScc")];
            } failure:^(NSError *error) {
                [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Mail_MailSendFail")];
            }];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -DataSource
-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        NSArray *arr;
        if (self.messageModel) {
            switch (self.messageModel.type) {
                case IMMessageTypeText:
                {
                     arr = @[PMLocalizedStringWithKey(@"PM_FORWARD_ForwardWithEmail"),PMLocalizedStringWithKey(@"PM_Main_ForwardContact")];
                }
                    break;
                case IMMessageTypeImage:
                case IMMessageTypeFile:
                {
                    arr = @[PMLocalizedStringWithKey(@"PM_IMChat_ForwardOtherContact")];
                }
                    break;
                default:
                    break;
            }
            
        }else{
            arr = @[PMLocalizedStringWithKey(@"PM_IMChat_ForwardOtherContact")];
        }
        
        NSArray *array = [[MCIMConversationManager shared] getAllConversations];
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"_onTopTime"ascending:NO];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"_lastMsgTime"ascending:NO];
        NSArray *tempArray = [array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil]];
        
        _dataSource =[[NSMutableArray alloc] initWithCapacity:2];
        [_dataSource addObject:arr];
        
        //遍历去除oa会话对象
        NSMutableArray *forwardConversations = [NSMutableArray arrayWithArray:tempArray];
        for (MCIMConversationModel *conversationModel in tempArray) {
            if (conversationModel.type== MailChatConversationTypeApp) {
                [forwardConversations removeObject:conversationModel];
                break;
            }
        }
        [_dataSource addObject:forwardConversations];
        
    }
    return _dataSource;
}

@end
