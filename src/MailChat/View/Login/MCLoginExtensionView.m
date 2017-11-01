//
//  MCLoginExtensionView.m
//  NPushMail
//
//  Created by zhang on 16/1/22.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCLoginExtensionView.h"

static NSString*const kMCLoginExtensionViewCellId = @"kMCLoginExtensionViewCellId";

@interface MCLoginExtensionView () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView    *tableView;
@property (nonatomic,strong)NSArray        *mailSuffixesArray;
@property (nonatomic,strong)NSMutableArray *mailDomainResult;
@end
@implementation MCLoginExtensionView


- (id)initWithFrame:(CGRect)frame EmailType:(NSInteger)emailType {
    if (self = [super initWithFrame:frame]) {
       
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"suffix" ofType:@"plist"];
        NSArray*suffixes = [NSArray arrayWithContentsOfFile:plistPath];
        _mailSuffixesArray = [suffixes objectAtIndex:emailType];//邮箱后缀集合
        _mailDomainResult  = [NSMutableArray array];
        [self setUp];
    }
    return self;
}


- (void)setUp {
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self addSubview:_tableView];
}

#pragma mark - UITableViewDelegate dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.mailDomainResult.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:kMCLoginExtensionViewCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMCLoginExtensionViewCellId];
    }
    NSString*mailDmain = self.mailDomainResult[indexPath.row];
    NSString*mailPrefix= [self mailPrefixWith:_email];
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@",mailPrefix,mailDmain];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell*cell = [tableView cellForRowAtIndexPath:indexPath];
    self.hidden = YES;
    if ([_delegate respondsToSelector:@selector(mcLoginExtensionView:didSelectEmail:)]) {
        [_delegate mcLoginExtensionView:self didSelectEmail:cell.textLabel.text];
    }
}

//set
- (void)setEmail:(NSString *)email {
    
    _email = email;
    self.hidden = email.length >0?NO:YES;
    
    [self.mailDomainResult removeAllObjects];
    NSString*mailDomain = [email mailDomain];
    if ([mailDomain length] <= 0) {
        [self.mailDomainResult addObjectsFromArray:self.mailSuffixesArray];
    } else {
        NSString*pre = [NSString stringWithFormat:@"self LIKE '@%@*'",mailDomain];
        NSPredicate*predicate = [NSPredicate predicateWithFormat:pre];
        [self.mailDomainResult addObjectsFromArray:[self.mailSuffixesArray filteredArrayUsingPredicate:predicate]];
    }
    if (self.mailDomainResult.count <= 0) {
        self.hidden = YES;
    }else {
        [self.tableView reloadData];
    }
}

//Prefix
- (NSString*)mailPrefixWith:(NSString*)email {
    //中文空格
    email = [email stringByReplacingOccurrencesOfString:@" " withString:@""];
    //英文空格
    email = [email stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSRange atRange = [email rangeOfString:@"@" options:NSBackwardsSearch];
    if (atRange.length == 0) {
        return email;
    }
    
    NSRange domainRange = NSMakeRange(0, atRange.location);
    return [email substringWithRange:domainRange];
}

@end
