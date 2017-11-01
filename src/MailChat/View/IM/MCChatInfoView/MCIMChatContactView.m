//
//  MCIMChatContactView.m
//  NPushMail
//
//  Created by swhl on 16/3/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatContactView.h"
#import "MCIMChatContactCell.h"
#import "MCIMChatContactFootView.h"
#import "UIView+MCExpand.h"

//为了测试方便，暂时设置页面最多显示个数  6--15  4--16
const static  CGFloat  xCellRowMaxSHowNum6 = 15;
const static  CGFloat  xCellRowMaxSHowNum4s = 16;
const static  CGFloat  xCellRowSHowNum6 = 5;
const static  CGFloat  xCellRowSHowNum4s = 4;

const static  CGFloat  xCellFootViewHeight = 44.0f;
const static  CGFloat  xCellItemViewWidth = 50.0f;
const static  CGFloat  xCellItemViewHeight = 74.0f;
const static  CGFloat  xCellItemTop = 12.0f;
const static  CGFloat  xCellItemLeft = 14.0f;
const static  CGFloat  xCellItemDown= 12.0f;
const static  CGFloat  xCellItemRight = 14.0f;


@interface MCIMChatContactView ()<UICollectionViewDataSource,UICollectionViewDelegate,MCIMChatContactCellDelegate,MCIMChatContactFootViewDelegate>
{
    NSUInteger _dataSourceNum;
    NSUInteger _membersCount;
    CGFloat  xCellRowNumber;  //iphone 4  4s 5 5s==4   其他=5
}
@property (nonatomic, strong) UICollectionView *collectView;
@property (nonatomic, strong) UIImageView      *lineImage;
@property (nonatomic, strong) NSMutableArray   *noShowDataSource;

@end

@implementation MCIMChatContactView

- (void)dealloc
{
    [self.collectView removeObserver:self forKeyPath:@"contentSize"];
}

-(instancetype)initWithFrame:(CGRect)frame
                  dataSource:(NSArray *)array
                        type:(MCIMChatContactViewType)type
{
    xCellRowNumber = ScreenWidth<321?xCellRowSHowNum4s:xCellRowSHowNum6;
    CGFloat count =0;
    CGFloat diffcount =0;
    _membersCount = array.count;
    switch (type) {
        case MCIMChatContactViewTypeGroupDel:
            count = array.count+2;
            diffcount = 2;
            break;
        case MCIMChatContactViewTypeGroupNoDel:
            count = array.count+1;
            diffcount = 1;
            break;
        default:
            count = 2;
            break;
    }
    CGFloat maxNum = xCellRowNumber==4?xCellRowMaxSHowNum4s:xCellRowMaxSHowNum6;
    CGFloat showNum = count >= maxNum ? maxNum:count;
    CGFloat offy = xCellRowNumber==4?2.0:1.5; //一行4个5个，footView size 有问题。
    CGFloat height = xCellItemViewHeight * ceil((showNum)/xCellRowNumber) + 13*(offy) + ((ceil(showNum/xCellRowNumber))-1)*24;
    CGRect rect = frame;
    CGFloat  extentHeight = array.count >= (maxNum-diffcount)?xCellFootViewHeight:0.0f;
    rect.size.height = height + extentHeight;
    
    self = [super initWithFrame:rect];
    if (self) {
        self.type = type;
        if (array) {
            [self.noShowDataSource addObjectsFromArray:array];
            
            CGFloat lengthNum = array.count >=(maxNum-diffcount)?(maxNum-diffcount):array.count;
            NSRange rage = NSMakeRange(0, lengthNum);
            NSIndexSet *indexSet =[NSIndexSet indexSetWithIndexesInRange:rage];
            array = [array subarrayWithRange:rage];
            [self.dataArray insertObjects:array atIndexes:indexSet];
            
            [self.noShowDataSource removeObjectsAtIndexes:indexSet];
        }
        
        _dataSourceNum = self.dataArray.count;
        [self addSubview:self.collectView];
        self.backgroundColor = [UIColor whiteColor];
        
        _lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, rect.size.height-0.5, ScreenWidth, 0.5)];
        _lineImage.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [self addSubview:_lineImage];
        
        
        
        [self.collectView addObserver:self
                             forKeyPath:@"contentSize"
                                options:NSKeyValueObservingOptionOld
                                context:nil];
        
    }

    return self;
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (object == self.collectView && [keyPath isEqualToString:@"contentSize"]) {
        
        CGRect rect = self.frame;
        rect.size = self.collectView.contentSize;
        
        self.frame =rect;
        _lineImage.frame = CGRectMake(0, rect.size.height-0.5, ScreenWidth, 0.5);
        self.collectView.frame =self.bounds;
        
        if (self.delegate &&[self.delegate respondsToSelector:@selector(didReloadDataSourceFrame:)]) {
            [self.delegate didReloadDataSourceFrame:self.frame];
        }
        
    }
}


