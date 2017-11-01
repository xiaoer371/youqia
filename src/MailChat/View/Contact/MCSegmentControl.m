//
//  MCSegmentControl.m
//  NPushMail
//
//  Created by wuwenyu on 16/4/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCSegmentControl.h"

#define MCSegmentControlItemFont (15)

#define MCSegmentControlHspace (0)

#define MCSegmentControlLineHeight (2)

#define MCSegmentControlAnimationTime (0.3)

#define MCSegmentControlIconWidth (50.0)
typedef NS_ENUM(NSInteger, MCSegmentControlItemType)
{
    MCSegmentControlItemTypeTitle = 0,
    MCSegmentControlItemTypeIconUrl
};

@interface MCSegmentControlItem : UIView

@property (nonatomic , strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *titleIconView;
@property (nonatomic, assign) MCSegmentControlItemType type;

- (void)setSelected:(BOOL)selected;
@end

@implementation MCSegmentControlItem

- (id)initWithFrame:(CGRect)frame title:(NSString *)title type:(MCSegmentControlItemType)type
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _type = type;
        switch (_type) {
            case MCSegmentControlItemTypeIconUrl:
            {
               
            }
                break;
            case MCSegmentControlItemTypeTitle:
            default:
            {
                _titleLabel = ({
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(MCSegmentControlHspace, 0, CGRectGetWidth(self.bounds) - 2 * MCSegmentControlHspace, CGRectGetHeight(self.bounds))];
                    label.font = [UIFont systemFontOfSize:MCSegmentControlItemFont];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.text = title;
                    label.textColor = AppStatus.theme.fontTintColor;
                    label.backgroundColor = [UIColor clearColor];
                    label;
                });
                [self addSubview:_titleLabel];
            }
                break;
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected{
    switch (_type) {
        case MCSegmentControlItemTypeIconUrl:
        {
        }
            break;
        default:
        {
            if (_titleLabel) {
                [_titleLabel setTextColor:selected? AppStatus.theme.tintColor:                    AppStatus.theme.fontTintColor];
            }
        }
            break;
    }
}

@end

@interface MCSegmentControl ()<UIScrollViewDelegate>

@property (nonatomic , strong) UIScrollView *contentView;

@property (nonatomic , strong) UIView *leftShadowView;

@property (nonatomic , strong) UIView *rightShadowView;

@property (nonatomic , strong) UIView *lineView;

@property (nonatomic , strong) NSMutableArray *itemFrames;

@property (nonatomic , strong) NSMutableArray *items;

@property (nonatomic) NSInteger currentIndex;

@property (nonatomic , assign) id <MCSegmentControlDelegate> delegate;

@property (nonatomic , copy) MCSegmentControlBlock block;

@end

@implementation MCSegmentControl

- (id)initWithFrame:(CGRect)frame Items:(NSArray *)titleItem
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        _contentView = ({
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
            scrollView.backgroundColor = [UIColor clearColor];
            scrollView.delegate = self;
            scrollView.showsHorizontalScrollIndicator = NO;
            [self addSubview:scrollView];
            
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap:)];
            [scrollView addGestureRecognizer:tapGes];
            [tapGes requireGestureRecognizerToFail:scrollView.panGestureRecognizer];
            scrollView;
        });
        
        [self initItemsWithTitleArray:titleItem];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame Items:(NSArray *)titleItem delegate:(id<MCSegmentControlDelegate>)delegate
{
    if (self = [self initWithFrame:frame Items:titleItem]) {
        self.delegate = delegate;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame Items:(NSArray *)titleItem selectedBlock:(MCSegmentControlBlock)selectedHandle
{
    if (self = [self initWithFrame:frame Items:titleItem]) {
        self.block = selectedHandle;
    }
    return self;
}

- (void)doTap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:sender.view];
    
    __weak typeof(self) weakSelf = self;
    
    [_itemFrames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CGRect rect = [obj CGRectValue];
        
        if (CGRectContainsPoint(rect, point)) {
            
            [weakSelf selectIndex:idx];
            
            [weakSelf transformAction:idx];
            
            *stop = YES;
        }
    }];
}

