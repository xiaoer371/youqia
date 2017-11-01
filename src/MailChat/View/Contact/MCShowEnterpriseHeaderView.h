//
//  MCShowEnterpriseHeaderView.h
//  NPushMail
//
//  Created by wuwenyu on 16/7/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  点击事件回调
 *
 *  @param model
 */
typedef void (^selectedItemBlock)(id model);

@interface MCShowEnterpriseHeaderView : UIView

- (id)initWithFrame:(CGRect)frame models:(NSArray *)models selectedItemBlock:(selectedItemBlock)block;
@property(nonatomic, strong) NSArray *models;
@property(nonatomic, strong) UICollectionView *collectionView;

@end
