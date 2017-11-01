//
//  MCMessageGroupsViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/7/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMessageGroupsViewController.h"
#import "MCIMGropCellDataSource.h"
#import "MCMessageGroupCell.h"
#import "MCIMGroupManager.h"
#import "MCIMConversationManager.h"
#import "MCIMChatViewController.h"
#import "MCIMNoMessageView.h"
#import "UIView+MCExpand.h"
#import "MCAppDelegate.h"
#import "MCSelectedContactsRootViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCMessageViewController.h"

@interface MCMessageGroupsViewController ()<UITableViewDelegate>
@property (nonatomic,strong)MCIMNoMessageView *mcNoMessageView;
@end

@implementation MCMessageGroupsViewController {
    UISearchDisplayController *_searchDisplay;
    MCIMGropCellDataSource *_searchResultCellDataSource;
    MCIMGropCellDataSource *_groupsCellDataSource;
    NSMutableArray *_groups;
    NSMutableArray *_searchRusltArray;
    UITableView *_tableView;
    UISearchBar *_searchBar;
    BOOL _isSearch;
    SelectedMsgGroupType _ctrlType;
    SelectedMsgGroupBlock _selectedMsgGroupBlock;
}

- (id) initWithFromCtrlType:(SelectedMsgGroupType)ctrlType selectedGroupBlock:(SelectedMsgGroupBlock)block {
    if (self == [super init]) {
        _ctrlType = ctrlType;
        _selectedMsgGroupBlock = block;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self loadSubViews];
//    [self loadDataSource];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadDataSource];
    [_tableView reloadData];
}

- (void)loadDataSource {
    //MCIMGroupModel
    _groups = [[[MCIMGroupManager shared] getSavedGroupModels] mutableCopy];
    _groupsCellDataSource.models = _groups;
    _mcNoMessageView.hidden = _groups.count != 0?YES:NO;
}

- (void)loadSubViews {
    _groups = [NSMutableArray new];
    _searchRusltArray = [NSMutableArray new];
    self.viewTitle = PMLocalizedStringWithKey(@"PM_ContactMessageGroups");
    [self.rightNavigationBarButtonItem setImage:[UIImage imageNamed:@"addLinkman111.png"]];
    [self.rightNavigationBarButtonItem setTitle:[NSString stringWithFormat:@"%@",PMLocalizedStringWithKey(@"PM_Msg_AddChats")]];
    TableViewCellConfigureBlock tableViewConfigureBlock = ^(id cell, id model, NSIndexPath *indexPath) {
        [cell configureCellWithModel:model];
    };
    _groupsCellDataSource =  [[MCIMGropCellDataSource alloc] initWithModels:_groups cellIdentifier:@"MCMessageGroupCell" configureCellBlock:tableViewConfigureBlock];
    
    __block typeof(self)weak = self;
    _groupsCellDataSource.deleteDataSourceBlock = ^{
        if (_groups.count == 0) {
            weak.mcNoMessageView.hidden = NO;
        }
    };
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth- NAVIGATIONBARHIGHT)];
    _tableView.delegate = self;
    _tableView.backgroundColor = AppStatus.theme.backgroundColor;
    _tableView.dataSource = _groupsCellDataSource;
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    _tableView.sectionIndexColor = AppStatus.theme.fontTintColor;
    [_tableView registerNib:[UINib nibWithNibName:@"MCMessageGroupCell" bundle:nil] forCellReuseIdentifier:@"MCMessageGroupCell"];
    [self.view addSubview:_tableView];

    //无消息标签
    _mcNoMessageView = [[MCIMNoMessageView alloc] initWithCreatType:MCNODateSourceAlertNoFile imageName:@"mc_noGroups.png" text:PMLocalizedStringWithKey(@"PM_IMChat_noGroupsNotice")];
    [_mcNoMessageView moveToY:0];
    [self.view addSubview:_mcNoMessageView];
}

#pragma mark -   UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MCIMGroupModel *model = [_groupsCellDataSource modelAtIndexPath:indexPath];
    if (_ctrlType == SelectedMsgGroupFromSelectedContact) {
        if (_selectedMsgGroupBlock) {
            _selectedMsgGroupBlock(model);
        }
    }else {
        
        [self.navigationController popToRootViewControllerAnimated:NO];
        MCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//        appDelegate.mCTabBarController.selectedIndex = 1;
        UINavigationController *nav ; //= appDelegate.mCTabBarController.viewControllers[1];
        int i = 0;
        for (UINavigationController *subNav in appDelegate.tabBarController.viewControllers) {
            if ([subNav.viewControllers[0] isKindOfClass:[MCMessageViewController class]]) {
                i++;
                nav =subNav;
                break;
            }
        }
        appDelegate.tabBarController.selectedIndex = i;
        MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForGroup:model];
        MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
        [nav pushViewController:vc animated:NO];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)leftNavigationBarButtonItemAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightNavigationBarButtonItemAction:(id)sender {
    
    [MCUmengManager addEventWithKey:mc_im_sendchat];
    __block typeof(self)weakSelf = self;
    MCSelectedContactsRootViewController *selectedContactsViewCottroller = [[MCSelectedContactsRootViewController alloc]initWithSelectedModelsBlock:^(id models) {
        NSArray*contacts = (NSArray*)models;
        if (contacts.count==0){
            [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Msg_ErrNoContacts")];
            return;
        }
        [weakSelf creatChatWithContacts:contacts];
        
    } selectedMsgGroupModelBlock:^(id model) {
        MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForGroup:model];
        MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    } formCtrlType:SelectedContactFromChat alreadyExistsModels:nil];
    
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:selectedContactsViewCottroller];
    
    [weakSelf presentViewController:navigationController animated:YES completion:nil];
}


-(void)creatChatWithContacts:(NSArray *)contacts
{
    if (contacts.count==1) {
        MCContactModel *contactModel = contacts[0];
        
        if ([contactModel.account isEqualToString:AppStatus.currentUser.email]) {
            [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_IMChat_CurrentChat")];
            return;
        }
        
        MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForContact:contactModel];
        MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else
    {
        NSMutableArray *newContacts =[NSMutableArray arrayWithArray:contacts];
        for (MCContactModel *contactModel in contacts) {
            if ([contactModel.account isEqualToString:AppStatus.currentUser.email]) {
                [newContacts removeObject:contactModel];
            }
        }
        
        if (newContacts.count==1) {
            MCContactModel *contactModel = contacts[0];
            MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForContact:contactModel];
            MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            __weak typeof(self) weakSelf = self;
            [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_GroupCreating")];
            MCIMGroupManager *groupManager =[MCIMGroupManager shared];
            [groupManager createGroupWithGroupName:nil members:newContacts success:^(id response) {
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
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
