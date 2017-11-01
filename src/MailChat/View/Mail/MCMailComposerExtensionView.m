//
//  MCMailComposerExtestionView.m
//  NPushMail
//
//  Created by zhang on 16/1/11.
//  Copyright © 2016年 sprite. All rights reserved.
//


#import "MCMailComposerExtensionView.h"
#import "NSString+Extension.h"
#import "MCContactManager.h"

@interface MCMailComposerExtensionView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
//dataSource
@property (nonatomic,strong)NSArray     *contactArray;

@end

const static CGFloat kMCMailComposerExtestionHightForCell         = 50.0;
const static CGFloat kMCMailComposerExtestionResultLableLeftSpace = 15.0;
const static CGFloat kMCMailComposerExtestionCellTextFont         = 15.0;
const static CGFloat kMCMailComposerExtestionCellDetailTextFont   = 13.0;
static NSString *const kMCMailComposerExtestionCellId             = @"kMCMailComposerExtestionCellId";

@implementation MCMailComposerExtensionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, frame.size.height)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tableView.backgroundColor = AppStatus.theme.backgroundColor;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:_tableView];
        
        _resultContacts = [NSArray new];
        _contactArray  = [[MCContactManager sharedInstance] getContacts];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _tableView.frame =CGRectMake(0, 0, ScreenWidth, frame.size.height);
    
}
//搜索匹配联系人
- (void)setSearchString:(NSString *)searchString {
    _searchString = searchString;
    NSString *str  =  [self trimWithString:searchString];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF.account contains[c] %@ or SELF.displayName contains[c] %@",str,str];
    _resultContacts =[_contactArray filteredArrayUsingPredicate:predicate];
    [_tableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDelegate DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.resultContacts.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString*cellId = @"cell";
    UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    MCContactModel *model = _resultContacts [indexPath.row];
    cell.textLabel.text = model.displayName;
    cell.textLabel.textColor = AppStatus.theme.fontTintColor;
    cell.textLabel.font = [UIFont systemFontOfSize:kMCMailComposerExtestionCellTextFont];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:kMCMailComposerExtestionCellDetailTextFont];
    cell.detailTextLabel.text = model.account;
    cell.detailTextLabel.textColor = AppStatus.theme.fontTintColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MCContactModel *contactModel = _resultContacts[indexPath.row];
    MCMailAddress  *mailAddress = [MCMailAddress new];
    mailAddress.email = [self trimWithString:contactModel.account];
    mailAddress.name  = contactModel.displayName;
    
    if (_searchCompleteCallBack) {
        _searchCompleteCallBack (mailAddress);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kMCMailComposerExtestionHightForCell;
}

//private
-(NSString *)trimWithString:(NSString*)trimString
{
    trimString= [trimString stringByReplacingOccurrencesOfString:@" " withString:@""];
    trimString  = [trimString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [trimString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end
