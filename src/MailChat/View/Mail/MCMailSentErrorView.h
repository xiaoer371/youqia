//
//  MCMailSentErrorView.h
//  NPushMail
//
//  Created by zhang on 2016/11/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCMailSentErrorView : UIView

@property (nonatomic,copy)dispatch_block_t dismissCallback;
@property (nonatomic,copy)dispatch_block_t didSelectedPendingBox;

- (id)initWithFrame:(CGRect)frame needClearItem:(BOOL)needClearItem;

- (void)show;

- (void)dismiss;

@end
