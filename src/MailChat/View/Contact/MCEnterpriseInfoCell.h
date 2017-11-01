//
//  MCEnterpriseInfoCell.h
//  NPushMail
//
//  Created by wuwenyu on 16/7/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat paddingX = 5;
static const CGFloat paddingY = 5;

@interface MCEnterpriseInfoCell : UICollectionViewCell

- (void)configureWithTitle:(NSString *)title enableSelect:(BOOL)flag;

@end
