//
//  MCDownMenuView.m
//  NPushMail
//
//  Created by wuwenyu on 16/5/24.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCDownMenuView.h"
#import "UIView+MJExtension.h"
#import "MCAccount.h"
#import "MCGestureManagerCell.h"
#import "MCTopAccountInfoCell.h"
#import "MCContactModel.h"

@interface MCDownMenuView()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSString *cellIdentifier;

@end

static const CGFloat animateDuration = 0.3f;
static const CGFloat addOrDelBtnWidth = 11;
static const CGFloat addOrDelBtnHeight = 11;

@implementation MCDownMenuView {
    selectedMenu _selectedBlock;
    UIView *_backgroundView;
    UIView *_maskBgView;
    UIView *_headerView;
}

- (id)initWithFrame:(CGRect)frame dataArray:(NSArray *)ary selectedMenuBlock:(selectedMenu)selectedBlock cellIdentifier:(NSString *)cellIdentifier {
    if (self = [super initWithFrame:frame]) {
        _dataAry = ary;
        _selectedBlock = selectedBlock;
        _cellIdentifier = cellIdentifier;
        _originFrame = frame;
        self.clipsToBounds = YES;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
        [_tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
        [self addSubview:_tableView];
        
        [self setMj_h:0];
    }
    return self;
}

- (void)setUpTableViewInWindow {
    _tableView.layer.borderColor   = [UIColor colorWithHexString:@"E1E2E3"].CGColor;
    _tableView.separatorColor  =  [UIColor colorWithHexString:@"E1E2E3"];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableFooterView = UIView.new;
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _originFrame.size.width, 40)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, (CGRectGetHeight(_headerView.frame) - 21)/2, 180, 21)];
    titleLabel.text = PMLocalizedStringWithKey(@"PM_Mine_AddEmailAccount");
    [titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = _headerView.frame;
    [btn addTarget:self action:@selector(addAccountAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *addActBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addActBtn setImage:[UIImage imageNamed:@"addAccountIcon.png"] forState:UIControlStateNormal];
    addActBtn.frame = CGRectMake(_originFrame.size.width - 12 - addOrDelBtnWidth, (CGRectGetHeight(_headerView.frame) - addOrDelBtnHeight)/2, addOrDelBtnWidth, addOrDelBtnHeight);
    [addActBtn addTarget:self action:@selector(addAccountAction) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *hLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_headerView.frame) - 0.2, CGRectGetWidth(_headerView.frame), 0.2)];
    hLine.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
    
    [_headerView addSubview:titleLabel];
    [_headerView addSubview:btn];
    [_headerView addSubview:addActBtn];
    [_headerView addSubview:hLine];
    _tableView.tableHeaderView = _headerView;
    
}

- (void)show {
    __weak MCDownMenuView *weakSelf = self;
    [UIView animateWithDuration:animateDuration animations:^{
        [weakSelf setMj_h:weakSelf.originFrame.size.height];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss {
    __weak MCDownMenuView *weakSelf = self;
    [UIView animateWithDuration:animateDuration animations:^{
        [weakSelf setMj_h:0];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showInWindow {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    // 背景
    _backgroundView = UIView.new;
    _backgroundView.frame = CGRectMake(0, 0, keyWindow.bounds.size.width, keyWindow.bounds.size.height);
    _backgroundView.backgroundColor = [UIColor clearColor];
    _backgroundView.userInteractionEnabled = YES;
    [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissInWindow)]];
    [keyWindow addSubview:_backgroundView];
    
    _maskBgView = UIView.new;
    _maskBgView.frame = CGRectMake(0, NAVIGATIONBARHIGHT, keyWindow.bounds.size.width, keyWindow.bounds.size.height - NAVIGATIONBARHIGHT);
    _maskBgView.backgroundColor = [UIColor grayColor];
    _maskBgView.alpha = 0;
    _maskBgView.userInteractionEnabled = YES;
    [_maskBgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissInWindow)]];
    [keyWindow addSubview:_maskBgView];
    // 刷新数据更新contentSize
    [_tableView reloadData];
    [_tableView setMj_h:self.originFrame.size.height];
    
    [keyWindow addSubview:self];
    __weak MCDownMenuView *weakSelf = self;
    [UIView animateWithDuration:animateDuration animations:^{
        _maskBgView.alpha = 0.2;
        [weakSelf setMj_h:weakSelf.originFrame.size.height];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissInWindow {
    __weak MCDownMenuView *weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        _backgroundView.alpha = 0;
        _maskBgView.alpha = 0;
        [weakSelf setMj_h:0];
    } completion:^(BOOL finished) {
        if (weakSelf.dissMissBlock) {
            weakSelf.dissMissBlock();
        }
        [_backgroundView removeFromSuperview];
        _backgroundView = nil;
        [_maskBgView removeFromSuperview];
        _maskBgView = nil;
        [self removeFromSuperview];
    }];
}

#pragma mark - 
- (void)addAccountAction {
    [self dismissInWindow];
    if (self.addAccountBlock) {
        self.addAccountBlock();
    }
}

- (void)deleteAccount:(MCAccount *)act {
    if (self.delteAccountBlock) {
        self.delteAccountBlock(act);
    }
}

#pragma mark - UITableViewDelegate/DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 49;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCAccount *act = self.dataAry[indexPath.row];
    if ([_cellIdentifier isEqualToString:@"MCGestureManagerCell"]) {
        MCGestureManagerCell *cell = (MCGestureManagerCell *)[tableView dequeueReusableCellWithIdentifier:@"MCGestureManagerCell"];
        [cell configureCellWithSingleTitle:act.email];
        return cell;
    }
    if ([_cellIdentifier isEqualToString:@"MCTopAccountInfoCell"]) {
        MCTopAccountInfoCell *cell = (MCTopAccountInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"MCTopAccountInfoCell"];
        __weak MCDownMenuView *weakSelf = self;
        cell.delAccountBlock = ^(id delAccount){
            MCAccount *act = (MCAccount *)delAccount;
            [weakSelf deleteAccount:act];
        };
        [cell configureCellWithModel:act];
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id obj = self.dataAry[indexPath.row];
    if ([_cellIdentifier isEqualToString:@"MCGestureManagerCell"]) {
        [self dismiss];
    }
    if ([_cellIdentifier isEqualToString:@"MCTopAccountInfoCell"]) {
        [self dismissInWindow];
    }
    if (_selectedBlock) {
        _selectedBlock(obj, indexPath);
    }
}

@end