- (void)transformAction:(NSInteger)index
{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(MCSegmentControlDelegate)] && [self.delegate respondsToSelector:@selector(segmentControl:selectedIndex:)]) {
        
        [self.delegate segmentControl:self selectedIndex:index];
        
    }else if (self.block) {
        
        self.block(index);
    }
}

- (void)initItemsWithTitleArray:(NSArray *)titleArray
{
    _itemFrames = @[].mutableCopy;
    _items = @[].mutableCopy;
    float y = 0;
    float height = CGRectGetHeight(self.bounds);
    
    NSObject *obj = [titleArray firstObject];
    if ([obj isKindOfClass:[NSString class]]) {
        for (int i = 0; i < titleArray.count; i++) {
            float x = i > 0 ? CGRectGetMaxX([_itemFrames[i-1] CGRectValue]) : 0;
            float width = ScreenWidth/titleArray.count;
            CGRect rect = CGRectMake(x, y, width, height);
            [_itemFrames addObject:[NSValue valueWithCGRect:rect]];
        }
        
        for (int i = 0; i < titleArray.count; i++) {
            CGRect rect = [_itemFrames[i] CGRectValue];
            NSString *title = titleArray[i];
            MCSegmentControlItem *item = [[MCSegmentControlItem alloc] initWithFrame:rect title:title type:MCSegmentControlItemTypeTitle];
            if (i == 0) {
                [item setSelected:YES];
            }
            [_items addObject:item];
            [_contentView addSubview:item];
        }
        
    }
    
    [_contentView setContentSize:CGSizeMake(CGRectGetMaxX([[_itemFrames lastObject] CGRectValue]), CGRectGetHeight(self.bounds))];
    self.currentIndex = 0;
    [self selectIndex:0];
}

- (void)addRedLine
{
    if (!_lineView) {
        CGRect rect = [_itemFrames[0] CGRectValue];
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(
                                                             CGRectGetMinX(rect),
                                                             CGRectGetHeight(rect) - MCSegmentControlLineHeight,
                                                             CGRectGetWidth(rect) - 2 * MCSegmentControlHspace,
                                                             MCSegmentControlLineHeight)];
        _lineView.backgroundColor = AppStatus.theme.tintColor;
        [_contentView addSubview:_lineView];
        
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(rect)-0.5, CGRectGetWidth(self.bounds), 0.5)];
        bottomLineView.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [self addSubview:bottomLineView];
    }
}

- (void)selectIndex:(NSInteger)index
{
    [self addRedLine];
    if (index != _currentIndex) {
        MCSegmentControlItem *curItem = [_items objectAtIndex:index];
        CGRect rect = [_itemFrames[index] CGRectValue];
        CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + MCSegmentControlHspace, CGRectGetHeight(rect) - MCSegmentControlLineHeight, CGRectGetWidth(rect) - 2 * MCSegmentControlHspace, MCSegmentControlLineHeight);
        [UIView animateWithDuration:MCSegmentControlAnimationTime animations:^{
            _lineView.frame = lineRect;
        } completion:^(BOOL finished) {
            [_items enumerateObjectsUsingBlock:^(MCSegmentControlItem *item, NSUInteger idx, BOOL *stop) {
                [item setSelected:NO];
            }];
            [curItem setSelected:YES];
            _currentIndex = index;
        }];
    }
    [self setScrollOffset:index];
}

