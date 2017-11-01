//
//  MCSearchBar.h
//  NPushMail
//
//  Created by wuwenyu on 16/8/10.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCSearchBar;

@protocol MCSearchBarDelegate <NSObject>

@optional
-(BOOL)searchBarShouldBeginEditing:(MCSearchBar *)searchBar;
-(void)searchBarDidBeginEditing:(MCSearchBar *)searchBar;
-(BOOL)searchBarShouldEndEditing:(MCSearchBar *)searchBar;
-(void)searchBarDidEndEditing:(MCSearchBar *)searchBar;
-(void)searchBar:(MCSearchBar *)searchBar textDidChange:(NSString *)searchText;
-(void)searchBarCancelAction:(MCSearchBar *)searchBar;
-(void)searchBarSearchAction:(MCSearchBar *)searchBar;

@end

static const CGFloat textFieldBgViewPaddingX = 15;
static const CGFloat textFieldAnimationOffsetX = 6;

@interface MCSearchBar : UIView
@property(nonatomic, strong) UIImageView *textFieldBgView;
@property(nonatomic, strong) UITextField *textField;
@property(nonatomic, strong) UIColor *searchBackgroundColor;
//文本颜色
@property(nonatomic ,strong) UIColor *textColor;
//字体
@property(nonatomic ,strong) UIFont *font;
@property(nonatomic ,strong) NSString *text;
@property(nonatomic ,strong) NSString *placeholder;
@property(nonatomic ,strong) UIColor *placeholderColor;
@property(nonatomic ,strong) UIFont *placeholderFont;
@property(nonatomic ,assign) BOOL isBecomeFirstResponder;
@property(nonatomic, weak) id<MCSearchBarDelegate> delegate;
@end
