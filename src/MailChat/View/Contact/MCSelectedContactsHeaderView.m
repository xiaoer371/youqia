//
//  MCSelectedContactsHeaderView.m
//  NPushMail
//
//  Created by wuwenyu on 16/7/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCSelectedContactsHeaderView.h"
#import "MCSelectedMemberCell.h"
#import "TITokenField.h"
#import "UIView+MJExtension.h"
#import "MCContactModel.h"

@interface MCSelectedContactsHeaderView()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)UICollectionViewFlowLayout *collectionFlowLayout;

@end

static const CGFloat searchFieldMinWidth = 100;

@implementation MCSelectedContactsHeaderView {
    UIImageView *_hLineImageView;
    removeItemBlock _removeBlcok;
}

- (id)initWithFrame:(CGRect)frame models:(NSMutableArray *)models removeBlock:(removeItemBlock)block {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        _models = models;
        _removeBlcok = block;
        CGFloat collectViewWidth = [self collectionViewWidth];
        _collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionFlowLayout.minimumInteritemSpacing = 0;
        _collectionFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, collectViewWidth, CGRectGetHeight(frame)- 1) collectionViewLayout:_collectionFlowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"MCSelectedMemberCell" bundle:nil] forCellWithReuseIdentifier:@"MCSelectedMemberCell"];
    
        _searchIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(textFieldPaddingX, (CGRectGetHeight(frame) - 15)/2, 15, 15)];
        _searchIconImageView.image = [UIImage imageNamed:@"searchIcon.png"];
        
        _searchPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(frame) - 21)/2 - 2, 80, 21)];
        _searchPlaceholderLabel.text = PMLocalizedStringWithKey(@"PM_Contact_SearchBarPlaceHolderWithSpace");
        _searchPlaceholderLabel.textColor = [UIColor lightGrayColor];
        
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(collectViewWidth + textFieldPaddingX, paddingY, ScreenWidth - textFieldPaddingX - collectViewWidth, frame.size.height - paddingY*2)];
        _textField.placeholder = @"";
        _textField.backgroundColor = [UIColor whiteColor];
        [_textField setText:kMCTextEmpty];
        [self addSubview:_textField];
        
        _hLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - 0.5, frame.size.width, 0.5)];
        _hLineImageView.backgroundColor = AppStatus.theme.toolBarSeparatorColor;
        [self addSubview:_collectionView];
        [self addSubview:_hLineImageView];
        [self addSubview:_searchIconImageView];
        [_textField addSubview:_searchPlaceholderLabel];
        if (_models.count > 0) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:_models.count - 1 inSection:0];
            [_collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }
        
        if (_models.count > 0) {
            [_searchIconImageView setHidden:YES];
            [_searchPlaceholderLabel setHidden:NO];
            _searchPlaceholderLabel.text = PMLocalizedStringWithKey(@"PM_Contact_SearchBarPlaceHolder");
        }
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *collectionCellID = @"MCSelectedMemberCell";
    MCSelectedMemberCell *cell = (MCSelectedMemberCell *)[collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];
    MCContactModel *model = [_models objectAtIndex:indexPath.row];
    [cell configureCellWithModel:model indexPath:indexPath];
    return cell;
}

- (CGSize )collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MCContactModel *model = [_models objectAtIndex:indexPath.row];
    TIToken *token = [[TIToken alloc] initWithTitle:model.displayName];
    if (indexPath.row == 0) {
        return  CGSizeMake(CGRectGetWidth(token.frame) + textFieldPaddingX, 25 + paddingY*2);
    }
    return  CGSizeMake(CGRectGetWidth(token.frame) + paddingX, 25 + paddingY*2);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //点击事件
    DDLogVerbose(@"点击事件");
    MCContactModel *model = [_models objectAtIndex:indexPath.row];
    model.cantEdit = NO;
    model.isSelect = NO;
    [_models removeObjectAtIndex:indexPath.row];
    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
    if (_models.count == 0) {
        [self resetTextFieldStatus];
    }
    if (_removeBlcok) {
        _removeBlcok(model);
    }
    [self updateSubViews];
}

- (void)updateSubViews {
    if (_models.count > 0) {
        [_searchIconImageView setHidden:YES];
        if (_models.count > 10) {
            return;
        }
    }else {
        [self resetTextFieldStatus];
    }
    
    CGFloat collectViewWidth = [self collectionViewWidth];
    [_collectionView setMj_w:collectViewWidth];
    _textField.frame = CGRectMake(collectViewWidth + textFieldPaddingX, paddingY, ScreenWidth - collectViewWidth - textFieldPaddingX, self.frame.size.height - paddingY*2);
    if (_models.count > 0) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:_models.count - 1 inSection:0];
        [_collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }
}

- (CGFloat)collectionViewWidth {
    CGFloat collectViewWidth = 0;
    for (MCContactModel *model in _models) {
        TIToken *tempToken = [[TIToken alloc] initWithTitle:model.displayName];
        CGFloat cellWidth = CGRectGetWidth(tempToken.frame) + paddingX;
        collectViewWidth = collectViewWidth + cellWidth;
    }
    if (collectViewWidth > (ScreenWidth - searchFieldMinWidth - textFieldPaddingX)) {
        collectViewWidth = ScreenWidth - searchFieldMinWidth - textFieldPaddingX;
    }
    if (collectViewWidth > 0) {
        collectViewWidth = collectViewWidth + (textFieldPaddingX - paddingX);
    }
    return collectViewWidth;
}

- (void)insertItemWithModel:(id)model {
    [self updateSubViews];
    [_searchPlaceholderLabel setHidden:NO];
    _searchPlaceholderLabel.text = PMLocalizedStringWithKey(@"PM_Contact_SearchBarPlaceHolder");
}

- (void)removeItemWithModel:(id)model {
    [self updateSubViews];
}

- (void)resetTextFieldStatus {
    [_searchIconImageView setHidden:NO];
    [_searchPlaceholderLabel setHidden:NO];
    _searchPlaceholderLabel.text = PMLocalizedStringWithKey(@"PM_Contact_SearchBarPlaceHolderWithSpace");
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
