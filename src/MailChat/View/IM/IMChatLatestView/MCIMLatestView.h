//
//  MCIMLatestView.h
//  NPushMail
//
//  Created by swhl on 16/7/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCIMLatestViewDelegate <NSObject>

- (void)selectLastImage:(UIImage *)image;

@end

@interface MCIMLatestView : UIView

@property (nonatomic, weak) id<MCIMLatestViewDelegate> delegate;

- (instancetype)initWithOrigin:(CGPoint)origin;

- (instancetype)initWithDelegate:(id <MCIMLatestViewDelegate>)delegate;

- (void)isShowLatestImage;

@end