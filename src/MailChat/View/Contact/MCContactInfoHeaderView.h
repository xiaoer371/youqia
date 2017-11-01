//
//  MCContactInfoHeaderView.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^setImportantBlock)(BOOL important);

@interface MCContactInfoHeaderView : UIImageView

- (id)initWithFrame:(CGRect)frame showBottomLine:(BOOL)showLineFlag importantBlock:(setImportantBlock)importantBlock;
- (void)configureView:(id)contactModel;

@end
