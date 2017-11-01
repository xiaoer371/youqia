//
//  MCIMChatPreviewCell.h
//  NPushMail
//
//  Created by swhl on 16/4/28.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCIMChatPreviewCellDelegate <NSObject>

-(void)handleDoubleFingerEvent;

-(void)handleLongFingerEvent;

@end

@interface MCIMChatPreviewCell : UICollectionViewCell
@property (nonatomic,weak) id<MCIMChatPreviewCellDelegate> delegate;

@end
