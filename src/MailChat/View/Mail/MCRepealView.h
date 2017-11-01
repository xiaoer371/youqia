//
//  MCRepealView.h
//  NPushMail
//
//  Created by zhang on 16/9/19.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCRepealView : UIView

/**
 延迟消息的秒数，默认5秒
 */
@property (nonatomic,assign) NSInteger delaySeconds;

/**
 提示消息
 */
@property (nonatomic,copy) NSString *message;
/**
 操作按钮
 */
@property (nonatomic,copy) NSString *doItemTitle;

+ (instancetype)shared;

- (id)initWithFrame:(CGRect)frame;

- (void)showWithUndoBlock:(dispatch_block_t)undoBlock commitBlock:(dispatch_block_t)commitBlock;

- (void)dismiss;

@end
