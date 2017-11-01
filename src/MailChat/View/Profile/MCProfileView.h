//
//  MCProfileView.h
//  NPushMail
//
//  Created by zhang on 16/4/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCProfileView;

@protocol MCProfileViewDelegate <NSObject>

- (void)profileView:(MCProfileView*)profileView didChangeAccount:(MCAccount*)account;

- (void)profileView:(MCProfileView *)profileView didSelectCellIndexPath:(NSIndexPath*)indexPath title:(NSString*)title;

- (void)profileView:(MCProfileView *)profileView didSelectAccountInfo:(MCAccount *)account;

- (void)profileViewAddNewAccount;
@end


@interface MCProfileView : UIView

@property (nonatomic,strong)NSArray *accounts;

- (id)initWithDelegate:(id<MCProfileViewDelegate>)delegate;

- (void)reloadData;

@end