- (void)moveIndexWithProgress:(float)progress
{
    float delta = progress - _currentIndex;
    
    CGRect origionRect = [_itemFrames[_currentIndex] CGRectValue];;
    
    CGRect origionLineRect = CGRectMake(CGRectGetMinX(origionRect) + MCSegmentControlHspace, CGRectGetHeight(origionRect) - MCSegmentControlLineHeight, CGRectGetWidth(origionRect) - 2 * MCSegmentControlHspace, MCSegmentControlLineHeight);
    
    CGRect rect;
    
    if (delta > 0) {
        //        如果delta大于1的话，不能简单的用相邻item间距的乘法来计算距离
        if (delta > 1) {
            self.currentIndex += floorf(delta);
            delta -= floorf(delta);
            origionRect = [_itemFrames[_currentIndex] CGRectValue];;
            origionLineRect = CGRectMake(CGRectGetMinX(origionRect) + MCSegmentControlHspace, CGRectGetHeight(origionRect) - MCSegmentControlLineHeight, CGRectGetWidth(origionRect) - 2 * MCSegmentControlHspace, MCSegmentControlLineHeight);
        }
        
        
        
        if (_currentIndex == _itemFrames.count - 1) {
            return;
        }
        
        rect = [_itemFrames[_currentIndex + 1] CGRectValue];
        
        CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + MCSegmentControlHspace, CGRectGetHeight(rect) - MCSegmentControlLineHeight, CGRectGetWidth(rect) - 2 * MCSegmentControlHspace, MCSegmentControlLineHeight);
        
        CGRect moveRect = CGRectZero;
        
        moveRect.size = CGSizeMake(CGRectGetWidth(origionLineRect) + delta * (CGRectGetWidth(lineRect) - CGRectGetWidth(origionLineRect)), CGRectGetHeight(lineRect));
        moveRect.origin = CGPointMake(CGRectGetMidX(origionLineRect) + delta * (CGRectGetMidX(lineRect) - CGRectGetMidX(origionLineRect)) - CGRectGetMidX(moveRect), CGRectGetMidY(origionLineRect) - CGRectGetMidY(moveRect));
        _lineView.frame = moveRect;
    }else if (delta < 0){
        
        if (_currentIndex == 0) {
            return;
        }
        rect = [_itemFrames[_currentIndex - 1] CGRectValue];
        CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + MCSegmentControlHspace, CGRectGetHeight(rect) - MCSegmentControlLineHeight, CGRectGetWidth(rect) - 2 * MCSegmentControlHspace, MCSegmentControlLineHeight);
        CGRect moveRect = CGRectZero;
        moveRect.size = CGSizeMake(CGRectGetWidth(origionLineRect) - delta * (CGRectGetWidth(lineRect) - CGRectGetWidth(origionLineRect)), CGRectGetHeight(lineRect));
        moveRect.origin = CGPointMake(CGRectGetMidX(origionLineRect) - delta * (CGRectGetMidX(lineRect) - CGRectGetMidX(origionLineRect)) - CGRectGetMidX(moveRect), CGRectGetMidY(origionLineRect) - CGRectGetMidY(moveRect));
        _lineView.frame = moveRect;
        if (delta < -1) {
            self.currentIndex -= 1;
        }
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    if (currentIndex != _currentIndex) {
        MCSegmentControlItem *preItem = [_items objectAtIndex:_currentIndex];
        MCSegmentControlItem *curItem = [_items objectAtIndex:currentIndex];
        [preItem setSelected:NO];
        [curItem setSelected:YES];
        _currentIndex = currentIndex;
    }
}

- (void)endMoveIndex:(NSInteger)index
{
    [self selectIndex:index];
}

- (void)setScrollOffset:(NSInteger)index
{
    if (_contentView.contentSize.width <= ScreenWidth) {
        return;
    }
    
    CGRect rect = [_itemFrames[index] CGRectValue];
    
    float midX = CGRectGetMidX(rect);
    
    float offset = 0;
    
    float contentWidth = _contentView.contentSize.width;
    
    float halfWidth = CGRectGetWidth(self.bounds) / 2.0;
    
    if (midX < halfWidth) {
        offset = 0;
    }else if (midX > contentWidth - halfWidth){
        offset = contentWidth - 2 * halfWidth;
    }else{
        offset = midX - halfWidth;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        [_contentView setContentOffset:CGPointMake(offset, 0) animated:NO];
    }];
}

int ExceMinIndex(float f)
{
    int i = (int)f;
    if (f != i) {
        return i+1;
    }
    return i;
}


@end
