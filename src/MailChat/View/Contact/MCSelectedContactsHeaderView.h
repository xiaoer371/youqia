//
//  MCSelectedContactsHeaderView.h
//  NPushMail
//
//  Created by wuwenyu on 16/7/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const kMCTextEmpty = @"\u200B"; // Zero-Width Space
static NSString *const kMCTextHidden = @"\u200D"; // Zero-Width Joiner

@class MCSelectedContactItem;
/**
 *  点击移除回调
 *
 *  @param model
 */
typedef void (^removeItemBlock)(id model);

@interface MCSelectedContactsHeaderView : UIView

- (id)initWithFrame:(CGRect)frame models:(NSArray *)models removeBlock:(removeItemBlock)block;
@property(nonatomic, strong) NSMutableArray *models;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIImageView *searchIconImageView;
@property(nonatomic, strong) UILabel *searchPlaceholderLabel;
@property(nonatomic, strong) UITextField *textField;
- (void)insertItemWithModel:(id)model;
- (void)removeItemWithModel:(id)model;
- (void)updateSubViews;
/**
 *  重置搜索框的状态
 */
- (void)resetTextFieldStatus;
@end
