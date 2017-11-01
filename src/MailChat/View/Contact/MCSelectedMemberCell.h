//
//  MCSelectedMemberCell.h
//  NPushMail
//
//  Created by wuwenyu on 16/4/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCContactModel;

static const CGFloat paddingX = 2;
static const CGFloat paddingY = 2;
static const CGFloat textFieldPaddingX = 15;

@interface MCSelectedMemberCell : UICollectionViewCell

- (void)configureCellWithModel:(MCContactModel *)model indexPath:(NSIndexPath *)path;

@end
