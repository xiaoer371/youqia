//
//  MCShowSelectedMembersBottomView.m
//  NPushMail
//
//  Created by wuwenyu on 16/4/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCShowSelectedMembersBottomView.h"
#import "MCSelectedMemberCell.h"

@interface MCShowSelectedMembersBottomView()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)UICollectionViewFlowLayout *collectionFlowLayout;

@end

static const CGFloat sureBtnWidth = 50;
static const CGFloat sureBtnHeight = 30;

@implementation MCShowSelectedMembersBottomView {
    UIButton *_sureBtn;
    UIImageView *_hLineImageView;
}

- (id)initWithFrame:(CGRect)frame selectedBlock:(SelectedModelsBlock)block {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = AppStatus.theme.toolBarBackgroundColor;
        _selectedBlcok = block;
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.frame = CGRectMake(CGRectGetWidth(frame) - sureBtnWidth - 5, (CGRectGetHeight(frame) - sureBtnHeight)/2, sureBtnWidth, sureBtnHeight);
        [_sureBtn setTitle:PMLocalizedStringWithKey(@"PM_Common_Sure") forState:UIControlStateNormal];
        [_sureBtn setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sureBtnPress) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sureBtn];

        _collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionFlowLayout.minimumInteritemSpacing = 0;
        _collectionFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame) - CGRectGetWidth(_sureBtn.frame) - 2, CGRectGetHeight(frame)) collectionViewLayout:_collectionFlowLayout];
        _collectionView.backgroundColor = AppStatus.theme.toolBarBackgroundColor;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"MCSelectedMemberCell" bundle:nil] forCellWithReuseIdentifier:@"MCSelectedMemberCell"];
        
        _hLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        _hLineImageView.backgroundColor = AppStatus.theme.toolBarSeparatorColor;
        [self addSubview:_collectionView];
        [self addSubview:_hLineImageView];
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
    MCSelectedMemberCell* cell = (MCSelectedMemberCell *)[collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];
    MCContactModel *model = [_models objectAtIndex:indexPath.row];
    [cell configureCellWithModel:model indexPath:indexPath];
    return cell;
}

- (CGSize )collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return  CGSizeMake(37, CGRectGetHeight(self.frame));
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //点击头像
}

- (void)sureBtnPress {
    if (_models.count == 0) {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Contact_selectedContacts") delegate:nil cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Sure") otherButtonTitles:nil, nil];
        [alertV show];
        return;
    }
    if (_selectedBlcok) {
        _selectedBlcok(_models);
    }
}

@end
