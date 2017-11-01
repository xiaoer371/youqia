//
//  MCEnterpriseOrganizationViewController.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/2.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"
#import "MCContactDidSelectedContactBlock.h"

@interface MCEnterpriseOrganizationViewController : MCBaseSubViewController
@property (nonatomic, strong) UITableView *mainTabelV;
-(id) initWithEisFlag:(BOOL)eisFlag haveChangeFrame:(BOOL)haveChangeFrame didSelectedBlock:(ContactDidSelectedBlock)block;
- (void)changeAccountLoadData;
@end
