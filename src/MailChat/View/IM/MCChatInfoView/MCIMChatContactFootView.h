//
//  MCIMChatContactFootView.h
//  NPushMail
//
//  Created by swhl on 16/4/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCIMChatContactFootViewDelegate <NSObject>

-(void)didSelectAction;

@end


@interface MCIMChatContactFootView : UICollectionReusableView
@property (nonatomic,weak) id<MCIMChatContactFootViewDelegate> delegate;
@property (nonatomic ,strong) UILabel  *textLab;

@end
