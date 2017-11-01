//
//  MCMailAttachListView.m
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCMailAttachListView.h"

@interface MCMailAttachListView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)UITableView*tableView;

@end

static  NSString*const kMCMailAttachListViewCellId = @"MCMailAttachListViewCellId";

@implementation MCMailAttachListView

- (id)initWithMCMailAttachment:(NSArray*)mailAttachments
{
    self = [super init];
    if (self) {
        
        self.clipsToBounds = YES;
        _mailAttachments                = mailAttachments;
        self.tableView                 = [[UITableView alloc] init];
        self.tableView.dataSource      = self;
        self.tableView.delegate        = self;
        self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        self.tableView.scrollEnabled   = NO;
        [self addSubview:self.tableView];
        
        self.frame = CGRectMake(0, 0, ScreenWidth, _mailAttachments.count*kMCMailAttchListCellHight+3);
        self.tableView.frame = self.frame;
    }
    return self;
}

- (void)setMailAttachments:(NSArray *)mailAttachments {
    
    if (_mailAttachments.count != mailAttachments.count) {
        self.frame = CGRectMake(0, 0, ScreenWidth, mailAttachments.count*kMCMailAttchListCellHight+3);
        self.tableView.frame = self.frame;
    }
    _mailAttachments = mailAttachments;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate ,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _mailAttachments.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MCMailAttachListCell*cell = [tableView dequeueReusableCellWithIdentifier:kMCMailAttachListViewCellId];
    if (!cell) {
        NSArray*array = [[NSBundle mainBundle] loadNibNamed:@"MCMailAttachListCell" owner:nil options:nil];
        cell = [array lastObject];
    }
    
    cell.mcMailAttachment = _mailAttachments[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kMCMailAttchListCellHight;
}

//delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([_delegate respondsToSelector:@selector(mailAttachListView:didSelectAttach:)]) {
        
        MCMailAttachment*attachment = _mailAttachments[indexPath.row];
        
        [_delegate mailAttachListView:self didSelectAttach:attachment];
    }
}

@end
