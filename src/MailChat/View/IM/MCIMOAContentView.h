//
//  MCIMOAContentView.h
//  NPushMail
//
//  Created by swhl on 16/3/22.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCIMOAMessageModel.h"


@class MCIMOAContentView;

@protocol MCIMOAContentViewDelegate <NSObject>

-(void)didSelectContentView;

@end

@interface MCIMOAContentView : UIView

@property(nonatomic,weak)id<MCIMOAContentViewDelegate> delegate;

-(void)setFrameWithOAmodel:(MCIMOAMessageModel *)oaModel originPoint:(CGPoint)originPoint;

@end
