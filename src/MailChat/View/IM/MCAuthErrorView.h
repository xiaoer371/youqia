//
//  MCAuthErrorView.h
//  NPushMail
//
//  Created by swhl on 16/12/8.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    AuthErrorTypeMail = 0,
    AuthErrorTypeOA,
} AuthErrorType;

@class MCAuthErrorView;
@protocol MCAuthErrorViewDelegate <NSObject>

- (void)reAuth:(MCAuthErrorView *)authErrorView;

- (void)conversationWithHelper:(MCAuthErrorView *)authErrorView;

@end

@interface MCAuthErrorView : UIView

@property (nonatomic,weak) id<MCAuthErrorViewDelegate> delegate;

- (instancetype)initWithType:(AuthErrorType)type;

@end
