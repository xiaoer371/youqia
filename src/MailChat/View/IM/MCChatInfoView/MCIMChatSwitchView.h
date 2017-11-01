//
//  MCIMChatSwitchView.h
//  NPushMail
//
//  Created by swhl on 16/3/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCIMChatSwitchView;

@protocol MCIMChatSwitchViewDelegate <NSObject>

- (void)swithAction:(UISwitch *)switchView;

@end


@interface MCIMChatSwitchView : UIView

@property (nonatomic,weak) id<MCIMChatSwitchViewDelegate> delegate;
@property (nonatomic,strong) UISwitch *switchView;

- (instancetype)initWithFrame:(CGRect)frame
                    WithTitle:(NSString *)title
                      swithon:(BOOL)on_off;

@end