-(void)setOriginPoint:(CGPoint)originPoint
{
    _originPoint = originPoint;
    CGRect rect = self.frame;
    rect.origin.x = originPoint.x;
    rect.origin.y = originPoint.y;
    self.frame = rect;
}

-(UICollectionView *)collectView
{
    if (!_collectView) {
        
        UICollectionViewFlowLayout *collectViewLayout = [[UICollectionViewFlowLayout alloc] init];
        [collectViewLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        _collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height) collectionViewLayout:collectViewLayout];
        _collectView.delegate = self;
        _collectView.dataSource = self;
        _collectView.scrollEnabled = NO;
        _collectView.backgroundColor = [UIColor whiteColor];
        [_collectView registerClass:[MCIMChatContactCell class] forCellWithReuseIdentifier:@"MCIMChatContactCell"];
        [_collectView registerClass:[MCIMChatContactFootView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"MCIMChatContactFootView"];
    }
    return _collectView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return  self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"MCIMChatContactCell";
    MCIMChatContactCell * cell = (MCIMChatContactCell*) [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    MCIMChatContactCellModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(xCellItemViewWidth,xCellItemViewHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(13, 24, 13, 24);
    return UIEdgeInsetsMake(xCellItemTop, xCellItemLeft, xCellItemDown, xCellItemRight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return (ScreenWidth - 2*24 - xCellRowNumber*xCellItemViewWidth)/(xCellRowNumber-1);
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 13;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.type) {
        case MCIMChatContactViewTypeSingle:
        {
            if (indexPath.row ==1) {
                if (self.delegate &&[self.delegate respondsToSelector:@selector(didSelectAddContactToGroup)]) {
                    [self.delegate didSelectAddContactToGroup];
                }
            }else
            {
                if (self.delegate &&[self.delegate respondsToSelector:@selector(didSelectItem:)]) {
                    MCIMChatContactCellModel *model = self.dataArray[indexPath.row];
                    [self.delegate didSelectItem:model];
                }
            }
        }
            break;
            
        case MCIMChatContactViewTypeGroupDel:
        {
            if (indexPath.row == self.dataArray.count-1) {
                if (self.delegate &&[self.delegate respondsToSelector:@selector(deleteDataSourceItem)]) {
                    [self.delegate deleteDataSourceItem];
                }
            }else if (indexPath.row == self.dataArray.count-2){
                
                if (self.delegate &&[self.delegate respondsToSelector:@selector(addDataSourceItem)]) {
                    [self.delegate addDataSourceItem];
                }
                
            }else{
                if (self.delegate &&[self.delegate respondsToSelector:@selector(didSelectItem:)]) {
                    MCIMChatContactCellModel *model = self.dataArray[indexPath.row];
                    [self.delegate didSelectItem:model];
                }
            }

        }
            break;
            
        case MCIMChatContactViewTypeGroupNoDel:
        {
            if (indexPath.row == self.dataArray.count-1) {
                if (self.delegate &&[self.delegate respondsToSelector:@selector(didSelectAddContactToGroup)]) {
                    [self.delegate addDataSourceItem];
                }
            }else
            {
                if (self.delegate &&[self.delegate respondsToSelector:@selector(didSelectItem:)]) {
                    MCIMChatContactCellModel *model = self.dataArray[indexPath.row];
                    [self.delegate didSelectItem:model];
                }
            }
        }
            break;
            
        default:
            break;
    };
}

#pragma mark - 区尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if([kind isEqual:UICollectionElementKindSectionFooter])
    {
      MCIMChatContactFootView *footView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"MCIMChatContactFootView" forIndexPath:indexPath];
        footView.delegate = self;
        footView.textLab.text = [NSString stringWithFormat:@"%@(%lu)", PMLocalizedStringWithKey(@"PM_Msg_SingleName"),(unsigned long)_membersCount];
        return footView;

    }else return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
     CGFloat maxNum = xCellRowNumber==4?xCellRowMaxSHowNum4s:xCellRowMaxSHowNum6;
    if (self.dataArray.count == maxNum) {
        return CGSizeMake(ScreenWidth, xCellFootViewHeight);
    }else{
        return CGSizeZero;
    }
}

-(void)didSelectAction
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(didSelectGroupMembers)]) {
        [self.delegate didSelectGroupMembers];
    }
}


