//
//  MCIMChatFaceView.h
//  NPushMail
//
//  Created by swhl on 16/3/2.
//  Copyright © 2016年 sprite. All rights reserved.
//

// only emoji

#import <UIKit/UIKit.h>

@protocol MCIMChatFaceViewDelegate <NSObject>

-(void)selectedFacialView:(NSString*)str;

-(void)sendMessageText:(id)sender;

-(void)deleteFacialView:(NSString*)str;

@end


@interface MCIMChatFaceView : UIView


@property(nonatomic,weak) id <MCIMChatFaceViewDelegate>  delegate;

-(instancetype)initWithFrame:(CGRect)frame;


-(NSArray *)getPlistFaces;

@end
