//
//  MCMailMoveViewController.m
//  NPushMail
//
//  Created by zhang on 16/3/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMailMoveViewController.h"

@interface MCMailMoveViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)UITableView *boxTableView;

@property (nonatomic,strong)NSMutableArray * boxArray;

@property (nonatomic,strong)MCMailBox *currentMailBox;

@property (nonatomic,copy) void(^moveComplete)(MCMailBox*);

@property (nonatomic,strong) MCMailManager *mailManager;

@end


static NSString*const kMCMailMoveTableViewCellId = @"kMCMailMoveTableViewCellId";

@implementation MCMailMoveViewController

- (id)initWithCurrentMailBox:(MCMailBox*)mailBox manager:(MCMailManager *)mailManager moveComplete:(void(^)(MCMailBox*))moveComplete{
 
    if (self = [super init]) {
        _currentMailBox = mailBox;
        _moveComplete = moveComplete;
        _mailManager = mailManager;
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self views];
}

//views
- (void)views {
    
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Mail_MoveTo");
    _boxTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT) style:UITableViewStylePlain];
    _boxTableView.delegate = self;
    _boxTableView.dataSource = self;
    _boxTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:_boxTableView];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.boxArray.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMCMailMoveTableViewCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMCMailMoveTableViewCellId];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"3b3b3b"];
    }
    cell.imageView.image = AppStatus.theme.mailBoxStyle.otherBoxIcon;
    MCMailBox *mailBox = _boxArray[indexPath.row];
    cell.textLabel.text = mailBox.name;
    return cell;
}

//tableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self dismissViewControllerAnimated:YES completion:^{
        MCMailBox *mailBox = _boxArray [indexPath.row];
        if (_moveComplete) {
            _moveComplete(mailBox);
        }
    }];
    if (_selectBoxCallBack) {
        _selectBoxCallBack ();
    }
}

//dataSource
- (NSMutableArray*)boxArray {
    
    if (!_boxArray) {
        
        _boxArray = [NSMutableArray new];
        MCMailManager *manager = [[MCMailManager alloc]initWithAccount:AppStatus.currentUser];
        NSArray *boxes = [manager getLocalFoldersWithUserId:AppStatus.currentUser.accountId];
        for (MCMailBox *mailBox in boxes) {
            if ([_currentMailBox.path isEqualToString:mailBox.path]||
                mailBox.type == MCMailFolderTypeSent |
                mailBox.type == MCMailFolderTypeDrafts |
                mailBox.type == MCMailFolderTypeStarred |
                mailBox.type == MCMailFolderTypePending |
                (mailBox.type == MCMailFolderTypeTrash &&
                 _currentMailBox.type == MCMailFolderTypeSpam)
                ) {
                continue;
            } else if (_currentMailBox.type == MCMailFolderTypeSent &&
                       (mailBox.type == MCMailFolderTypeInbox |
                        mailBox.type == MCMailFolderTypeSpam)) {
                continue;
            }
            
            [_boxArray addObject:mailBox];
        }
        
    }
    return _boxArray;
}

- (void)leftNavigationBarButtonItemAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