#pragma mark - datasource
-(void)addItemsWithModels:(NSArray <__kindof MCIMChatContactCellModel *> *)models
{
    _dataSourceNum = _dataArray.count;
    BOOL isStop = NO;
    for (MCIMChatContactCellModel *model  in models) {
        _dataSourceNum = _dataArray.count;
        _membersCount ++;
        if (isStop ==NO && [self addItemDataArray:_dataSourceNum]) {
            [_dataArray insertObject:model atIndex:_dataArray.count-2];
            continue;
        }
        if(xCellRowNumber ==xCellRowSHowNum4s)
        {
            if (self.dataArray.count ==xCellRowMaxSHowNum4s) {
                isStop = YES;
                if (![self.noShowDataSource containsObject:model]) {
                    [self.noShowDataSource addObject:model];
                    continue;
                }
            }
        }else{
            if (self.dataArray.count == xCellRowMaxSHowNum6) {
                isStop = YES;
                if (![self.noShowDataSource containsObject:model]) {
                    [self.noShowDataSource addObject:model];
                }
            }
        }
    }
//    [self layoutCollectionViewFrame];
    [self.collectView reloadData];
}

- (BOOL)addItemDataArray:(NSInteger)a
{
    if (xCellRowNumber ==xCellRowSHowNum4s) {
        if (a == xCellRowMaxSHowNum4s) {
            return NO;
        }return YES;
    }else{
        if (a == xCellRowMaxSHowNum6) {
            return NO;
        }return YES;
    }

}


-(void)deleteItemsWithModels:(NSArray <__kindof MCIMChatContactCellModel *> *)models
{
    _dataSourceNum = _dataArray.count;
    NSArray *tempArray = self.dataArray.copy;
    
    
    NSInteger delNum = 0;
    for (MCIMChatContactCellModel *model in models) {
        for (MCIMChatContactCellModel *model2 in tempArray) {
            if ([model.account  isEqualToString:model2.account]) {
                [self.dataArray removeObject:model2];
                delNum +=1;
            }
        }
        _membersCount --;
    }

    if (self.noShowDataSource.count >=1 ) {
        [self addnoShowDataSource:delNum];
    }
    
    [self.collectView reloadData];
}

- (void)addnoShowDataSource:(NSInteger)num
{
    NSArray *tempArrap = [NSArray arrayWithArray:self.noShowDataSource];
    
    NSInteger a = num;
    for (MCIMChatContactCellModel *model  in tempArrap ) {
        if (a >= tempArrap.count) {
            [_dataArray insertObject:model atIndex:_dataArray.count-2];
            _dataSourceNum = _dataArray.count;
            [self.noShowDataSource removeObject:model];
        }else{
            for (int j=0; j<a; j++ ) {
                [_dataArray insertObject:model atIndex:_dataArray.count-2];
                _dataSourceNum = _dataArray.count;
                [self.noShowDataSource removeObject:model];
            }
        }
        a--;
        if ( a< 0 ) {
            return;
        }
    }
}

//-(void)layoutCollectionViewFrame
//{
//    
////    self.collectView.contentSize
//    return;
//    
//    NSUInteger oldNum = ceil(_dataSourceNum/xCellRowNumber);
//    NSUInteger newNum = ceil(self.dataArray.count/xCellRowNumber);
//    CGFloat maxNum = xCellRowNumber==4?xCellRowMaxSHowNum4s:xCellRowMaxSHowNum6;
//
//    if (oldNum != newNum ||  (self.dataArray.count <= maxNum || self.dataArray.count >= (maxNum - xCellRowNumber))){
//        
//        CGFloat  extentHeight = self.dataArray.count==maxNum?xCellFootViewHeight:0.0f;
//        CGFloat height = xCellItemViewHeight * ceil((self.dataArray.count)/xCellRowNumber) + 13 +(ceil((self.dataArray.count)/xCellRowNumber)-1)*24 + extentHeight;
//
//        CGRect supRect = self.frame;
//        supRect.size.height = height;
//        self.frame = supRect;
//        _lineImage.frame = CGRectMake(0, supRect.size.height-0.5, ScreenWidth, 0.5);
//        self.collectView.frame = self.bounds;
//        if (self.delegate &&[self.delegate respondsToSelector:@selector(didReloadDataSourceFrame:)]) {
//            [self.delegate didReloadDataSourceFrame:self.frame];
//        }
//    }
//}


- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray  = [[NSMutableArray alloc] init];
        
        MCIMChatContactCellModel *model1 = [[MCIMChatContactCellModel alloc] init];
        model1.account = @"add";
        model1.name = PMLocalizedStringWithKey(@"PM_Msg_GroupMemberAdd");
        model1.state = MCModelStateAdd;
        model1.type = MCModelStateMember;

        [_dataArray addObject:model1];
        
        if (self.type == MCIMChatContactViewTypeGroupDel) {
            MCIMChatContactCellModel *model2 = [[MCIMChatContactCellModel alloc] init];
            model2.account = @"del";
            model2.name = PMLocalizedStringWithKey(@"PM_Msg_DelMsgCell");
            model2.type = MCModelStateMember;
            model2.state = MCModelStateDel;
            [_dataArray addObject:model2];
        }
    }
    return _dataArray;
}

- (NSMutableArray *)noShowDataSource
{
    if (!_noShowDataSource) {
        _noShowDataSource  = [[NSMutableArray alloc] init];
    }
    return _noShowDataSource;
}

@end
