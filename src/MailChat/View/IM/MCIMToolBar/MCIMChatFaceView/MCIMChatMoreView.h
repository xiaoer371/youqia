//
//  MCIMChatMoreView.h
//  NPushMail
//
//  Created by swhl on 16/3/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCIMChatMoreViewDelegate <NSObject>

- (void)didSelectPhotos;

- (void)didSelectTakePhotos;

- (void)didSelectFile;

@optional
- (void)didSendLogFileToHelper;

@end


@interface MCIMChatMoreView : UIView

@property (nonatomic, weak) id<MCIMChatMoreViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
              isHelperAccount:(BOOL)isHelperAccount;


@end
