//
//  MCDownMenuView.h
//  NPushMail
//
//  Created by wuwenyu on 16/5/24.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^selectedMenu)(id obj, NSIndexPath *index);
typedef void(^dissMissBlock)(void);
typedef void(^addAccountBlock)(void);
typedef void(^delteAccountBlock)(MCAccount *act);

@interface MCDownMenuView : UIView

- (id)initWithFrame:(CGRect)frame dataArray:(NSArray *)ary selectedMenuBlock:(selectedMenu)selectedBlock cellIdentifier:(NSString *)cellIdentifier;
- (void)show;
- (void)dismiss;

- (void)setUpTableViewInWindow;
- (void)showInWindow;
- (void)dismissInWindow;
@property(nonatomic, strong) dissMissBlock dissMissBlock;
@property(nonatomic, strong) addAccountBlock addAccountBlock;
@property(nonatomic, strong) delteAccountBlock delteAccountBlock;
@property(nonatomic, assign) CGRect originFrame;
@property(nonatomic, strong) NSArray *dataAry;
@property(nonatomic, strong) UITableView *tableView;
@end
