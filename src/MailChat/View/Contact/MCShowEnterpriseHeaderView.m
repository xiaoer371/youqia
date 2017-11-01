//
//  MCShowEnterpriseHeaderView.m
//  NPushMail
//
//  Created by wuwenyu on 16/7/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCShowEnterpriseHeaderView.h"
#import "MCEnterpriseInfoCell.h"
#import "MCEnterpriseContactCellItem.h"
#import "MCBranchInfo.h"
#import "MCGroup.h"

@interface MCShowEnterpriseHeaderView()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)UICollectionViewFlowLayout *collectionFlowLayout;

@end

@implementation MCShowEnterpriseHeaderView {
    UIImageView *_hLineImageView;
    selectedItemBlock _selectedItemBlock;
}

- (id)initWithFrame:(CGRect)frame models:(NSArray *)models selectedItemBlock:(selectedItemBlock)block {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = AppStatus.theme.backgroundColor;
        _models = models;
        _selectedItemBlock = block;
        _collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionFlowLayout.minimumInteritemSpacing = 0;
        _collectionFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)- 1) collectionViewLayout:_collectionFlowLayout];
        _collectionView.backgroundColor = AppStatus.theme.backgroundColor;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"MCEnterpriseInfoCell" bundle:nil] forCellWithReuseIdentifier:@"MCEnterpriseInfoCell"];
        
        _hLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - 0.5, frame.size.width, 0.5)];
        _hLineImageView.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [self addSubview:_collectionView];
        [self addSubview:_hLineImageView];
        if (_models.count > 0) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:_models.count - 1 inSection:0];
            [_collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
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
    static NSString *collectionCellID = @"MCEnterpriseInfoCell";
    MCEnterpriseInfoCell *cell = (MCEnterpriseInfoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];
    id model = [_models objectAtIndex:indexPath.row];
    NSString *title = @"";
    if ([model isKindOfClass:[NSString class]]) {
        NSString *obj = (NSString *)model;
        title = obj;
    }
    if ([model isMemberOfClass:[MCEnterpriseContactCellItem class]]) {
        MCEnterpriseContactCellItem *obj = (MCEnterpriseContactCellItem *)model;
        title = obj.branchInfo.name;
    }

    BOOL enableSelectFlag = YES;
    if (indexPath.row == _models.count - 1) {
        enableSelectFlag = NO;
    }
    [cell configureWithTitle:title enableSelect:enableSelectFlag];
    return cell;
}

- (CGSize )collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id model = [_models objectAtIndex:indexPath.row];
    NSString *title = @"";
    if ([model isKindOfClass:[NSString class]]) {
        NSString *obj = (NSString *)model;
        title = obj;
    }
    if ([model isMemberOfClass:[MCEnterpriseContactCellItem class]]) {
        MCEnterpriseContactCellItem *obj = (MCEnterpriseContactCellItem *)model;
        title = obj.branchInfo.name;
    }
    BOOL enableSelectFlag = YES;
    if (indexPath.row == _models.count - 1) {
        enableSelectFlag = NO;
    }
    if (enableSelectFlag) {
        title = [title stringByAppendingString:@">"];
    }
    CGSize size = [title boundingRectWithSize:CGSizeMake(999999.0f, 21) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} context:nil].size;
    return  CGSizeMake(size.width + paddingX*2, size.height + paddingY*2);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //点击事件
    id model = [_models objectAtIndex:indexPath.row];
    BOOL enableSelectFlag = YES;
    if (indexPath.row == _models.count - 1) {
        enableSelectFlag = NO;
    }
    if (enableSelectFlag) {
        if (_selectedItemBlock) {
            _selectedItemBlock(model);
        }
    }
}

@end
