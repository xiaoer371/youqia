//
//  MCIMChatMemberViewController.m
//  NPushMail
//
//  Created by swhl on 16/4/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatMemberViewController.h"
#import "MCIMConversationModel.h"
#import "MCShowSelectedMembersBottomView.h"
#import "UIView+MCExpand.h"
#import "MCIMGroupModel.h"
//#import "MCContactCell.h"
#import "MCContactManager.h"
#import "MCContactInfoViewController.h"
#import "MCIMMemberCell.h"

@interface MCIMChatMemberViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy)   SelectedModelsBlock selectedModelsBlock;
@property (nonatomic, strong) MCIMConversationModel  *conversationModel;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *selectedModels;

@end

@implementation MCIMChatMemberViewController

- (instancetype)initWithConversation:(MCIMConversationModel*)conversationModel selectedModelsBlock:(SelectedModelsBlock)selectedModelsBlock ChatMemberType:(ChatMemberType)ChatMemberType
{
    self = [super init];
    if (self) {
        self.conversationModel = conversationModel;
        self.selectedModelsBlock = selectedModelsBlock;
        self.ChatMemberType = ChatMemberType;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
     self.definesPresentationContext = YES;
    
    self.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_IMChat_GroupMembers");
    self.currentUserLable.text = @"";
    self.currentUserLable.frame = CGRectZero;
    [self.navBarTitleLable moveoffSetY:6.0f];
    
    [self.view addSubview:self.tableView];

    if (self.ChatMemberType == ChatMemberTypeNormal) {
        
    }else if (self.ChatMemberType == ChatMemberTypeDelete){

        [self.rightNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_IMChat_MessageDelete")];
    }else{
        
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCIMMemberCell *cell =[tableView dequeueReusableCellWithIdentifier:@"MCIMMemberCell" forIndexPath:indexPath];
    MCContactModel *model = self.dataArray[indexPath.row];
    [cell configureCellWithModel:model];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MCContactModel *model = nil;
    model =self.dataArray[indexPath.row];
    
    switch (self.ChatMemberType) {
        case ChatMemberTypeNormal:
        {
            MCContactInfoViewController *vc = [[MCContactInfoViewController alloc] initFromType:fromChat contactModel:model canEditable:NO isEnterprise:NO];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case ChatMemberTypeDelete:
        {
            MCContactCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell changeSelectedState];
            [self setSelectedModelsWithModel:model];
        }
            break;
            
        default:
            break;
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleNone;
}

- (void)setSelectedModelsWithModel:(MCContactModel *)model
{
    BOOL isExist = NO;
    for (MCContactModel *obj in self.selectedModels) {
        if ([obj.account  isEqualToString:model.account]) {
            isExist = YES;
            if (!model.isSelect) {
                [_selectedModels removeObject:obj];
            }
            break;
        }
    }
    if (!isExist) {
        if (model.isSelect) {
            [self.selectedModels addObject:model];
        }
    }
}
- (void)didPresentSearchController:(UISearchController *)searchController
{
    DDLogVerbose(@"didPresentSearchController");
    
    CGFloat height = CGRectGetHeight(_tableView.frame);
    _tableView.frame = CGRectMake(0, 20, ScreenWidth, height);
    

}
- (void)willDismissSearchController:(UISearchController *)searchController
{
    DDLogVerbose(@"willDismissSearchController");
    CGFloat height = CGRectGetHeight(_tableView.frame);
    _tableView.frame = CGRectMake(0, 0, ScreenWidth, height);
    
}

#pragma mark - left / right action
-(void)leftNavigationBarButtonItemAction:(id)sender
{
    for ( MCContactModel *contactModel in self.dataArray) {
        contactModel.isSelect = NO;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void)rightNavigationBarButtonItemAction:(id)sender
{
    _selectedModelsBlock(self.selectedModels);
    for ( MCContactModel *contactModel in self.dataArray) {
        contactModel.isSelect = NO;
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        MCIMGroupModel *model = (MCIMGroupModel*)self.conversationModel.peer;
        _dataArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (MCIMGroupMember *member in model.members) {
            //删除状态下不要显示群主
            if (self.ChatMemberType == ChatMemberTypeDelete) {
                if (member.isOwner) {
                    continue;
                }
            }
            MCContactModel *contactModel =[[MCContactManager sharedInstance] getContactWithEmail:member.userId];
            if (contactModel) {
                if ([member isOwner]) {
                    contactModel.groupMemberType = MCModelStateOwner;
                }else{
                    contactModel.groupMemberType = MCModelStateMember;
                }
                if ( member.joinState == IMGroupMemberJoinStateWaiting  ) {
                    contactModel.groupMemberType = MCModelStateNotJion;
                }
                [_dataArray addObject:contactModel];
            }
        }
    }
    return _dataArray;
}

-(NSMutableArray *)selectedModels
{
    if (!_selectedModels) {
        _selectedModels = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedModels;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        CGFloat height = 0.0f;
        BOOL isEdit =NO;
        switch (self.ChatMemberType) {
            case ChatMemberTypeNormal:{
                height =ScreenHeigth- NAVIGATIONBARHIGHT;
                isEdit = NO;
            }
                break;
            case ChatMemberTypeDelete:{
                height =ScreenHeigth- NAVIGATIONBARHIGHT;
                isEdit = YES;
            }
                break;
            default:
                break;
        }
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth,height )];
        _tableView.delegate = self;
        _tableView.backgroundColor = AppStatus.theme.backgroundColor;
        _tableView.dataSource = self;
        _tableView.editing = isEdit;
        _tableView.allowsSelectionDuringEditing = YES;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
        _tableView.sectionIndexColor = [UIColor colorWithHexString:@"aaaaaa"];
        [_tableView registerNib:[UINib nibWithNibName:@"MCIMMemberCell" bundle:nil] forCellReuseIdentifier:@"MCIMMemberCell"];
    }
    return _tableView;
}

@end
