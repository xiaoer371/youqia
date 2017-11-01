//
//  MCIMInputFaceView.h
//  NPushMail
//
//  Created by swhl on 16/3/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCIMInputFaceViewDelegate <NSObject>

-(void)didSelectFaceStr:(NSString *)str;

-(void)didSendMessage:(id)sender;

-(void)didDeleteFaceStr:(NSString *)str;

@end

@interface MCIMInputFaceView : UIView

@property (nonatomic,weak) id<MCIMInputFaceViewDelegate> delegate;

-(NSArray *)getPlistFaces;

@end
