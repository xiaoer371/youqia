//
//  MCShowSelectedMembersBottomView.h
//  NPushMail
//
//  Created by wuwenyu on 16/4/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSelectedContactsBlock.h"

@interface MCShowSelectedMembersBottomView : UIView

@property(nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) SelectedModelsBlock selectedBlcok;
- (id)initWithFrame:(CGRect)frame selectedBlock:(SelectedModelsBlock)block;
@end
