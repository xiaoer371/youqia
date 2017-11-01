//
//  MCMailListTableView.m
//  NPushMail
//
//  Created by zhang on 16/3/2.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMailListTableView.h"
@interface MCMailListTableView ()<SRRefreshDelegate>
@property (nonatomic,assign)BOOL refreshControlValueChange;
@end

@implementation MCMailListTableView
- (id)init {
    
    if (self = [super init]) {
        
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT - TOOLBAR_HEIGHT);
        self.multipleTouchEnabled = NO;
        self.backgroundColor = AppStatus.theme.backgroundColor;
        [self setExclusiveTouch:YES];
        self.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
        self.allowsSelectionDuringEditing = YES;
        self.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        self.showsVerticalScrollIndicator = YES;
        self.separatorInset = UIEdgeInsetsMake(0, 57.0, 0, 0);
        self.separatorColor = AppStatus.theme.tableViewSeparatorColor;
        
        _refreshView = [[SRRefreshView alloc]init];
        _refreshView.delegate = self;
        _refreshView.upInset = 0;
        _refreshView.slimeMissWhenGoingBack = YES;
        _refreshView.slime.bodyColor = [UIColor colorWithHexString:@"aaafb6"];
        _refreshView.slime.skinColor = [UIColor colorWithHexString:@"aaafb6"];
        _refreshView.slime.lineWith = 1;
        _refreshView.backgroundColor = [UIColor clearColor];
        [self addSubview:_refreshView];
    }
    return self;
}

- (void)endRefreshWithResult:(LoadMailResult)result{
    if (!_refreshControlValueChange) {
        return;
    }
    NSString *note = result == LoadMailResultNoNewMails ? PMLocalizedStringWithKey(@"PM_Mail_NoneNewMail"):PMLocalizedStringWithKey(@"PM_Mail_NewMail");
    [_refreshView endRefreshWithResult:note];
    _refreshControlValueChange = NO;
}

#pragma mark SRRefreshViewDelegate
- (void)slimeRefreshStartRefresh:(SRRefreshView*)refreshView {
    
    if ([_refreshDelegate respondsToSelector:@selector(tableViewDidRefresh)]) {
        _refreshControlValueChange = YES;
        [_refreshDelegate tableViewDidRefresh];
    }
}

@end
