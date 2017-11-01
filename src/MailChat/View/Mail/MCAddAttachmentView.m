//
//  MCAddAttachmentView.m
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//
#import "MCAddAttachmentView.h"
#import "MFullScreenControl.h"
#import "MFullScreenView.h"
#import "UIImageView+WebCache.h"
#import "UIImage+MultiFormat.h"
@interface MCAddAttachmentView ()<UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UIScrollPageControlViewDelegate>

@property (nonatomic,strong)UICollectionView  *collectionView;
@property (nonatomic,assign)NSInteger  currentSelectIndex;
@property (nonatomic,strong)MFullScreenControl *control;
@property (nonatomic,strong)NSMutableArray *imageAttachments;

@end

static NSString*  const kMCAddAttachmentViewCellId = @"MCAddAttachmentViewCellId";

const static NSInteger kMCAddAttachmentViewItemCount      = 3;
const static CGFloat  kMcAddAttachmentViewSpaceLingHight  = 1.0;
const static CGFloat  kMCAddAttachmentViewButtonItemHight = 46;
const static CGFloat  kMCAddAttachmentViewButtonItemWidth = 58;
const static CGFloat  kMCAddAttachmentViewCollectionViewItemSpace = 0;
const static CGFloat  kMCAddAttachmentViewHight           = 200;
const static CGFloat  kMCAddAttachmentMargin              = 33.0;
@implementation MCAddAttachmentView

- (id)initWithMailAttachments:(NSMutableArray *)mailAttachments{
    
    if (self = [super init]) {
        _mailAttachments = mailAttachments;
        _imageAttachments = [NSMutableArray new];
        [self setUp];
    }
    return self;
}

- (void)setUp{
    
    self.frame = CGRectMake(0, ScreenHeigth - NAVIGATIONBARHIGHT, ScreenWidth, kMCAddAttachmentViewHight);
    self.backgroundColor = AppStatus.theme.toolBarBackgroundColor;
    UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, kMcAddAttachmentViewSpaceLingHight)];
    horizontalLine.backgroundColor = AppStatus.theme.toolBarSeparatorColor;
    [self addSubview:horizontalLine];
    
    CGFloat space = (ScreenWidth - 2*kMCAddAttachmentMargin - 3*kMCAddAttachmentViewButtonItemWidth)/2;
    for (int i = 0; i < kMCAddAttachmentViewItemCount; i ++) {
        UIButton*button = [UIButton  buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(kMCAddAttachmentMargin+i*(kMCAddAttachmentViewButtonItemWidth+space), 1, kMCAddAttachmentViewButtonItemWidth, kMCAddAttachmentViewButtonItemHight);
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"mc_writeMail_addFile%d",i]] forState:UIControlStateNormal];
        button.tag = i;
        [button addTarget:self action:@selector(didTouchUpSelectItem:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    UIView *verticalLine = [[UIView alloc]initWithFrame:CGRectMake(0, kMCAddAttachmentViewButtonItemHight - 1, ScreenWidth, kMcAddAttachmentViewSpaceLingHight)];
    verticalLine.backgroundColor = AppStatus.theme.toolBarSeparatorColor;
    [self addSubview:verticalLine];
    
    UICollectionViewFlowLayout *lay=[[UICollectionViewFlowLayout alloc] init];
    lay.itemSize = CGSizeMake(92 ,98);
    lay.minimumLineSpacing = kMCAddAttachmentViewCollectionViewItemSpace;
    lay.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
    lay.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, kMCAddAttachmentViewButtonItemHight + 1, ScreenWidth, self.frame.size.height - kMCAddAttachmentViewButtonItemHight - 1) collectionViewLayout:lay];
    self.collectionView.backgroundColor = AppStatus.theme.toolBarBackgroundColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:@"MCAddAtttachmentCell" bundle:nil] forCellWithReuseIdentifier:kMCAddAttachmentViewCellId];
    [self addSubview:self.collectionView];
}

#pragma mark UICollectionViewDelegate UICollectionDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _mailAttachments.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MCAddAtttachmentCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMCAddAttachmentViewCellId forIndexPath:indexPath];
    cell.attachment = _mailAttachments[indexPath.row];
    cell.mcDeleteAttachComplete = ^(MCMailAttachment *attachment){
        [self deleteAttachment:attachment];
    };
    return cell;
}
//delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MCMailAttachment *attachment = _mailAttachments[indexPath.row];
    if (!attachment.isDownload) {
        return;
    }
    NSArray *imageAttachs;
    NSInteger index = indexPath.row;
    if (attachment.isImage) {
        imageAttachs = [self getImageAttachments];
        index = [imageAttachs  indexOfObject:attachment];
    }
    if ([_delegate respondsToSelector:@selector(addAttachmentView:didSelectAttach:imageAttachs:index:)]) {
        [_delegate addAttachmentView:self didSelectAttach:attachment imageAttachs:imageAttachs index:index];
    }
}

- (void)deleteAttachment:(MCMailAttachment *)attachment {
    
    NSInteger index = [_mailAttachments indexOfObject:attachment];
    if (index == NSNotFound) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_mailAttachments removeObject:attachment];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    if ([_delegate respondsToSelector:@selector(didDeleteAttachment:index:)]) {
        [_delegate didDeleteAttachment:attachment index:self.currentSelectIndex];
    }
}

- (void)didTouchUpSelectItem:(UIButton*)sender{
    //友盟事件统计
    switch (sender.tag) {
        case 0:
            [MCUmengManager addEventWithKey:mc_mail_detail_write_image];
            break;
        case 1:
            [MCUmengManager addEventWithKey:mc_mail_detail_write_takephoto];
            break;
        case 2:
            [MCUmengManager addEventWithKey:mc_mail_detail_write_file];
            break;
        default:
            break;
    }
    if ([_delegate respondsToSelector:@selector(addAttachmentView:didSelectImagePickerSourceType:)]) {
        [_delegate addAttachmentView:self didSelectImagePickerSourceType:sender.tag];
    }
}

//add attachments
- (void)setMailAttachments:(NSMutableArray *)mailAttachments {
    _mailAttachments = mailAttachments;
    [self.collectionView reloadData];
}

- (void)reload {
    [self.collectionView reloadData];
}

//Private
- (NSArray*)getImageAttachments {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.isImage == %d",1];
    NSArray *imageAttachs = [_mailAttachments filteredArrayUsingPredicate:predicate];
    return imageAttachs;
}

@end
